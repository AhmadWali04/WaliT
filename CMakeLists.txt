cmake_minimum_required(VERSION 3.16)
project(WalitHashEngine CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(walit_hash_engine STATIC cpp/WalitHashEngine.cpp)
target_include_directories(walit_hash_engine PUBLIC cpp)

enable_testing()

add_executable(test_sha256 tests/test_sha256.cpp)
target_link_libraries(test_sha256 walit_hash_engine)
add_test(NAME sha256_vectors COMMAND test_sha256)

add_executable(test_chain tests/test_chain.cpp)
target_link_libraries(test_chain walit_hash_engine)
add_test(NAME chain_validation COMMAND test_chain)
