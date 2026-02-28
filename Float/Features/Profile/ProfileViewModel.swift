import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var username: String = ""
    @Published var totalRedemptions: Int = 0
    @Published var totalSavings: Double = 0
}
