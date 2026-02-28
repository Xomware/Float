import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: FloatSpacing.lg) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(FloatColors.primary)
                Text("Sign in to see your profile")
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.textSecondary)
                FloatButton("Sign In") { }
                    .padding(.horizontal, FloatSpacing.xl)
            }
            .floatScreenBackground()
            .navigationTitle("Profile")
        }
    }
}
