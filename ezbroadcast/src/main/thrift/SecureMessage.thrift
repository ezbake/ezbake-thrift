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

namespace * ezbake.ezbroadcast.core.thrift
namespace py ezbake.ezbroadcast.core.thriftapi
namespace go ezbake.ezbroadcast.core.thriftapi

include "EzBakeBase.thrift"

struct SecureMessage {
    1: required EzBakeBase.Visibility visibility;
    2: required binary content;
    3: optional binary key;
}
