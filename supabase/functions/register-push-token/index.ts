/**
 * register-push-token
 * 
 * Registers or updates an APNs device token for the authenticated user.
 * Called by the iOS client immediately after receiving a device token from APNs.
 * 
 * Method: POST
 * Auth: Bearer token (Supabase JWT)
 * Body: { device_token: string, platform: "ios", app_version: string }
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface RegisterTokenRequest {
  device_token: string
  platform?: string
  app_version?: string
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Authenticate caller via Supabase JWT
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing Authorization header' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const body: RegisterTokenRequest = await req.json()
    if (!body.device_token || typeof body.device_token !== 'string') {
      return new Response(JSON.stringify({ error: 'device_token is required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Validate token format (APNs tokens are 64-char hex strings)
    const tokenRegex = /^[0-9a-f]{64}$/i
    if (!tokenRegex.test(body.device_token)) {
      return new Response(JSON.stringify({ error: 'Invalid device_token format' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Use service role for DB write
    const serviceSupabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Upsert: if this token already exists for this user, update it;
    // otherwise insert a new record.
    const { data, error: upsertError } = await serviceSupabase
      .from('push_tokens')
      .upsert({
        user_id: user.id,
        device_token: body.device_token,
        platform: body.platform ?? 'ios',
        app_version: body.app_version ?? null,
        is_active: true,
        last_used_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      }, {
        onConflict: 'user_id,device_token',
      })
      .select()
      .single()

    if (upsertError) {
      console.error('Failed to upsert push token:', upsertError)
      return new Response(JSON.stringify({ error: upsertError.message }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    console.log(`Push token registered for user ${user.id}: ${body.device_token.slice(0, 8)}...`)

    return new Response(
      JSON.stringify({ success: true, id: data.id }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    console.error('Unexpected error:', err)
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
