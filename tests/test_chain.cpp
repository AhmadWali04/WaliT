#include "WalitHashEngine.h"

#include <cassert>
#include <iostream>
#include <utility>

using namespace WalitHashEngine;

namespace {

Block makeBlock(int index, const std::string& timestamp,
                 std::vector<LineItem> items, double total,
                 const std::string& previousHash, uint64_t nonce) {
    Block block;
    block.blockIndex = index;
    block.timestamp = timestamp;
    block.lineItems = std::move(items);
    block.total = total;
    block.previousHash = previousHash;
    block.nonce = nonce;
    block.blockHash = computeBlockHash(index, timestamp, block.lineItems, total, previousHash, nonce);
    return block;
}

} // namespace

int main() {
    Block genesis = makeBlock(0, "2026-09-14T15:00:00Z",
                               {{"Pour Over - Ethiopia", "Single Origin, Light Roast", 6.50}},
                               6.50, GENESIS_PREVIOUS_HASH, 0);

    Block second = makeBlock(1, "2026-09-14T15:05:00Z",
                              {{"Almond Croissant", "Freshly Baked", 5.25}},
                              5.25, genesis.blockHash, 0);

    Block third = makeBlock(2, "2026-09-14T15:10:00Z",
                             {{"Oat Milk Latte", "Large 16oz", 7.00}},
                             7.00, second.blockHash, 0);

    std::vector<Block> chain = {genesis, second, third};

    ValidationResult result = validateChain(chain);
    assert(result.isValid);
    assert(result.firstInvalidIndex == -1);

    // Simulate someone editing a block directly in MongoDB without recomputing its hash.
    std::vector<Block> tampered = chain;
    tampered[1].total = 999.99;

    ValidationResult tamperedResult = validateChain(tampered);
    assert(!tamperedResult.isValid);
    assert(tamperedResult.firstInvalidIndex == 1);

    // A break in the previousHash link (e.g. reordered/spliced blocks) should also be caught.
    std::vector<Block> brokenLink = chain;
    brokenLink[2].previousHash = "deadbeef";

    ValidationResult brokenLinkResult = validateChain(brokenLink);
    assert(!brokenLinkResult.isValid);
    assert(brokenLinkResult.firstInvalidIndex == 2);

    std::cout << "chain validation: OK\n";
    return 0;
}
