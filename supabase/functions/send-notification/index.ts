/**
 * send-notification
 *
 * Generic push notification sender. Can target specific users or
 * all users with active push tokens near a venue.
 *
 * Method: POST
 * Auth: service-role key
 * Body:
 *   user_ids?:    string[]   — notify specific users
 *   venue_id?:    string     — notify all users with tokens (geofence broadcast)
 *   title:        string
 *   body:         string
 *   deal_id?:     string     — deep link target
 *   notification_type?: string
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { sendAPNsPush, APNsResult } from '../_shared/apns.ts'

interface NotificationPayload {
  user_ids?: string[]
  venue_id?: string
  title: string
  body: string
  deal_id?: string
  notification_type?: string
  badge?: number
}

serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const payload: NotificationPayload = await req.json()

    if (!payload.title || !payload.body) {
      return new Response(JSON.stringify({ error: 'title and body are required' }), { status: 400 })
    }

    let userIds: string[] = payload.user_ids ?? []

    // If venue_id provided, find users who bookmarked it
    if (payload.venue_id && !userIds.length) {
      const { data: bookmarks } = await supabase
        .from('bookmarks')
        .select('user_id')
        .eq('venue_id', payload.venue_id)

      userIds = bookmarks?.map((b: { user_id: string }) => b.user_id) ?? []
    }

    if (!userIds.length) {
      return new Response(JSON.stringify({ sent: 0, message: 'No target users' }), { status: 200 })
    }

    // Fetch active push tokens for target users
    const { data: tokenRows, error: tokenError } = await supabase
      .from('push_tokens')
      .select('user_id, device_token')
      .in('user_id', userIds)
      .eq('is_active', true)
      .eq('platform', 'ios')

    if (tokenError) throw new Error(`Token fetch failed: ${tokenError.message}`)
    if (!tokenRows?.length) {
      return new Response(JSON.stringify({ sent: 0, message: 'No active tokens' }), { status: 200 })
    }

    // Send pushes
    const results: APNsResult[] = await Promise.all(
      tokenRows.map((t: { user_id: string; device_token: string }) =>
        sendAPNsPush({
          deviceToken: t.device_token,
          title: payload.title,
          body: payload.body,
          dealId: payload.deal_id,
          venueId: payload.venue_id,
          notificationType: payload.notification_type,
          badge: payload.badge ?? 1,
        })
      )
    )

    // Log to notification_log
    const logEntries = tokenRows.map((t: { user_id: string; device_token: string }, i: number) => ({
      user_id: t.user_id,
      notification_type: payload.notification_type ?? 'system_announcement',
      title: payload.title,
      body: payload.body,
      deal_id: payload.deal_id ?? null,
      venue_id: payload.venue_id ?? null,
      device_token: t.device_token,
      apns_status: results[i]?.success ? 'sent' : 'failed',
      error_message: results[i]?.error ?? null,
    }))
    await supabase.from('notification_log').insert(logEntries)

    // Deactivate invalid tokens
    const invalidTokens = results.filter(r => r.invalidToken).map(r => r.deviceToken)
    if (invalidTokens.length) {
      await supabase.from('push_tokens').update({ is_active: false }).in('device_token', invalidTokens)
      console.log(`Deactivated ${invalidTokens.length} invalid tokens`)
    }

    const sent = results.filter(r => r.success).length
    const failed = results.filter(r => !r.success).length

    return new Response(
      JSON.stringify({ sent, failed, total: tokenRows.length }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    console.error('send-notification error:', err)
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
