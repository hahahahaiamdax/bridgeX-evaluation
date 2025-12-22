// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once
#include "bigint.h"
#include "util.h"

namespace eevm
{
    /**
     * An Ethereum block descriptor; in particular, this is used to parse
     * cpp-ethereum test cases.
     */
    struct Block
    {
        uint64_t number, gas_limit, timestamp;
        uint256_t coinbase, prev_randao, chain_id, base_fee;
    };

    inline bool operator==(const Block& l, const Block& r)
    {
        return l.coinbase == r.coinbase && l.number == r.number && l.prev_randao == r.prev_randao &&
          l.gas_limit == r.gas_limit && l.timestamp == r.timestamp && l.chain_id == r.chain_id &&
          l.base_fee == r.base_fee;
    }

    inline void from_json(const nlohmann::json& j, Block& b)
    {
        b.number = to_uint64(j["currentNumber"]);
        b.prev_randao = to_uint256(j["currentPrevRandao"]);
        b.gas_limit = to_uint64(j["currentGasLimit"]);
        b.timestamp = to_uint64(j["currentTimestamp"]);
        b.coinbase = to_uint256(j["currentCoinbase"]);
        b.chain_id = to_uint256(j["currentChainId"]);
        b.base_fee = to_uint256(j["currentBaseFee"]);
    }

    inline void to_json(nlohmann::json& j, const Block& b)
    {
        j["currentNumber"] = to_hex_string(b.number);
        j["currentPrevRandao"] = to_hex_string(b.prev_randao);
        j["currentGasLimit"] = to_hex_string(b.gas_limit);
        j["currentTimestamp"] = to_hex_string(b.timestamp);
        j["currentCoinbase"] = to_hex_string(b.coinbase);
        j["currentChainId"] = to_hex_string(b.chain_id);
        j["currentBaseFee"] = to_hex_string(b.base_fee);
    }
} // namespace eevm
