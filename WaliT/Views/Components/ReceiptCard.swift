import SwiftUI

struct ReceiptCard: View {
    let block: Block

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(white: 0.93))
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(block.merchant.name)
                    .font(.body.weight(.semibold))
                Text(block.displayDateTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(block.total, format: .currency(code: "USD"))
                    .font(.body.weight(.bold))
                CategoryPill(category: block.merchant.category)
            }
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    private var iconName: String {
        switch block.merchant.category {
        case .groceries: return "cart.fill"
        case .dining: return "cup.and.saucer.fill"
        case .transport: return "bus.fill"
        case .electronics: return "bolt.fill"
        case .health: return "cross.case.fill"
        }
    }
}

extension Block {
    var displayDateTime: String {
        guard let date = ISO8601DateFormatter().date(from: timestamp) else { return timestamp }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
