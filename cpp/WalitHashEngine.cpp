#include "WalitHashEngine.h"
#include "sha256.h"

#include <cstdio>
#include <cstring>
#include <sstream>

namespace WalitHashEngine {

std::string sha256Hex(const std::string& input) {
    using namespace detail;

    uint32_t state[8];
    std::memcpy(state, H0, sizeof(H0));

    const uint64_t bitLen = static_cast<uint64_t>(input.size()) * 8;

    // original bytes + 0x80 + zero padding + 8-byte big-endian bit length,
    // padded so the total length is a multiple of 64 bytes.
    std::vector<uint8_t> padded(input.begin(), input.end());
    padded.push_back(0x80);
    while (padded.size() % 64 != 56) {
        padded.push_back(0x00);
    }
    for (int i = 7; i >= 0; --i) {
        padded.push_back(static_cast<uint8_t>((bitLen >> (i * 8)) & 0xFF));
    }

    for (size_t offset = 0; offset < padded.size(); offset += 64) {
        transform(state, padded.data() + offset);
    }

    static const char* hexDigits = "0123456789abcdef";
    std::string digest;
    digest.reserve(64);
    for (int i = 0; i < 8; ++i) {
        for (int shift = 24; shift >= 0; shift -= 8) {
            uint8_t byte = static_cast<uint8_t>((state[i] >> shift) & 0xFF);
            digest.push_back(hexDigits[byte >> 4]);
            digest.push_back(hexDigits[byte & 0x0F]);
        }
    }
    return digest;
}

namespace {

std::string escapeJson(const std::string& s) {
    std::string out;
    out.reserve(s.size());
    for (char c : s) {
        switch (c) {
            case '"': out += "\\\""; break;
            case '\\': out += "\\\\"; break;
            default: out += c;
        }
    }
    return out;
}

std::string formatAmount(double amount) {
    char buf[64];
    std::snprintf(buf, sizeof(buf), "%.2f", amount);
    return std::string(buf);
}

std::string serializeLineItems(const std::vector<LineItem>& lineItems) {
    std::ostringstream out;
    out << '[';
    for (size_t i = 0; i < lineItems.size(); ++i) {
        const auto& item = lineItems[i];
        if (i > 0) out << ',';
        out << "{\"name\":\"" << escapeJson(item.name)
            << "\",\"description\":\"" << escapeJson(item.description)
            << "\",\"amount\":" << formatAmount(item.amount) << '}';
    }
    out << ']';
    return out.str();
}

} // namespace

std::string hash(const std::string& receiptJSON) {
    return sha256Hex(receiptJSON);
}

std::string computeBlockHash(int blockIndex,
                              const std::string& timestamp,
                              const std::vector<LineItem>& lineItems,
                              double total,
                              const std::string& previousHash,
                              uint64_t nonce) {
    std::ostringstream canonical;
    canonical << blockIndex << timestamp << serializeLineItems(lineItems)
              << formatAmount(total) << previousHash << nonce;
    return hash(canonical.str());
}

ValidationResult validateChain(const std::vector<Block>& blocks) {
    for (size_t i = 0; i < blocks.size(); ++i) {
        const Block& block = blocks[i];

        const std::string expectedPreviousHash =
            (i == 0) ? std::string(GENESIS_PREVIOUS_HASH) : blocks[i - 1].blockHash;
        if (block.previousHash != expectedPreviousHash) {
            return ValidationResult{false, static_cast<int>(i)};
        }

        const std::string recomputedHash = computeBlockHash(
            block.blockIndex, block.timestamp, block.lineItems,
            block.total, block.previousHash, block.nonce);
        if (recomputedHash != block.blockHash) {
            return ValidationResult{false, static_cast<int>(i)};
        }
    }
    return ValidationResult{true, -1};
}

} // namespace WalitHashEngine
