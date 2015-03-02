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

namespace * ezbake.profile

include "EzBakeBase.thrift"
include "EzSecurityServices.thrift"

typedef EzBakeBase.UserInfo UserInfo
typedef EzBakeBase.EzSecurityToken SecurityToken

enum SearchStatus {
    OK,
    ERROR
}

struct UserProfile {
    1: required string principal;
    2: required string uid;
    3: optional string firstName;
    4: optional string lastName;
    5: optional map<string, string> emails;
    6: optional string companyName;
    7: optional string phoneNumber;
    8: optional string organization;
    9: optional list<string> affiliations;
}

struct SearchResult {
    1: optional set<string> principals;
    2: optional map<string, UserProfile> profiles;
    3: optional bool resultOverflow;
    4: required SearchStatus statusCode;
}

exception MalformedQueryException {
    1: string reason;
}

const string SERVICE_NAME = "ezprofile";

service EzProfile extends EzBakeBase.EzBakeBaseService {
    /* --- Search requests --- */

    SearchResult searchDnByName(
        1: required SecurityToken ezToken,
        2: required string first,
        3: required string last) throws (
            1: EzBakeBase.EzSecurityTokenException tokenException);

    SearchResult searchDnByQuery(
        1: required SecurityToken ezToken,
        2: required string query) throws (
            1: MalformedQueryException mqException,
            2: EzBakeBase.EzSecurityTokenException tokenException);

    SearchResult searchProfileByName(
        1: required SecurityToken ezToken,
        2: required string first,
        3: required string last) throws (
            1: EzBakeBase.EzSecurityTokenException tokenException);

    SearchResult searchProfileByQuery(
        1: required SecurityToken ezToken,
        2: required string query) throws (
            1: MalformedQueryException mqException,
            2: EzBakeBase.EzSecurityTokenException tokenException);

    /* --- UserInfo requests: These Requests are deprecated and may be removed in a future version --- */

    UserInfo userProfile(
        1: required SecurityToken ezToken,
        2: string principal) throws (
            1: EzBakeBase.EzSecurityTokenException tokenException,
            2: EzSecurityServices.UserNotFoundException userNotFound);

    map<string, UserInfo> userProfiles(
        1: required SecurityToken ezToken,
        2: set<string> principals) throws (
            1: EzBakeBase.EzSecurityTokenException tokenException,
            2: EzSecurityServices.UserNotFoundException userNotFound);

    /* --- UserProfile requests --- */

    UserProfile getUserProfile(
        1: required SecurityToken ezToken,
        2: string principal) throws (
            1: EzBakeBase.EzSecurityTokenException tokenException,
            2: EzSecurityServices.UserNotFoundException userNotFound);

    map<string, UserProfile> getUserProfiles(
        1: required SecurityToken ezToken,
        2: set<string> principals) throws (
            1: EzBakeBase.EzSecurityTokenException tokenException,
            2: EzSecurityServices.UserNotFoundException userNotFound);
}