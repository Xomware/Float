import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface NotificationPayload {
  user_ids?: string[]    // specific users
  venue_id?: string      // notify all users near this venue
  title: string
  body: string
  deal_id?: string       // deep link
}

serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const payload: NotificationPayload = await req.json()

    // Get device tokens
    let tokens: string[] = []
    
    if (payload.user_ids?.length) {
      const { data } = await supabase
        .from('user_profiles')
        .select('apns_token')
        .in('id', payload.user_ids)
        .not('apns_token', 'is', null)
        .eq('notification_prefs->deals_nearby', 'true')
      
      tokens = data?.map((u: { apns_token: string }) => u.apns_token).filter(Boolean) ?? []
    }

    // Send APNs push via Supabase Auth (placeholder for actual APNs HTTP/2 implementation)
    const results = await Promise.allSettled(
      tokens.map(token => sendAPNS(token, payload.title, payload.body, payload.deal_id))
    )

    const sent = results.filter(r => r.status === 'fulfilled').length
    const failed = results.filter(r => r.status === 'rejected').length

    return new Response(
      JSON.stringify({ sent, failed, total: tokens.length }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})

async function sendAPNS(token: string, title: string, body: string, dealId?: string) {
  // APNs HTTP/2 push — requires JWT signed with Apple key
  // Full implementation requires: APNS_KEY_ID, APNS_TEAM_ID, APNS_PRIVATE_KEY env vars
  const apnsUrl = `https://api.push.apple.com/3/device/${token}`
  
  const payload = {
    aps: {
      alert: { title, body },
      sound: 'default',
      badge: 1,
    },
    dealId,  // for deep linking
  }

  // Placeholder — real impl needs JWT signing with Apple's ES256 key
  console.log(`APNs push to ${token.slice(0, 8)}...: ${title}`)
  return { token, payload }
}
