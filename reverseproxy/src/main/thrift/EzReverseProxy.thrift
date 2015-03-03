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

namespace * ezbake.reverseproxy.thrift
namespace py ezbake.reverseproxy.thriftapi
namespace go ezbake.reverseproxy.thriftapi

include "EzBakeBase.thrift"

const string SERVICE_NAME = "EzBakeFrontend";

enum ContentServiceType {
    DYNAMIC_ONLY = 0,
    STATIC_ONLY = 1,
    HYBRID = 2
}

enum AuthorizationOperation {
    USER_INFO,
    USER_JSON
}

/**
 * This is the structure that servers use to register with the reverse proxy. Registration is done via the
 * addUpstreamServerRegistration method.
 *
 * The first server that registers using this structure is effectively registering the application. When registering
 * multiple instances of a single application (typically for load balancing) ALL REGISTRATIONS MUST HAVE MATCHING
 * UserFacingUrlPrefix, AppName, and UpstreamPath. Once a UserFacingUrlPrefix is registered, any further registrations
 * of that prefix will be rejected if AppName and UpstreamPath do not match the values used in the first registration.
 * Additionally, timeout and timeoutTries SHOULD also be identical, but that is not strictly required. Obviously,
 * UpstreamHostAndPort should be different because the whole point is to register multiple upstream servers for reverse
 * proxying. However, if a duplicate UpstreamHostAndPort is registered, no error will occur.
 *
 * This structure is also used to remove upstream server registration in the removeUpstreamServerRegistration method. In
 * that method, only the UserFacingUrlPrefix, AppName, and UpstreamHostAndPort are are required.
 *
 * The tuple (UserFacingUrlPrefix, AppName, and UpstreamHostAndPort) unqiuely identifies an upstream proxy
 */
struct UpstreamServerRegistration {
    /**
     * This is the server name and path that maps to your application. It must be unique to your application. Do not
     * prefix this with http:// or https://. This should typically be something like:
     *     www.example.com/YourAppName/
     *
     * Though you'll need to use a server name that is valid for the project. Additionally, the path portion could be
     * more complicated, but should be simple. Do not include query parameters in this prefix.
     */
    1: required string UserFacingUrlPrefix;

    /**
     * The application name within EzBake it should probably be the same as the text in 1 folowing the first.
     * THIS VALUE MUST BE THE SAME FOR ALL REGISTRATIONS OF A SINGLE UserFacingUrlPrefix
     */
    2: required string AppName;

    /**
     * This is the hostname and port number on which the server to be reverse proxied runs. This should be of the form
     * "FQHostname:port" or "IP:port". For example, "www.example.com:443" or "192.168.1.1:8080"
     */
    3: required string UpstreamHostAndPort;

    /**
     * This is the path on the server to be proxied. This will often either be / or the same as the AppName. If the
     * service to be proxied is at 192.168.1.1:8080/myApp/, the value specified here should be myApp/.
     *
     * THERE ARE SEVERAL IMPORTANT RESTRICTIONS HERE!!!
     *     - The proxy will not automatically append a trailing / character. If you need it, append it explicitly.
     *     - wildcard characters are not allowed
     *     - adding query parameters *should* work here but is not officially supported.
     *     - THIS PARAMETER MUST BE THE SAME FOR ALL REGISTRATIONS OF A UserFacingUrlPrefix.
     */
    4: string UpstreamPath;

    /**
     * The time during which the specified number of unsuccessful attempts to communicate with the upstream should
     * happen to consider teh upstream unavailable. Also the time period the upstream will be considered unavailable.
     *
     * Valid ranges: 1 - 120 (seconds)
     */
    5: i32 timeout = 10;

    /**
     * The number of unsuccessful attempts to communicate with the upstream that should happen in the duration set by
     * the timeout (see above) parameter to consider the upstream unavailable for a duration also set by timeout
     * parameter.
     *
     * Valid ranges: 1 - 10
     */
    6: i32 timeoutTries = 1;

    /**
     * Sets the maximum allowed size of the client request body in MB. If set to zero, the system's default (currently
     * 256MB) will be used.
     */
    7: i32 uploadFileSize = 2;

    /**
     * Set this option to allow upstream session affinity. This is not useful for all static content served by the
     * frontend, as network load balancers are not session-aware, and may route the session across multiple frontend
     * instances
     */
    8: bool sticky = false;

    /**
     * Set this option to disable the support for chunked transfer encoding despite the HTTP/1.1 standards's
     * requirement
     */
    9: optional bool disableChunkedTransferEncoding = false;

    /**
     * Set of operations to perform when allowing a user to access requests/resources at the specified
     * UserFacingUrlPrefix. The value must be the same for all registrations of a UserFacingUrlPrefix. Using an empty
     * set, bypasses authorization and allows access.
     */
    10: optional set<AuthorizationOperation> authOperations = [AuthorizationOperation.USER_INFO,
                                                             AuthorizationOperation.USER_JSON];

    /**
     * Set this option to enabled validating the SSL certs when connecting to the upstream. The value must be the same
     * for all registrations of a UserFacingUrlPrefix.
     */
    11: optional bool validateUpstreamConnection = false;

    /**
     * Specifies the type of content that will be served for this registration. The value must be the same for all
     * registrations of a UserFacingUrlPrefix.
     */
    12: optional ContentServiceType contentServiceType = ContentServiceType.DYNAMIC_ONLY;
}

/**
 * Container for static content tarball. All content in the tarball MUST be classified no greater than the minimum
 * clearance level required for a user to gain access to the network.
 */
struct StaticContentBottle {
    1: string userFacingUrlPrefix;
    2: optional binary content;
}

/**
 * The registration could not be found
 */
exception RegistrationNotFoundException {
    1: string message;
}

/**
 * The registration could not be added because there is an existing registration with the same UserFacingUrlPrefix but a
 * different AppName or UpstreamPath
 */
exception RegistrationMismatchException {
    1: string message;
}

/**
 * The registration could not be added because one or more of the parameters was invalid
 */
exception RegistrationInvalidException {
    1: string message;
}

/**
 * Could not perform the static content operation
 */
exception StaticContentException {
    /**
     * Exception message
     */
    1: string message;

    /**
     * List of user facing urls which operation could not be completed
     */
    2: set<string> urls;
}

service EzReverseProxy extends EzBakeBase.EzBakeBaseService {
    void addUpstreamServerRegistration(
        1: UpstreamServerRegistration registration) throws (
            1: RegistrationMismatchException eMismatch,
            2: RegistrationInvalidException eInvalid);

    void removeUpstreamServerRegistration(
        1: UpstreamServerRegistration registration) throws (1: RegistrationNotFoundException eNotFound);

    void removeReverseProxiedPath(1: string userFacingUrlPrefix) throws (1: RegistrationNotFoundException eNotFound);

    void removeAllProxyRegistrations();

    bool isUpstreamServerRegistered(1: UpstreamServerRegistration registration);

    bool isReverseProxiedPathRegistered(1: string userFacingUrlPrefix);

    set<UpstreamServerRegistration> getAllUpstreamServerRegistrations();
    set<UpstreamServerRegistration> getRegistrationsForProxiedPath(1: string userFacingUrlPrefix);
    set<UpstreamServerRegistration> getRegistrationsForApp(1: string appName);

    void addStaticContent(1: set<StaticContentBottle> bottles) throws (1: StaticContentException error);
    void removeStaticContent(1: set<StaticContentBottle> bottles) throws (1: StaticContentException error);
    bool isStaticContentPresentForProxiedPath(1: string userFacingUrlPrefix);
}
