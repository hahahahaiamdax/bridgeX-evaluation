// Copyright (c) 2020 Oxford-Hainan Blockchain Research Institute
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#pragma once
#include "memory"
#include "vector"
namespace eevm
{

class AbstractStateEncryptor
{
 public:
    virtual ~AbstractStateEncryptor() {}
    virtual bool encrypt(const std::vector<uint8_t>& plain, std::vector<uint8_t>& serialised_cipher) = 0;

    virtual bool decrypt(const std::vector<uint8_t>& serial_cipher, std::vector<uint8_t>& plain) = 0;
};

using EncryptorPtr = std::shared_ptr<AbstractStateEncryptor>;
} // end namespace eevm
