/*   Copyright (C) 2013-2014 Computer Sciences Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License. */

namespace * ezbake.security.lock.smith.thrift
namespace py ezbake.security.lock.smith.thriftapi
namespace go ezbake.security.lock.smith.thriftapi

include "EzBakeBase.thrift"

typedef EzBakeBase.EzSecurityToken EzSecurityToken

enum KeyType {
    RSA,
    AES
}

exception KeyExistsException {
    1: string msg
}

exception KeyNotFoundException {
    1: string msg
}

const string SERVICE_NAME = "locksmith";

service EzLocksmith extends EzBakeBase.EzBakeBaseService {
    void generateKey(
        1: required EzSecurityToken ezToken,
        2: required string keyId,
        3: required KeyType type,
        4: list<string> sharedWith) throws (
            1: KeyExistsException keyExistsException,
            2: EzBakeBase.EzSecurityTokenException tokenException);

    void uploadKey(
        1: required EzSecurityToken ezToken,
        2: required string keyId,
        3: required string keyData,
        4: required KeyType type) throws (
            1: KeyExistsException keyExistsException,
            2: EzBakeBase.EzSecurityTokenException tokenException);

    string retrieveKey(
        1: required EzSecurityToken ezToken,
        2: required string id,
        3: required KeyType type) throws (
            1: KeyNotFoundException keyNotFoundException,
            2: KeyExistsException keyExistsException,
            3: EzBakeBase.EzSecurityTokenException tokenException);

    void removeKey(
        1: required EzSecurityToken ezToken,
        2: required string id,
        3: required KeyType type) throws (
            1: KeyNotFoundException keyNotFoundException,
            2: EzBakeBase.EzSecurityTokenException tokenException);

    string retrievePublicKey(
        1: required EzSecurityToken ezToken,
        2: required string id,
        3: string owner) throws (
            1: KeyNotFoundException keyNotFoundException,
            2: EzBakeBase.EzSecurityTokenException tokenException);
}
