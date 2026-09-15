import SwiftUI

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text("WaliT")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.top, 60)

                    card
                        .padding(.horizontal, 20)

                    Label("END-TO-END ENCRYPTED ARCHITECTURE", systemImage: "lock.shield")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .padding(.bottom, 40)
                }
            }
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back")
                    .font(.title2.weight(.bold))
                Text("Enter your details to access your secure vault.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            labeledField(icon: "envelope", placeholder: "Email", text: $email, isEmail: true)

            HStack {
                Image(systemName: "lock").foregroundColor(.secondary)
                if isPasswordVisible {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
                }
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color(white: 0.96))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            ActionButton(title: "Login", style: .filled) {
                isLoggedIn = true
            }

            HStack(spacing: 8) {
                dividerLine
                Text("OR").font(.caption).foregroundColor(.secondary)
                dividerLine
            }

            HStack(spacing: 12) {
                ActionButton(title: "Biometric", style: .outlined) { isLoggedIn = true }
                ActionButton(title: "Passkey", style: .outlined) { isLoggedIn = true }
            }

            HStack(spacing: 4) {
                Spacer()
                Text("Don't have an account?")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text("Create account")
                    .font(.footnote.weight(.semibold))
                Spacer()
            }
        }
        .padding(20)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private var dividerLine: some View {
        Rectangle().fill(Color(white: 0.85)).frame(height: 1)
    }

    private func labeledField(icon: String, placeholder: String, text: Binding<String>, isEmail: Bool = false) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(.secondary)
            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .keyboardType(isEmail ? .emailAddress : .default)
        }
        .padding(12)
        .background(Color(white: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
