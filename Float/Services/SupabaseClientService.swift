// SupabaseClientService.swift
// Float

import Supabase
import Foundation

/// Singleton Supabase client — initialized once at app launch
final class SupabaseClientService {
    static let shared = SupabaseClientService()
    
    let client: SupabaseClient
    
    private init() {
        guard
            let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
            let url = URL(string: urlString),
            let anonKey = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String
        else {
            fatalError("[Float] Missing SUPABASE_URL or SUPABASE_ANON_KEY in Info.plist")
        }
        client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
    }
}
