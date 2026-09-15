import Foundation
import WalitHashEngine

// Swift-facing wrapper around the C++ WalitHashEngine (via Swift's native C++ interop,
// see Package.swift) so the rest of the app never spells out std::vector/std::string directly.
enum HashingService {
    static let genesisPreviousHash = String(cString: WalitHashEngine.GENESIS_PREVIOUS_HASH)

    static func computeBlockHash(blockIndex: Int, timestamp: String, lineItems: [LineItem],
                                  total: Double, previousHash: String, nonce: Int) -> String {
        var cxxItems = WalitHashEngine.makeLineItemVector()
        for item in lineItems {
            var cxxItem = WalitHashEngine.LineItem()
            cxxItem.name = std.string(item.name)
            cxxItem.description = std.string(item.description)
            cxxItem.amount = item.amount
            cxxItems.push_back(cxxItem)
        }

        let digest = WalitHashEngine.computeBlockHash(
            Int32(blockIndex), std.string(timestamp), cxxItems, total,
            std.string(previousHash), UInt64(nonce))
        return String(digest)
    }

    static func validateChain(_ blocks: [Block]) -> (isValid: Bool, firstInvalidIndex: Int?) {
        var cxxChain = WalitHashEngine.makeBlockVector()
        for block in blocks {
            var cxxItems = WalitHashEngine.makeLineItemVector()
            for item in block.lineItems {
                var cxxItem = WalitHashEngine.LineItem()
                cxxItem.name = std.string(item.name)
                cxxItem.description = std.string(item.description)
                cxxItem.amount = item.amount
                cxxItems.push_back(cxxItem)
            }

            var cxxBlock = WalitHashEngine.Block()
            cxxBlock.blockIndex = Int32(block.blockIndex)
            cxxBlock.timestamp = std.string(block.timestamp)
            cxxBlock.lineItems = cxxItems
            cxxBlock.total = block.total
            cxxBlock.previousHash = std.string(block.previousHash)
            cxxBlock.nonce = UInt64(block.nonce)
            cxxBlock.blockHash = std.string(block.blockHash)
            cxxChain.push_back(cxxBlock)
        }

        let result = WalitHashEngine.validateChain(cxxChain)
        return (result.isValid, result.isValid ? nil : Int(result.firstInvalidIndex))
    }
}
