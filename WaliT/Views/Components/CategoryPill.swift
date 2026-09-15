import SwiftUI

struct CategoryPill: View {
    let category: ReceiptCategory

    var body: some View {
        Text(category.rawValue)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Theme.categoryColor(for: category).opacity(0.18))
            .foregroundColor(Theme.categoryColor(for: category))
            .clipShape(Capsule())
    }
}
