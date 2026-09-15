#pragma once

#include <cstdint>
#include <string>
#include <vector>

namespace WalitHashEngine {

// Matches Section 5's genesis block rule: previousHash = "0000000000000000".
constexpr const char* GENESIS_PREVIOUS_HASH = "0000000000000000";

struct LineItem {
    std::string name;
    std::string description;
    double amount = 0.0;
};

// One block in the receipt chain (mirrors the MongoDB `receipts` document).
struct Block {
    int blockIndex = 0;
    std::string timestamp;
    std::vector<LineItem> lineItems;
    double total = 0.0;
    std::string previousHash;
    uint64_t nonce = 0;
    std::string blockHash;
};

struct ValidationResult {
    bool isValid = true;
    int firstInvalidIndex = -1; // -1 when the chain is valid
};

// Raw SHA-256 hex digest of `input`.
std::string sha256Hex(const std::string& input);

// Accepts a serialised receipt string and returns its hex digest.
std::string hash(const std::string& receiptJSON);

// Builds the canonical string per Section 5's chaining rule
// (blockIndex + timestamp + JSON(lineItems) + total + previousHash + nonce) and hashes it.
std::string computeBlockHash(int blockIndex,
                              const std::string& timestamp,
                              const std::vector<LineItem>& lineItems,
                              double total,
                              const std::string& previousHash,
                              uint64_t nonce);

// Walks the full chain, recomputing each block's hash and checking previousHash linkage.
// Returns the index of the first broken block, if any.
ValidationResult validateChain(const std::vector<Block>& blocks);

// Swift's C++ interop can't spell out std::vector<T> template instantiations directly;
// callers get a concretely-typed empty vector from these and push_back onto it instead.
std::vector<LineItem> makeLineItemVector();
std::vector<Block> makeBlockVector();

} // namespace WalitHashEngine
