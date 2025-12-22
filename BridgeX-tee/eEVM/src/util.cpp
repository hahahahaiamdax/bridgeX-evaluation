// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "eEVM/util.h"

#include "eEVM/rlp.h"

#include <iomanip>

using namespace std;

namespace eevm
{
    string strip(const string& s)
    {
        return (s.size() >= 2 && s[1] == 'x') ? s.substr(2) : s;
    }

    uint64_t to_uint64(const std::string& s)
    {
        return strtoull(s.c_str(), nullptr, 16);
    }

    vector<uint8_t> to_bytes(const string& _s)
    {
        auto s = strip(_s);

        const size_t byte_len = (s.size() + 1) / 2; // round up
        vector<uint8_t> v(byte_len);

        // Handle odd-length strings
        size_t n = 0;
        if (s.size() % 2 != 0)
        {
            v[0] = static_cast<uint8_t>(strtoul(s.substr(0, 1).c_str(), nullptr, 16));
            ++n;
        }

        auto x = n;
        for (auto i = n; i < byte_len; ++i, x += 2)
        {
            v[i] = static_cast<uint8_t>(strtoul(s.substr(x, 2).c_str(), nullptr, 16));
        }
        return v;
    }

    Address generate_address(const Address& sender, uint64_t nonce)
    {
        const auto rlp_encoding = rlp::encode(sender, nonce);
        return from_big_endian(Keccak256(rlp_encoding).data() + 12u, 20u);
    }

    Address generate_address_for_create2(const Address& sender, const uint256_t& salt, const std::vector<uint8_t>& init_code)
    {
        vector<uint8_t> data;
        data.emplace_back(static_cast<uint8_t>(strtoul("ff", nullptr, 16))); 
        uint8_t sender_arr[256];
        to_big_endian(sender, sender_arr);
        for (auto i = 0; i < 256; i++)
        {
            data.emplace_back(sender_arr[i]);
        }

        uint8_t salt_arr[256];
        to_big_endian(salt, salt_arr);
        for (auto i = 0; i < 256; i++)
        {
            data.emplace_back(salt_arr[i]);
        }
        
        const auto init_code_hash = Keccak256(init_code).HashBytes();
        data.insert(data.end(), init_code_hash.begin(), init_code_hash.end());

        return from_big_endian(Keccak256(data).data() + 12u, 20u);
    }

    uint256_t to_uint256(const uint8_t* data, size_t size, bool needHash)
    {
        if (needHash)
            return from_big_endian(Keccak256(data, size).data(), 32u);
        return from_big_endian(data, size);
    }

} // namespace eevm
