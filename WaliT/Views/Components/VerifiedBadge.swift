import SwiftUI

struct VerifiedBadge: View {
    let isVerified: Bool

    var body: some View {
        Label(
            isVerified ? "Verified Digital Copy" : "Chain Integrity Failure",
            systemImage: isVerified ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
        )
        .font(.subheadline.weight(.semibold))
        .foregroundColor(isVerified ? Theme.verifiedGreen : Theme.flagRed)
    }
}
