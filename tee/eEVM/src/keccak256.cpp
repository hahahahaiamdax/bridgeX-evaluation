
#include <eEVM/keccak256.h>
#include <eEVM/util.h>
// extern "C"
// {
#include "keccak/hash.h"
// }
namespace eevm
{
Keccak256::Keccak256(const uint8_t* data, size_t size)
{
    SHA3_CTX context;
    keccak_init(&context);
    keccak_update(&context, data, size);
    keccak_final(&context, hash.data());
}

Keccak256::Keccak256(const std::vector<uint8_t>& vec) : Keccak256(vec.data(), vec.size()) {}
Keccak256::Keccak256(const std::string& str) : Keccak256((const uint8_t*)str.data(), str.size()) {}

template <size_t N>
Keccak256::Keccak256(const std::array<uint8_t, N>& a) : Keccak256(a.data(), N)
{}

Keccak256 Keccak256::from_skip(const std::string& str, size_t skip)
{
    skip = std::min(skip, str.size());
    return Keccak256((const uint8_t*)str.data() + skip, str.size() - skip);
}

std::string Keccak256::hex_str() const
{
    return to_hex_string(hash);
}

Keccak256 Keccak256::from_hex(const std::string& str)
{
    Keccak256 digest;
    auto s = strip(str);
    if (s.empty())
        return digest;
    for (size_t i = 0, x = 0; i < 32; i++, x += 2) {
        digest.hash.at(i) = strtol(s.substr(x, 2).c_str(), 0, 16);
    }
    return digest;
}

Keccak256 Keccak256::from_hex(const std::vector<uint8_t>& data)
{
    Keccak256 digest;
    std::copy(data.begin(), data.end(), digest.hash.begin());
    return digest;
}

bool operator==(const Keccak256& lhs, const Keccak256& rhs)
{
    for (unsigned i = 0; i < Keccak256::SIZE; i++) {
        if (lhs.hash[i] != rhs.hash[i]) {
            return false;
        }
    }
    return true;
}

void to_json(nlohmann::json& j, const Keccak256& hash)
{
    j = hash.hex_str();
}

void from_json(const nlohmann::json& j, Keccak256& hash)
{
    auto value = j.get<std::string>();
    hash = Keccak256::from_hex(value);
}
}
