export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export interface Database {
  public: {
    Tables: {
      merchants: {
        Row: {
          id: string;
          user_id: string;
          business_name: string;
          contact_email: string;
          contact_phone: string | null;
          logo_url: string | null;
          is_active: boolean;
          created_at: string;
          updated_at: string;
          notification_preferences: Json;
        };
        Insert: {
          user_id: string;
          business_name: string;
          contact_email: string;
          contact_phone?: string | null;
          logo_url?: string | null;
          is_active?: boolean;
          notification_preferences?: Json;
        };
        Update: {
          user_id?: string;
          business_name?: string;
          contact_email?: string;
          contact_phone?: string | null;
          logo_url?: string | null;
          is_active?: boolean;
          notification_preferences?: Json;
        };
        Relationships: [];
      };
      merchant_venues: {
        Row: {
          id: string;
          merchant_id: string;
          venue_id: string;
          role: "owner" | "manager" | "staff";
          created_at: string;
        };
        Insert: {
          merchant_id: string;
          venue_id: string;
          role?: "owner" | "manager" | "staff";
        };
        Update: {
          role?: "owner" | "manager" | "staff";
        };
        Relationships: [];
      };
      venues: {
        Row: {
          id: string;
          name: string;
          address: string;
          city: string;
          state: string;
          zip: string;
          phone: string | null;
          website: string | null;
          cover_image_url: string | null;
          hours: Json;
          is_active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          name: string;
          address: string;
          city: string;
          state: string;
          zip: string;
          phone?: string | null;
          website?: string | null;
          cover_image_url?: string | null;
          hours?: Json;
          is_active?: boolean;
        };
        Update: {
          name?: string;
          address?: string;
          city?: string;
          state?: string;
          zip?: string;
          phone?: string | null;
          website?: string | null;
          cover_image_url?: string | null;
          hours?: Json;
          is_active?: boolean;
        };
        Relationships: [];
      };
      deals: {
        Row: {
          id: string;
          merchant_id: string;
          venue_id: string;
          title: string;
          description: string | null;
          discount_type: "percentage" | "fixed" | "bogo" | "free_item";
          discount_value: number;
          start_time: string;
          end_time: string;
          recurrence: Json | null;
          max_redemptions: number | null;
          total_redemptions: number;
          is_active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          merchant_id: string;
          venue_id: string;
          title: string;
          description?: string | null;
          discount_type: "percentage" | "fixed" | "bogo" | "free_item";
          discount_value: number;
          start_time: string;
          end_time: string;
          recurrence?: Json | null;
          max_redemptions?: number | null;
          is_active?: boolean;
        };
        Update: {
          title?: string;
          description?: string | null;
          discount_type?: "percentage" | "fixed" | "bogo" | "free_item";
          discount_value?: number;
          start_time?: string;
          end_time?: string;
          recurrence?: Json | null;
          max_redemptions?: number | null;
          is_active?: boolean;
        };
        Relationships: [];
      };
      deal_analytics: {
        Row: {
          id: string;
          deal_id: string;
          date: string;
          views: number;
          redemptions: number;
          peak_hour: number | null;
          revenue_impact: number | null;
        };
        Insert: {
          deal_id: string;
          date: string;
          views?: number;
          redemptions?: number;
          peak_hour?: number | null;
          revenue_impact?: number | null;
        };
        Update: {
          views?: number;
          redemptions?: number;
          peak_hour?: number | null;
          revenue_impact?: number | null;
        };
        Relationships: [];
      };
      redemptions: {
        Row: {
          id: string;
          deal_id: string;
          venue_id: string;
          merchant_id: string;
          user_id: string;
          redeemed_at: string;
          discount_amount: number;
          status: "completed" | "pending" | "cancelled";
        };
        Insert: {
          deal_id: string;
          venue_id: string;
          merchant_id: string;
          user_id: string;
          discount_amount: number;
          status?: "completed" | "pending" | "cancelled";
        };
        Update: {
          status?: "completed" | "pending" | "cancelled";
        };
        Relationships: [];
      };
    };
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: Record<string, never>;
  };
}
