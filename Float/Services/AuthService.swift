import SwiftUI
import Supabase
import AuthenticationServices
import OSLog
import CommonCrypto

private let logger = Logger(subsystem: "com.xomware.float", category: "Auth")

@MainActor
final class AuthService: ObservableObject {
    
    // MARK: - Published State
    @Published var session: Session?
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var authError: String?
    @Published var needsOnboarding = false
    
    var isAuthenticated: Bool { session != nil }
    var currentUser: User? { session?.user }
    
    private let supabase = SupabaseClientService.shared.client
    
    // MARK: - Init
    init() {
        Task { await listenToAuthChanges() }
    }
    
    // MARK: - Auth State Listener
    func listenToAuthChanges() async {
        for await (event, session) in supabase.auth.authStateChanges {
            logger.info("Auth state change: \(event.rawValue)")
            self.session = session
            
            switch event {
            case .signedIn:
                await fetchOrCreateProfile()
            case .signedOut:
                userProfile = nil
                needsOnboarding = false
            case .tokenRefreshed:
                break
            default:
                break
            }
        }
    }
    
    // MARK: - Sign In with Apple
    func signInWithApple() async {
        isLoading = true
        authError = nil
        defer { isLoading = false }
        
        do {
            let helper = SignInWithAppleHelper()
            let result = try await helper.signIn()
            
            let session = try await supabase.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: result.idToken,
                    nonce: result.nonce
                )
            )
            self.session = session
            logger.info("Signed in with Apple: \(session.user.id)")
        } catch {
            authError = error.localizedDescription
            logger.error("Apple sign-in failed: \(error)")
        }
    }
    
    // MARK: - Sign In with Google
    func signInWithGoogle() async {
        isLoading = true
        authError = nil
        defer { isLoading = false }
        
        do {
            try await supabase.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "com.xomware.float://login-callback")
            )
            logger.info("Google OAuth initiated")
        } catch {
            authError = error.localizedDescription
            logger.error("Google sign-in failed: \(error)")
        }
    }
    
    // MARK: - Email Auth
    func signInWithEmail(email: String, password: String) async {
        isLoading = true
        authError = nil
        defer { isLoading = false }
        
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            self.session = session
            logger.info("Signed in with email: \(email)")
        } catch {
            authError = mapAuthError(error)
            logger.error("Email sign-in failed: \(error)")
        }
    }
    
    func signUpWithEmail(email: String, password: String) async {
        isLoading = true
        authError = nil
        defer { isLoading = false }
        
        do {
            let response = try await supabase.auth.signUp(email: email, password: password)
            self.session = response.session
            logger.info("Signed up with email: \(email)")
        } catch {
            authError = mapAuthError(error)
            logger.error("Email sign-up failed: \(error)")
        }
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        authError = nil
        defer { isLoading = false }
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            logger.info("Password reset email sent to: \(email)")
        } catch {
            authError = error.localizedDescription
            logger.error("Password reset failed: \(error)")
        }
    }
    
    // MARK: - Sign Out
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            session = nil
            userProfile = nil
            logger.info("Signed out")
        } catch {
            logger.error("Sign out failed: \(error)")
        }
    }
    
    // MARK: - Profile
    func fetchOrCreateProfile() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            let profile: UserProfile = try await supabase
                .from("user_profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            self.userProfile = profile
            self.needsOnboarding = profile.username == nil || profile.displayName == nil
            logger.info("Fetched profile for: \(userId)")
        } catch {
            // Profile may not exist yet (trigger handles creation, but can race)
            logger.warning("Profile fetch failed, will retry: \(error)")
            needsOnboarding = true
        }
    }
    
    func updateProfile(username: String, displayName: String, avatarUrl: String? = nil) async throws {
        guard let userId = currentUser?.id else { throw AuthError.notAuthenticated }
        
        struct ProfileUpdate: Encodable {
            let username: String
            let displayName: String
            let avatarUrl: String?
            enum CodingKeys: String, CodingKey {
                case username; case displayName = "display_name"; case avatarUrl = "avatar_url"
            }
        }
        
        try await supabase
            .from("user_profiles")
            .update(ProfileUpdate(username: username, displayName: displayName, avatarUrl: avatarUrl))
            .eq("id", value: userId.uuidString)
            .execute()
        
        await fetchOrCreateProfile()
        needsOnboarding = false
    }
    
    // MARK: - Helpers
    private func mapAuthError(_ error: Error) -> String {
        let msg = error.localizedDescription.lowercased()
        if msg.contains("invalid login") { return "Incorrect email or password." }
        if msg.contains("email not confirmed") { return "Please check your email and confirm your account." }
        if msg.contains("user already registered") { return "An account with this email already exists." }
        if msg.contains("password") { return "Password must be at least 6 characters." }
        return error.localizedDescription
    }
    
    enum AuthError: LocalizedError {
        case notAuthenticated
        var errorDescription: String? { "You must be signed in to do that." }
    }
}

// MARK: - Apple Sign In Helper
struct AppleSignInResult {
    let idToken: String
    let nonce: String
}

@MainActor
final class SignInWithAppleHelper: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    nonisolated(unsafe) private var continuation: CheckedContinuation<AppleSignInResult, Error>?
    private let nonce = UUID().uuidString
    
    func signIn() async throws -> AppleSignInResult {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = nonce.sha256
            
            let authController = ASAuthorizationController(authorizationRequests: [request])
            authController.delegate = self
            authController.presentationContextProvider = self
            authController.performRequests()
        }
    }
    
    // swiftlint:disable:next line_length
nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else {
            let error = NSError(
                domain: "AppleSignIn", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to get Apple ID token"]
            )
            continuation?.resume(throwing: error)
            return
        }
        continuation?.resume(returning: AppleSignInResult(idToken: idToken, nonce: nonce))
    }
    
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
    
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

private extension String {
    var sha256: String {
        let data = Data(self.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash) }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
