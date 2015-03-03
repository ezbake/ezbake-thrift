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

namespace * ezbake.data.base.thrift
namespace py ezbake.data.base.thriftapi
namespace go ezbake.data.base.thriftapi

include "EzBakeBase.thrift"

struct PurgeResult {
    1: required bool isFinished
    2: optional set<i64> purged;
    3: optional set<i64> unpurged;
}

struct PurgeItems {
    1: required set<i64> items
    2: optional i64 purgeId
}

struct PurgeOptions {
    1: optional i32 batchSize
}

service BaseDataService extends EzBakeBase.EzBakeBaseService {
    PurgeResult purge(1: PurgeItems items, 2: PurgeOptions options, 3: EzBakeBase.EzSecurityToken token);
    EzBakeBase.CancelStatus cancelPurge(1: i64 purgeId, 2: EzBakeBase.EzSecurityToken token);
}
