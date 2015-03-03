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

namespace * ezbake.security.thrift
namespace py ezbake.security.thriftapi
namespace go ezbake.security.thriftapi

include "EzBakeBase.thrift"

typedef EzBakeBase.EzSecurityToken EzSecurityToken
typedef EzBakeBase.EzSecurityTokenJson EzSecurityTokenJSON
typedef EzBakeBase.EzSecurityPrincipal EzSecurityPrincipal
typedef EzBakeBase.TokenRequest TokenRequest
typedef EzBakeBase.ValidityCaveats ValidityCaveats
typedef EzBakeBase.X509Info X509Info

exception AppNotRegisteredException {
    1: string message;
}

exception UserNotFoundException {
    1: string message;
}

struct ProxyTokenRequest {
    1: X509Info x509;
    5: ValidityCaveats validity;
}

struct ProxyTokenResponse {
    1: required string token;
    2: required string signature;
}

const string SECURITY_SERVICE_NAME = "EzBakeSecurityService";

service EzSecurity extends EzBakeBase.EzBakeBaseService {
    /**
     * Initial user log in requires a proxy token. Right now proxy tokens are only issued to the frontend
     *
     * @param request the signed token request
     *
     * @return a proxy token issued by EzSecurity
     */
    ProxyTokenResponse requestProxyToken(
        1: required ProxyTokenRequest request) throws (
            1: EzBakeBase.EzSecurityTokenException ezSecurityTokenException,
            2: UserNotFoundException userNotFound);

    /**
     * Request tokens from EzSecurity. These can be inital token requests (app or user) as well as request to forward a
     * received token to another application.
     *
     * @param request a request object generated with the requested information
     * @param signature the base64 encoded signature of the serialized request object
     */
    EzSecurityToken requestToken(
        1: required TokenRequest request,
        2: required string signature) throws (
            1: EzBakeBase.EzSecurityTokenException ezSecurityTokenException,
            2: AppNotRegisteredException appNotRegistered);

    /**
     * Refresh an expired token
     *
     * @param request a token request that includes the expired token
     * @param signature the base64 encoded signature of the serialized request object
     *
     * @return an updated token
     */
    EzSecurityToken refreshToken(
        1: required TokenRequest request,
        2: required string signature) throws (
            1: EzBakeBase.EzSecurityTokenException ezSecurityTokenException,
            2: AppNotRegisteredException appNotRegistered);

    /**
     * Checks whether the given user id is valid
     *
     * @param ezSecurityToken a token issued by EzSecurity to the requesting app, with targetSecurityId EzSecurity
     * @param userId the user's id
     *
     * @return true if the user is valid, otherwise false
     */
    bool isUserInvalid(
        1: required EzSecurityToken ezSecurityToken,
        2: required string userId) throws (
            1: EzBakeBase.EzSecurityTokenException tokenException);

    EzSecurityTokenJSON requestUserInfoAsJson(
        1: required TokenRequest request,
        2: required string signature ) throws (
            1: EzBakeBase.EzSecurityTokenException ezSecurityTokenException);

    /**
     * This function can only be executed EzSecurity -> EzSecurity. It will reject other requests. Depends on SSL
     */
    bool updateEzAdmins(1: set<string> ezAdmins);

    /**
     * Wipe out any caches of external data that EzSecurity is maintining
     */
    void invalidateCache(
        1: required EzSecurityToken request) throws (1: EzBakeBase.EzSecurityTokenException ezSecurityTokenException);



    /*
     * get a user's authorizations as computed by EzSecurity. Only callable by applications with _Ez_ security ids
     */
    set<string> getAuthorizations(
        1:required EzBakeBase.EzSecurityToken token,
        2:required EzBakeBase.TokenType userType,
        3:required string userId) throws (
            1:EzBakeBase.EzSecurityTokenException tokenException, 2:UserNotFoundException userNotFound)

}

enum RegistrationStatus {
    PENDING,
    ACTIVE,
    DENIED
}

struct ApplicationRegistration {
    1: string id;
    2: string owner;
    3: string appName;
    4: string classification;
    5: list<string> authorizations;
    10: list<string> communityAuthorizations;
    6: RegistrationStatus status;
    7: set<string> admins;
    8: string appDn;
    9: optional string message;
}

struct AppCerts {
    1: binary application_priv;
    2: binary application_pub;
    3: binary application_crt;
    4: binary application_p12;
    5: binary ezbakeca_crt;
    6: binary ezbakeca_jks;
    7: binary ezbakesecurityservice_pub;
}

exception RegistrationException {
    1: string message;
}

exception SecurityIDNotFoundException {
    1: string message;
}

exception SecurityIDExistsException {
    1: string message;
}

exception PermissionDeniedException {
    1:string message;
}

exception AdminNotFoundException {
    1:string message;
}

const string REGISTRATION_SERVICE_NAME = "EzSecurityRegistration";

service EzSecurityRegistration extends EzBakeBase.EzBakeBaseService {
    /**
     * Creates a New Application in the EzSecurity Registration database
     *
     * @param ezToken Required token issued by EzSecurity. Will be verified
     * @param appName The application name
     * @param classification Classification level of the application
     * @param authorizations List of all authorizations application is authorized for
     * @param id Optional, if not provided one will be generated
     * @param admins Optional, set of user DNs for users who should be allowed to administer this application
     *
     * @returnsthe security ID of the registration
     *
     * @throws RegistrationException if passed ID already exists
     */
    string registerApp(
        1: required EzBakeBase.EzSecurityToken ezToken,
        2: required string appName,
        3: required string classification,
        4: required list<string> authorizations,
        8: list<string> communityAuthorizations,
        5: string id,
        6: set<string> admins,
        7: string appDn) throws (
            1: RegistrationException regException,
            2: SecurityIDExistsException sidException);

    /**
     * Promotes An Application. Must be an admin to use this method.
     *
     * @param ezToken Required token issued by EzSecurity. Will be verified
     * @param id Security ID of application being promoted
     *
     * @throws RegistraitonException if user is not an admin or registraion does not exist
     */
    void promote(
        1: required EzBakeBase.EzSecurityToken ezToken,
        2: required string id) throws (
            1: RegistrationException regException,
            2: SecurityIDNotFoundException sidnfException,
            3: PermissionDeniedException pdException);

    /**
     * Demotes An Application - sets application status to pending. Application can be re-promoted. Must be an admin to
     * use this method.
     *
     * @param ezToken Required token issued by EzSecurity. Will be verified
     * @param id Security ID of application being demoted
     *
     * @throws RegistraitonException if user is not an admin or registraion does not exist
     */
    void demote(
        1: required EzBakeBase.EzSecurityToken ezToken,
        2: required string id) throws (
            1: RegistrationException regException, 2: SecurityIDNotFoundException sidnfException);

    /**
     * Denies An Application. Must be an admin to use this method.
     *
     * @param ezToken Required token issued by EzSecurity. Will be verified
     * @param id Security ID of application being unregistered
     *
     * @throws RegistraitonException if user is not an admin or registraion does not exist
     */
    void denyApp(
        1: required EzBakeBase.EzSecurityToken ezToken,
        2: required string id) throws (
            1: RegistrationException regException,
            2: SecurityIDNotFoundException sidnfException,
            3: PermissionDeniedException pdException);

    /**
     * Deletes an application registration.
     *
     * Must be the application owner or EzAdmin to call this method. Can only delete an app that is pending or denied
     */
    void deleteApp(
        1: required EzBakeBase.EzSecurityToken securityToken,
        2: required string id) throws (
            1: RegistrationException regException,
            2: SecurityIDNotFoundException sidnfException,
            3: PermissionDeniedException pdException);

    /**
     * Updates metadata associated with a registered application
     *
     * Puts the updated application into pending status
     *
     * @param ezToken Required token issued by EzSecurity. Will be verified
     * @param registration ApplicationRegistration with updates
     *
     * @throws RegistraitonException if registraion does not exist, or unallowed updates requsted
     */
    void update(
        1: required EzBakeBase.EzSecurityToken ezToken,
        2: required ApplicationRegistration registration) throws (
            1: RegistrationException regException,
            2: SecurityIDNotFoundException sidnfException);

    /**
     * Retrieves an Application Registration, regardless of status
     *
     * @param ezToken Required token issued by EzSecurity. Will be verified
     * @param id Security ID of application being queried
     *
     * @throws RegistraitonException if registraion does not exist
     */
    ApplicationRegistration getRegistration(
        1: required EzBakeBase.EzSecurityToken ezToken,
        2: required string id) throws (
            1: RegistrationException regException,
            2: SecurityIDNotFoundException sidnfException,
            3: PermissionDeniedException pemException);

    /**
     * Retrieves Registration Status for a given security ID
     *
     * @param ezToken Required token issued by EzSecurity. Will be verified
     * @param id Security ID of application being queried
     *
     * @throws RegistraitonException if registraion does not exist
     */
    RegistrationStatus getStatus(
        1: required EzBakeBase.EzSecurityToken ezToken,
        2: required string id) throws (
            1: RegistrationException regException,
            2: SecurityIDNotFoundException sidnfException);

    /**
     * Retrieves all Application Registration, owned by a user
     *
     * @param ezToken Required token issued by EzSecurity. Will be verified
     *
     * @throws RegistraitonException if registraion does not exist, or other errors
     */
    list<ApplicationRegistration> getRegistrations(
        1: required EzBakeBase.EzSecurityToken ezToken) throws (1: RegistrationException regException);


    /**
     * Retrieves all Application Registration, optionally filtered by status. Admins can see registrations they don't
     * own, but if a non-admin user calls this method, they will only see registrations they own.
     *
     * @param ezToken Required token issued by EzSecurity. Will be verified
     *
     * @throws RegistraitonException if registraion does not exist, or other errors
     */
    list<ApplicationRegistration> getAllRegistrations(
        1: required EzBakeBase.EzSecurityToken ezToken,
        2: RegistrationStatus status) throws (
            1: RegistrationException regException);

    AppCerts getAppCerts(
        1: required EzBakeBase.EzSecurityToken ezToken,
        2: required string id) throws (
            1: RegistrationException regException,
            2: SecurityIDNotFoundException sidnfException);


    void addAdmin(
        1: required EzBakeBase.EzSecurityToken ezToken,
        2: required string id,
        3: required string admin) throws (
            1: PermissionDeniedException pdException,
            2: SecurityIDNotFoundException sidnfException
            3: RegistrationException rException);

    void removeAdmin(
        1: required EzBakeBase.EzSecurityToken ezToken,
        2: required string id,
        3: required string admin) throws (
            1: PermissionDeniedException pdException,
            2: SecurityIDNotFoundException sidnfException,
            3: RegistrationException rException);
}
