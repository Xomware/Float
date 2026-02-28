/**
 * notify-favorites
 * 
 * Sends push notifications to users who have bookmarked a venue
 * when that venue posts a new active deal.
 * 
 * Intended to be called as a Postgres webhook trigger on deals INSERT,
 * or manually via POST from an admin tool / other edge function.
 * 
 * Method: POST
 * Auth: service-role only (webhook or internal call)
 * Body: { deal_id: string }  — the newly created deal
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { sendAPNsPush, APNsResult } from '../_shared/apns.ts'

serve(async (req) => {
  try {
    const serviceSupabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Support Postgres webhook format (record in payload) or direct call
    let dealId: string
    const body = await req.json()

    if (body.record?.id) {
      // Postgres webhook: { type: 'INSERT', record: { id, ... } }
      dealId = body.record.id
    } else if (body.deal_id) {
      dealId = body.deal_id
    } else {
      return new Response(JSON.stringify({ error: 'deal_id required' }), { status: 400 })
    }

    // Fetch the deal + venue details
    const { data: deal, error: dealError } = await serviceSupabase
      .from('deals')
      .select('id, title, description, venue_id, is_active, venues(id, name)')
      .eq('id', dealId)
      .single()

    if (dealError || !deal) {
      return new Response(JSON.stringify({ error: 'Deal not found' }), { status: 404 })
    }

    if (!deal.is_active) {
      return new Response(JSON.stringify({ skipped: 'Deal is not active' }), { status: 200 })
    }

    const venue = deal.venues as { id: string; name: string }
    const venueId = venue.id
    const venueName = venue.name

    // Find all users who bookmarked this venue and have active push tokens
    const { data: bookmarks, error: bookmarkError } = await serviceSupabase
      .from('bookmarks')
      .select('user_id')
      .eq('venue_id', venueId)
      .not('user_id', 'is', null)

    if (bookmarkError) {
      throw new Error(`Failed to fetch bookmarks: ${bookmarkError.message}`)
    }

    if (!bookmarks?.length) {
      return new Response(JSON.stringify({ sent: 0, message: 'No users have bookmarked this venue' }), { status: 200 })
    }

    const userIds = bookmarks.map((b: { user_id: string }) => b.user_id)

    // Fetch active push tokens for these users
    const { data: tokens, error: tokenError } = await serviceSupabase
      .from('push_tokens')
      .select('user_id, device_token')
      .in('user_id', userIds)
      .eq('platform', 'ios')
      .eq('is_active', true)

    if (tokenError) {
      throw new Error(`Failed to fetch push tokens: ${tokenError.message}`)
    }

    if (!tokens?.length) {
      return new Response(JSON.stringify({ sent: 0, message: 'No active push tokens' }), { status: 200 })
    }

    // Send APNs pushes
    const title = `New Deal from ${venueName}! 🎉`
    const body_text = deal.title
    const results: APNsResult[] = await Promise.all(
      tokens.map((t: { user_id: string; device_token: string }) =>
        sendAPNsPush({
          deviceToken: t.device_token,
          title,
          body: body_text,
          dealId: deal.id,
          venueId,
          notificationType: 'favorited_venue_new_deal',
          badge: 1,
        })
      )
    )

    // Batch-insert notification logs
    const logEntries = tokens.map((t: { user_id: string; device_token: string }, i: number) => ({
      user_id: t.user_id,
      notification_type: 'favorited_venue_new_deal',
      title,
      body: body_text,
      deal_id: deal.id,
      venue_id: venueId,
      device_token: t.device_token,
      apns_status: results[i]?.success ? 'sent' : 'failed',
      error_message: results[i]?.error ?? null,
    }))

    await serviceSupabase.from('notification_log').insert(logEntries)

    // Deactivate invalid tokens returned by APNs
    const invalidTokens = results
      .filter(r => r.invalidToken)
      .map(r => r.deviceToken)

    if (invalidTokens.length) {
      await serviceSupabase
        .from('push_tokens')
        .update({ is_active: false })
        .in('device_token', invalidTokens)
      console.log(`Deactivated ${invalidTokens.length} invalid tokens`)
    }

    const sent = results.filter(r => r.success).length
    const failed = results.filter(r => !r.success).length

    console.log(`notify-favorites: deal=${dealId} venue=${venueId} sent=${sent} failed=${failed}`)

    return new Response(
      JSON.stringify({ sent, failed, total: tokens.length }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    console.error('notify-favorites error:', err)
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
