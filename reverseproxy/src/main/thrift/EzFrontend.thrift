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

namespace * ezbake.frontend.thrift
namespace py ezbake.frontend.thriftapi
namespace go ezbake.frontend.thriftapi

include "EzReverseProxy.thrift"

struct ServerCertInfo {
    1: string certificateContents;
    2: string keyContents;
}

exception EzFrontendCertException {
    1: string message;
}

service EzFrontendService extends EzReverseProxy.EzReverseProxy {
    void addServerCerts(1: string serverName, 2: ServerCertInfo info) throws (1: EzFrontendCertException error);
    void removeServerCerts(1: string serverName) throws (1: EzFrontendCertException error);
    bool isServerCertPresent(1: string serverName);
}

