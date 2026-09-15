import Foundation

@MainActor
final class ReceiptListViewModel: ObservableObject {
    @Published var blocks: [Block] = []
    @Published var isLoading = false
    @Published var isScanning = false
    @Published var errorMessage: String?

    private let api = ReceiptAPIService.shared

    func loadReceipts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            blocks = try await api.fetchReceipts()
            errorMessage = nil
        } catch {
            errorMessage = "Couldn't reach the WaliT API. Is the backend running on localhost:3000?"
        }
    }

    func scanReceipt() async {
        isScanning = true
        defer { isScanning = false }
        do {
            let receipt = try await StripeService.shared.simulateTapToPay()

            let nextIndex = (blocks.map(\.blockIndex).max().map { $0 + 1 }) ?? 0
            let previousHash = blocks.first(where: { $0.blockIndex == nextIndex - 1 })?.blockHash
                ?? HashingService.genesisPreviousHash

            let blockHash = HashingService.computeBlockHash(
                blockIndex: nextIndex, timestamp: receipt.timestamp, lineItems: receipt.lineItems,
                total: receipt.total, previousHash: previousHash, nonce: 0)
            print("WaliT C++ engine computed block hash:", blockHash)

            let payload = NewBlockPayload(
                blockIndex: nextIndex, timestamp: receipt.timestamp, transactionId: receipt.transactionId,
                merchant: receipt.merchant, lineItems: receipt.lineItems, subtotal: receipt.subtotal,
                tax: receipt.tax, total: receipt.total, paymentMethod: receipt.paymentMethod,
                blockHash: blockHash, previousHash: previousHash, nonce: 0)

            let created = try await api.postReceipt(payload)
            blocks.append(created)
            errorMessage = nil
        } catch {
            errorMessage = "Scan failed: \(error.localizedDescription)"
        }
    }
}
