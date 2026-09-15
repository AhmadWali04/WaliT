import SwiftUI

@main
struct WaliTApp: App {
    // For POC: auth is mocked (Section 9.1) — any credentials succeed and set this flag.
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    NavigationStack {
                        ReceiptListView()
                    }
                } else {
                    LoginView()
                }
            }
        }
    }
}
