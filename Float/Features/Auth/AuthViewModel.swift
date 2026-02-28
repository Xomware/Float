import SwiftUI

class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
}
