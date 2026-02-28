/**
 * notify-expiring-deals
 *
 * Sends push notifications to users who have bookmarked deals
 * that are expiring within the next 30 minutes.
 *
 * Schedule: Invoke every 15 minutes via pg_cron or Supabase Cron.
 *   SELECT cron.schedule('notify-expiring', '*/15 * * * *',
 *     $$SELECT net.http_post(url:='<SUPABASE_URL>/functions/v1/notify-expiring-deals',
 *       headers:='{"Authorization": "Bearer <SERVICE_KEY>"}'::jsonb, body:='{}'::jsonb) AS request_id$$);
 *
 * Method: POST (no body required)
 * Auth: service-role key in Authorization header
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { sendAPNsPush, APNsResult } from '../_shared/apns.ts'

serve(async (_req) => {
  try {
    const serviceSupabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const now = new Date()
    const windowStart = new Date(now.getTime() + 28 * 60 * 1000) // 28 min from now
    const windowEnd   = new Date(now.getTime() + 32 * 60 * 1000) // 32 min from now

    // Find active deals expiring in the 28-32 minute window
    // (4-minute window to handle cron timing jitter)
    const { data: deals, error: dealsError } = await serviceSupabase
      .from('deals')
      .select('id, title, venue_id, expires_at, venues(name)')
      .eq('is_active', true)
      .gte('expires_at', windowStart.toISOString())
      .lte('expires_at', windowEnd.toISOString())

    if (dealsError) {
      throw new Error(`Failed to fetch expiring deals: ${dealsError.message}`)
    }

    if (!deals?.length) {
      return new Response(JSON.stringify({ sent: 0, message: 'No deals expiring in window' }), { status: 200 })
    }

    console.log(`Found ${deals.length} deals expiring in next 28-32 minutes`)

    let totalSent = 0
    let totalFailed = 0

    for (const deal of deals) {
      const venueName = (deal.venues as { name: string })?.name ?? 'the venue'

      // Find users who bookmarked this deal (not just the venue)
      const { data: bookmarks, error: bookmarkError } = await serviceSupabase
        .from('bookmarks')
        .select('user_id')
        .eq('deal_id', deal.id)

      if (bookmarkError || !bookmarks?.length) continue

      const userIds = bookmarks.map((b: { user_id: string }) => b.user_id)

      // Fetch active push tokens, filtering by notification preference
      const { data: tokenRows, error: tokenError } = await serviceSupabase
        .from('push_tokens')
        .select('user_id, device_token')
        .in('user_id', userIds)
        .eq('is_active', true)
        .eq('platform', 'ios')

      if (tokenError || !tokenRows?.length) continue

      // Also check user notification prefs (expiring_soon must be true)
      const { data: profiles } = await serviceSupabase
        .from('user_profiles')
        .select('id, notification_prefs')
        .in('id', userIds)
        .eq('notification_prefs->expiring_soon', true)

      const allowedUserIds = new Set((profiles ?? []).map((p: { id: string }) => p.id))
      const filteredTokens = tokenRows.filter((t: { user_id: string }) => allowedUserIds.has(t.user_id))

      if (!filteredTokens.length) continue

      const title = '⏰ Deal Expiring Soon!'
      const body = `${deal.title} at ${venueName} expires in 30 minutes`

      const results: APNsResult[] = await Promise.all(
        filteredTokens.map((t: { user_id: string; device_token: string }) =>
          sendAPNsPush({
            deviceToken: t.device_token,
            title,
            body,
            dealId: deal.id,
            venueId: deal.venue_id,
            notificationType: 'deal_expiring_soon',
            badge: 1,
          })
        )
      )

      // Log notifications
      const logEntries = filteredTokens.map((t: { user_id: string; device_token: string }, i: number) => ({
        user_id: t.user_id,
        notification_type: 'deal_expiring_soon',
        title,
        body,
        deal_id: deal.id,
        venue_id: deal.venue_id,
        device_token: t.device_token,
        apns_status: results[i]?.success ? 'sent' : 'failed',
        error_message: results[i]?.error ?? null,
      }))
      await serviceSupabase.from('notification_log').insert(logEntries)

      // Deactivate invalid tokens
      const invalidTokens = results.filter(r => r.invalidToken).map(r => r.deviceToken)
      if (invalidTokens.length) {
        await serviceSupabase.from('push_tokens').update({ is_active: false }).in('device_token', invalidTokens)
      }

      const sent = results.filter(r => r.success).length
      const failed = results.filter(r => !r.success).length
      totalSent += sent
      totalFailed += failed

      console.log(`Deal ${deal.id}: sent=${sent} failed=${failed}`)
    }

    return new Response(
      JSON.stringify({ sent: totalSent, failed: totalFailed, deals_processed: deals.length }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    console.error('notify-expiring-deals error:', err)
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
