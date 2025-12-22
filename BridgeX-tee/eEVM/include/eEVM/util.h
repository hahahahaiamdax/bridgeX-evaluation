// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include "address.h"
#include "keccak256.h"

#define FMT_HEADER_ONLY
#include <fmt/format.h>
#include <iomanip>
#include <limits>
#include <nlohmann/json.hpp>
#include <sstream>
#include <vector>
namespace eevm
{
inline auto from_big_endian(const uint8_t* begin, size_t size = 32u)
{
    if (size == 32) {
        return intx::be::unsafe::load<uint256_t>(begin);
    } else if (size > 32) {
        throw std::logic_error("Calling from_big_endian with oversized array");
    } else {
        // TODO: Find out how common this path is, make it the caller's
        // responsibility
        uint8_t tmp[32] = {};
        const auto offset = 32 - size;
        memcpy(tmp + offset, begin, size);

        return intx::be::load<uint256_t>(tmp);
    }
}

inline void to_big_endian(const uint256_t& v, uint8_t* out)
{
    // TODO: Is this cast safe?
    // uint8_t(&arr)[32] =
    // *static_cast<uint8_t(*)[32]>(static_cast<void*>(out));
    intx::be::unsafe::store(out, v);
}

std::string strip(const std::string& s);
std::vector<uint8_t> to_bytes(const std::string& s);

template <typename Iterator>
std::string to_hex_string(Iterator begin, Iterator end)
{
    return fmt::format("0x{:02x}", fmt::join(begin, end, ""));
}

template <size_t N>
std::string to_hex_string(const std::array<uint8_t, N>& bytes)
{
    return to_hex_string(bytes.begin(), bytes.end());
}

inline std::string to_hex_string(const std::vector<uint8_t>& bytes)
{
    return to_hex_string(bytes.begin(), bytes.end());
}

inline std::string to_hex_string(uint64_t v)
{
    return fmt::format("0x{:x}", v);
}

inline std::string to_hex_string(const uint256_t& v)
{
    return fmt::format("0x{}", intx::hex(v));
}

inline std::string to_hex_string_fixed(const uint256_t& v, size_t min_hex_chars = 64)
{
    return fmt::format("0x{:0>{}}", intx::hex(v), min_hex_chars);
}

inline auto address_to_hex_string(const Address& v)
{
    return to_hex_string_fixed(v, 40);
}

template <typename T>
std::string to_lower_hex_string(const T& v)
{
    auto s = to_hex_string(v);
    std::transform(s.begin(), s.end(), s.begin(), ::tolower);
    return s;
}

inline uint256_t to_uint256(const std::string& s)
{
    return intx::from_string<uint256_t>(s);
}

uint256_t to_uint256(const uint8_t* data, size_t size, bool needHash = true);

inline std::string to_checksum_address(const Address& a)
{
    auto s = address_to_hex_string(a);

    // Start at index 2 to skip the "0x" prefix
    const auto h = Keccak256::from_skip(s, 2);

    for (size_t i = 0; i < s.size() - 2; ++i) {
        auto& c = s[i + 2];
        if (c >= 'a' && c <= 'f') {
            if (h.hash[i / 2] & (i % 2 == 0 ? 0x80 : 0x08)) {
                c = std::toupper(c);
            } else {
                c = std::tolower(c);
            }
        }
    }

    return s;
}

inline bool is_checksum_address(const std::string& s)
{
    const auto cs = to_checksum_address(to_uint256(s));
    return cs == s;
}

Address generate_address(const Address& sender, uint64_t nonce);
Address generate_address_for_create2(const Address& sender, const uint256_t& salt, const std::vector<uint8_t>& initcode);

uint64_t to_uint64(const std::string& s);

inline std::string parse_revert(const std::vector<uint8_t>& bin)
{
    if (bin.empty())
        return "";
    auto src = std::vector<uint8_t>(bin.begin() + 36, bin.end());
    auto offset = static_cast<uint64_t>(eevm::from_big_endian(src.data()));
    auto res = std::vector<uint8_t>(src.begin() + 32, src.begin() + 32 + offset);
    return {res.data(), res.data() + res.size()};
}
} // namespace eevm
