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

namespace * ezbake.discovery.stethoscope.thrift
namespace py ezbake.discovery.stethoscope.thriftapi

include "EzBakeBase.thrift"

const string SERVICE_NAME = "stethoscope";

struct Endpoint {
    1: required string hostname;
    2: required i32 port;
}

service StethoscopeService extends EzBakeBase.EzBakeBaseService {
    /**
     * Lets a client checkin to let us know that they are still alive
     *
     * @param applicationName the name of the application we want to make sure is alive
     * @param serviceName the name of the service we want to make sure is alive
     *
     * @returns a boolean which tells us that the service has processed the request
     */
    bool checkin(1: string applicationName, 2: string servceName, 3: Endpoint endpoint);
}
