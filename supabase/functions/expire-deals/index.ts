import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Cron: runs every 5 minutes via Supabase Cron Jobs
// Schedule: */5 * * * *
serve(async (_req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''  // needs service role to bypass RLS
  )

  const { data, error } = await supabase.rpc('expire_stale_deals')

  if (error) {
    console.error('Error expiring deals:', error)
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }

  const message = `Expired ${data} deals at ${new Date().toISOString()}`
  console.log(message)
  return new Response(JSON.stringify({ message, expired_count: data }))
})
