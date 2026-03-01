// SupabaseService.swift
// Float

import Foundation

// Supabase client — initialized in FloatApp.swift after config loading
// Full implementation in ticket 3 (auth branch)
enum SupabaseConfig {
    static var url: String { Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? "" }
    static var anonKey: String { Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? "" }
}
