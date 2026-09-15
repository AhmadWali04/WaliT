import XCTest
import WalitHashEngine

final class WalitHashEngineSwiftTests: XCTestCase {

    func testHashKnownVector() {
        let digest = String(WalitHashEngine.hash(std.string("abc")))
        XCTAssertEqual(digest, "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
    }

    func testValidateChainDetectsTamperedBlock() {
        func makeBlock(index: Int32, timestamp: String, items: [(String, String, Double)],
                        total: Double, previousHash: String, nonce: UInt64) -> WalitHashEngine.Block {
            var cxxItems = WalitHashEngine.makeLineItemVector()
            for (name, description, amount) in items {
                var item = WalitHashEngine.LineItem()
                item.name = std.string(name)
                item.description = std.string(description)
                item.amount = amount
                cxxItems.push_back(item)
            }

            let blockHash = WalitHashEngine.computeBlockHash(
                index, std.string(timestamp), cxxItems, total, std.string(previousHash), nonce)

            var block = WalitHashEngine.Block()
            block.blockIndex = index
            block.timestamp = std.string(timestamp)
            block.lineItems = cxxItems
            block.total = total
            block.previousHash = std.string(previousHash)
            block.nonce = nonce
            block.blockHash = blockHash
            return block
        }

        let genesis = makeBlock(
            index: 0, timestamp: "2026-09-14T15:00:00Z",
            items: [("Pour Over - Ethiopia", "Single Origin, Light Roast", 6.50)],
            total: 6.50, previousHash: String(cString: WalitHashEngine.GENESIS_PREVIOUS_HASH), nonce: 0)

        let second = makeBlock(
            index: 1, timestamp: "2026-09-14T15:05:00Z",
            items: [("Almond Croissant", "Freshly Baked", 5.25)],
            total: 5.25, previousHash: String(genesis.blockHash), nonce: 0)

        var chain = WalitHashEngine.makeBlockVector()
        chain.push_back(genesis)
        chain.push_back(second)

        let validResult = WalitHashEngine.validateChain(chain)
        XCTAssertTrue(validResult.isValid)
        XCTAssertEqual(validResult.firstInvalidIndex, -1)

        // Simulate someone editing a block directly in the database without recomputing its hash.
        var tampered = chain
        tampered[1].total = 999.99

        let tamperedResult = WalitHashEngine.validateChain(tampered)
        XCTAssertFalse(tamperedResult.isValid)
        XCTAssertEqual(tamperedResult.firstInvalidIndex, 1)
    }
}
