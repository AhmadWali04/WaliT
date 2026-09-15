import Foundation

@MainActor
final class ReceiptDetailViewModel: ObservableObject {
    @Published var block: Block
    @Published var isVerified = true
    @Published var memo = ""

    init(block: Block) {
        self.block = block
    }

    // Calls WalitHashEngine.validateChain() on the full chain and checks whether this
    // block falls before the first broken link (Section 9.3).
    func verify(against chain: [Block]) {
        let result = HashingService.validateChain(chain)
        if let firstInvalidIndex = result.firstInvalidIndex {
            isVerified = block.blockIndex < firstInvalidIndex
        } else {
            isVerified = true
        }
    }
}
