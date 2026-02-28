import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/types/database";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey);

export async function getSession() {
  const {
    data: { session },
    error,
  } = await supabase.auth.getSession();
  if (error) throw error;
  return session;
}

export async function getMerchantProfile(userId: string) {
  const { data, error } = await supabase
    .from("merchants")
    .select("*")
    .eq("user_id", userId)
    .single();
  if (error) throw error;
  return data;
}

export async function getMerchantVenues(merchantId: string) {
  const { data, error } = await supabase
    .from("merchant_venues")
    .select(`
      venue_id,
      role,
      venues (
        id,
        name,
        address,
        city,
        state,
        zip,
        phone,
        website,
        cover_image_url,
        hours,
        is_active,
        created_at
      )
    `)
    .eq("merchant_id", merchantId);
  if (error) throw error;
  return data;
}

export async function getMerchantDeals(merchantId: string) {
  const { data, error } = await supabase
    .from("deals")
    .select(`
      *,
      venues (name)
    `)
    .eq("merchant_id", merchantId)
    .order("created_at", { ascending: false });
  if (error) throw error;
  return data;
}

export async function getDealAnalytics(dealId: string) {
  const { data, error } = await supabase
    .from("deal_analytics")
    .select("*")
    .eq("deal_id", dealId)
    .order("date", { ascending: false })
    .limit(30);
  if (error) throw error;
  return data;
}

export async function getRedemptions(merchantId: string, limit = 50) {
  const { data, error } = await supabase
    .from("redemptions")
    .select(`
      *,
      deals (title, discount_type, discount_value),
      venues (name)
    `)
    .eq("merchant_id", merchantId)
    .order("redeemed_at", { ascending: false })
    .limit(limit);
  if (error) throw error;
  return data;
}
