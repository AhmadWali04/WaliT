import Foundation

// One block in the receipt chain, as stored/returned by the backend `receipts` collection.
struct Block: Codable, Identifiable, Hashable {
    var id: String { mongoId ?? blockHash }

    let mongoId: String?
    let blockIndex: Int
    let timestamp: String
    let transactionId: String
    let merchant: Merchant
    let lineItems: [LineItem]
    let subtotal: Double
    let tax: Double
    let total: Double
    let paymentMethod: String
    let blockHash: String
    let previousHash: String
    let nonce: Int

    enum CodingKeys: String, CodingKey {
        case mongoId = "_id"
        case blockIndex, timestamp, transactionId, merchant, lineItems
        case subtotal, tax, total, paymentMethod, blockHash, previousHash, nonce
    }
}

// Body of a POST /receipts request (Section 8) — same shape as Block minus the server-assigned _id.
struct NewBlockPayload: Codable {
    let blockIndex: Int
    let timestamp: String
    let transactionId: String
    let merchant: Merchant
    let lineItems: [LineItem]
    let subtotal: Double
    let tax: Double
    let total: Double
    let paymentMethod: String
    let blockHash: String
    let previousHash: String
    let nonce: Int
}

struct ChainVerification: Codable {
    let valid: Bool
    let firstInvalidIndex: Int?
}
