import Foundation

// Stands in for the Stripe Terminal SDK's simulated-reader lifecycle (Section 7).
// The real SDK requires a live (test-mode) Stripe account for connection tokens even in
// simulated mode, so until that's wired up, this reproduces the same end result — a
// completed payment mapped to a receipt — without a live network call.
final class StripeService {
    static let shared = StripeService()

    func simulateTapToPay() async throws -> Receipt {
        // Mirrors the SDK's connect -> ready -> collect -> process lifecycle timing.
        try await Task.sleep(nanoseconds: 700_000_000)

        let template = MockReceiptFactory.randomReceipt()
        let subtotal = template.lineItems.reduce(0) { $0 + $1.amount }
        let tax = (subtotal * 0.085).roundedToCents
        let total = (subtotal + tax).roundedToCents

        return Receipt(
            transactionId: "TRX-\(Int.random(in: 1000...9999))",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            merchant: template.merchant,
            lineItems: template.lineItems,
            subtotal: subtotal,
            tax: tax,
            total: total,
            paymentMethod: MockReceiptFactory.paymentMethod
        )
    }
}

private extension Double {
    var roundedToCents: Double {
        (self * 100).rounded() / 100
    }
}
