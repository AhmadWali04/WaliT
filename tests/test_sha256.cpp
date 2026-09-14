#include "WalitHashEngine.h"

#include <cassert>
#include <iostream>

int main() {
    using WalitHashEngine::hash;

    assert(hash("") == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
    assert(hash("abc") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
    assert(hash("The quick brown fox jumps over the lazy dog") ==
           "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592");

    std::cout << "sha256 vectors: OK\n";
    return 0;
}
