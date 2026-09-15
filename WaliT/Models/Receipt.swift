import Foundation

struct LineItem: Codable, Identifiable, Hashable {
    var id: String { name + description }
    let name: String
    let description: String
    let amount: Double
}

enum ReceiptCategory: String, Codable, CaseIterable {
    case groceries = "Groceries"
    case dining = "Dining"
    case transport = "Transport"
    case electronics = "Electronics"
    case health = "Health"
}

struct Merchant: Codable, Hashable {
    let name: String
    let address: String
    let category: ReceiptCategory
}

// A freshly-captured receipt, before it's been hashed and posted to the chain.
struct Receipt: Codable, Hashable {
    let transactionId: String
    let timestamp: String
    let merchant: Merchant
    let lineItems: [LineItem]
    let subtotal: Double
    let tax: Double
    let total: Double
    let paymentMethod: String
}
