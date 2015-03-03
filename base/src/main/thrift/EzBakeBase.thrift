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

namespace * ezbake.base.thrift
namespace py ezbake.base.thriftapi
namespace go ezbake.base.thriftapi

include "EzMetrics.thrift"

struct TimeZone {
    1: required i16 hour;
    2: required i16 minute;
    3: required bool afterUTC;
}

struct Time {
    1: required i16 hour;
    2: required i16 minute;
    3: optional i16 second;
    4: optional i16 millisecond;
    5: required TimeZone tz;
}

struct Date {
    1: required i16 month;
    2: required i16 day;
    3: required i16 year;
}

struct DateTime {
    1: required Date date;
    2: optional Time time;
}

struct Coordinate {
    1: required double latitude;
    2: required double longitude;
}

struct Preview {
    1: required string mimetype;
    2: required binary content;
}

struct DocumentClassification {
    1: string classification;
}

/**
 * Enterprise metadata that contains additional information pertaining to a document.
 */
struct EnterpriseMetaData {
    1: map<string, string> tags;
}

struct PlatformObjectVisibilities {
    /**
     * Indicates the platform-wide object read authorizations of a requestor
     */
    1: optional set<i64> platformObjectReadVisibility,

    /**
     * Indicates the platform-wide object discovery authorizations of a requestor
     */
    2: optional set<i64> platformObjectDiscoverVisibility,

    /**
     * Indicates the platform-wide object write authorizations of a requestor
     */
    3: optional set<i64> platformObjectWriteVisibility,

    /**
     * Indicates the platform-wide object management authorizations of a requestor
     */
    4: optional set<i64> platformObjectManageVisibility
}

struct AdvancedMarkings {
    /**
     * The visibility controls for the object where the controls are based on permissions set in an external system
     */
    1: optional string externalCommunityVisibility,

    /**
     * The visibility controls for the object based on permissions set in the platform object permission management
     * service
     */
    2: optional PlatformObjectVisibilities platformObjectVisibility,

    /**
     * When the object is registered with the provenance service, it gets a unique ID for provenance/purge/ageoff uses.
     */
    3: optional i64 id,

    /**
     * For purge / ageoff. If this field is not set, a system-level purge or age-off call to the dataset where this
     * record matches will cause the record to be expunged.
     *
     * That behavior may not be appropriate for composite objects like counts or data derived from multiple provenance
     * sources.
     */
    4: optional bool composite,

    /**
     * If a system-level purge matches this row but the composite field was set at the time of the match, the access
     * layer *may* add the purge ID to this set as a mechanism to track that the data needs attention to fulfill a
     * purge.
     *
     * This may not make sense for all databases. Consequently, the access layer can choose to record the information
     * elsewhere as long as the access layer has an easy mechanism to determine exactly what data is still subject to an
     * incomplete purge operation
     */
    5: optional set<i64> purgeIds,
}

struct Visibility {
    /**
     * The formal visibility controls for the object
     */
    1: optional string formalVisibility,

    2: optional AdvancedMarkings advancedMarkings,

    3: optional string fullTextVisibility
}

/**
 * Standard Search Result. This object encapsulates a search result for a particular object that has been ingested and
 * disseminated into ezbake. Each field represents a piece of metadata about the ingested object. It also provides
 * faceting ability at query time.
 */
struct SSR {
    /**
     * The warehouse URI that correlates with this SSR object. The URI will point back to the original raw and parsed
     * object in the warehouse.
     */
    1: required string uri;

    /**
     * The visibility of the SSR object and it's corresponding original document.
     */
    2: required Visibility visibility;

    /**
     * The title of this search result. This would typically be the title of the incoming document to which this SSR
     * corresponds.
     */
    3: optional string title;

    /**
     * A snippet from the incoming document (if applicable). A typical case for including a snippet would be if the
     * corresponding document has a summary.
     */
    4: optional string snippet;

    /**
     * The date corresponding to the incoming document. This may be an event date from the document, or potentially a
     * document creation date. This field is flexible and should be set to the most useful value for the end user.
     */
    5: optional DateTime resultDate;

    /**
     * A geospatial coordinate that corresponds to the incoming document. This is only applicable in certain situations,
     * but may provide the end user with extra context and search/faceting ability.
     */
    6: optional Coordinate coordinate;

    /**
     * A binary preview of the document. This field pertains to a thumbnail or other binary representation of the
     * incoming document/object.
     */
    7: optional Preview preview;

    /**
     * Enterprise metadata containing data that pipelines tag a document with. This would be additional pieces of
     * information about the data that users can later search on.
     */
    8: optional EnterpriseMetaData metaData;

    /**
     * This field contains the timestamp which was generated when the SSR was indexed in the SSR service. If this value
     * is set when set to the SSR service, it will be ignored.
     */
    9: optional DateTime timeOfIngest;
}

/**
 * Information associated with a particular user, included when token is of type USER
 */
struct UserInfo {
    1: required string principal
    2: optional string id
    3: optional string firstName
    4: optional string lastName
    5: optional string name
    6: optional string citizenship

    /**
     * Key in the map is the type of email, ex: work, home, etc..
     */
    7: optional map<string, string> emails

    8: optional map<string, string> phoneNumbers
    9: optional string company
    10: optional string organization
}

/**
 * Information associated with an application, included when token is of type APP
 */
struct AppInfo {
    1: required string securityId
    2: optional string principal
}

/**
 * Communities are specialized groups that are supported from outside of EzBake
 */
struct CommunityMembership {
    1: required string name
    2: required string type
    3: optional string organization
    4: optional list<string> groups
    5: optional list<string> regions
    6: optional list<string> topics
    7: optional map<string, bool> flags
}

/**
 * EzSecurityToken types
 */
enum TokenType {
    USER,
    APP
}

/**
 * Validity structure contains the information used to verify the different types of tokens
 */
struct ValidityCaveats {
    /**
     * Issuer - may be used when verifying the signature
     */
    1: required string issuer

    /**
     * Ezbake Security ID of application token is issued to
     */
    2: required string issuedTo

    /**
     * Ezbake Security ID of application token can be passed to
     */
    3: optional string issuedFor

    /**
     * Timestamp of when the token becomes invalid
     */
    4: optional i64 issuedTime

    5: optional i64 notBefore
    6: required i64 notAfter

    /**
     * Base64 encoded signature generated with issuers private key. Used to verify the validity of the information in
     * the token
     */
    7: required string signature
}

/**
 * Principal associated to a specific entity
 */
struct EzSecurityPrincipal {
    /**
     * Identity of the entity
     */
    1: required string principal

    2: required ValidityCaveats validity

    /**
     * If present, the chain of custody the request has passed through
     */
    3: optional list<string> requestChain

    /**
     * ID if one exists above and beyond the principal
     */
    4: optional string externalID

    /**
     * The pretty name of the subject
     */
    5: optional string name

    6: optional string issuer
}

struct Authorizations{
    /**
     * The requestor's formal authorizations
     */
    1: optional set<string> formalAuthorizations,

    /**
     * The requestor's authorizations derived from external community memberships
     */
    2: optional set<string> externalCommunityAuthorizations,

    /**
     * The requestor's authorizationd derived from the platform's object security management service
     */
    3: optional set<i64> platformObjectAuthorizations,
}

/**
 * Token issued to applications and trusted throughout ezbake
 */
struct EzSecurityToken {
    /**
     * Caveats relating to token validity - the who, what, when, and signature
     */
    1: required ValidityCaveats validity

    /**
     * Type of token this is - if not present, assume it is a USER token
     */
    2: required TokenType type = TokenType.USER

    /**
     * Principal associated with this token. If present, and not expired, can be used to request new tokens
     */
    3: required EzSecurityPrincipal tokenPrincipal

    /**
     * Level of access the token is valid for. Definition of what levels mean is left up to the implementation
     */
    10: optional string authorizationLevel

    /**
     * Currently the best type of authorizations to use
     */
    11: optional Authorizations authorizations

    /**
     * External project groups come from outside of Ezbake (LDAP, etc...), and indicate membership for this token
     */
    13: optional map<string, list<string>> externalProjectGroups

    /**
     * Additional groups token belongs to, external to ezbake. More fine grained information than project groups
     */
    14: optional map<string, CommunityMembership> externalCommunities

    /**
     * Citizenship of token principal\
     */
    15: optional string citizenship

    /**
     * Organization of token principal
     */
    16: optional string organization

    /**
     * Flag indicating whether or not this token can be used in request to external services
     */
    17: optional bool validForExternalRequest = false

    18: optional string externalRequestPrincipal
    19: optional string externalRequestPrincipalIssuer
}

/**
 * Generic exception thrown when EzSecurityTokens go bad. We could add more specific causes, possibly an enum
 */
enum EzSecurityTokenExceptionType {
    EXPIRED,
    INVALID_SIGNATURE,
    INVALID_SECURITY_ID
}

exception EzSecurityTokenException {
    1:required string message
    2:optional string originalException
    3:optional EzSecurityTokenExceptionType type
}

/**
 * JSON representation of an ezsecurity token - not necessarily guaranteed to have same structure as EzSecurityToken
 */
struct EzSecurityTokenJson {
    1: required string json
    2: required string signature
}

struct X509Info {
    1:required string subject
    2:optional string issuer
}

struct ProxyUserToken {
    1:X509Info x509
    10:required string issuedBy
    11:required string issuedTo
    12:optional string issuedFor
    13:required i64 notAfter
    14:optional i64 notBefore
}

struct ProxyPrincipal {
    1: required string proxyToken;
    2: required string signature
}

/**
 * Used to request new tokens from EzSecurity
 */
struct TokenRequest {
    /**
     * Ezbake Security ID of requesting application
     */
    1: required string securityId;

    /**
     * Ezbake Security ID of application this token should be passed to
     */
    2: optional string targetSecurityId

    /*
     * Time at which this token was generated
     */
    3: required i64 timestamp;

    /*
     * Type of token being requested
     */
    5: required TokenType type = TokenType.USER;

    /*
     * Signature validity fields. These will be given priority over 1,2,3 if present
     */
    6: optional ValidityCaveats caveats

    /*
     * If present, auths in this set will not be included in the token
     */
    7: optional set<string> excludeAuthorizations;

    10: optional ProxyPrincipal proxyPrincipal
    11: optional EzSecurityToken tokenPrincipal
    12: optional EzSecurityPrincipal principal
}

enum ntkAccessType {
    PROFILE,
    GROUP,
    INDIVIDUAL
}

struct ntkAccess {
    1: required ntkAccessType accessType;
    2: required string accessSystemName;
    3: required list<string> accessValues;
}

struct ClassificationMarkings {
    1: required string classification;
    2: string ownerProducer;
    3: string declassDate;
    4: string SciControls;
    5: string sarIdentifier;
    6: string atomicEnergyMarkings;
    7: string disseminationControls;
    8: string fgiSourceOpen;
    9: string displayOnlyTo;
    10: string fgiSourceProtected;
    11: string releasableTo;
    12: string classifiedBy;
    13: string nonICMarkings;
    14: string compilationReason;
    15: string derivativelyClassifiedBy;
    16: string classificationReason;
    17: string nonUsControls;
    18: string derivedFrom;
    19: string declassException;
    20: string declassEvent;
    21: list<ntkAccess> ntkAccessList
}

union Classification {
    1: string CAPCOString;
    2: ClassificationMarkings markings;
}

/**
 * This exception describes when an application or user attempts to write or manage the visibility of data that they do
 * not have authorization to write or manage. This exception should NOT be used in cases where the user or application
 * does not have proper READ or DISCOVER permissions.
 */
exception EzBakeAccessDenied {
    1: optional string message;
}

enum Permission {
    READ,
    WRITE,
    MANAGE_VISIBILITY,
    DISCOVER
}

exception PurgeException {
    1: string message
}

enum CancelStatus{
    NOT_CANCELED,
    CANCELED,
    CANCEL_IN_PROGRESS,
    CANNOT_CANCEL
}

enum PurgeStatus {
    UNKNOWN_ID,
    /** Only valid when this structure is generated by the central purge service */
    WAITING_TO_START,
    STARTING,
    PURGING,
    STOPPING,
    ERROR,
    FINISHED_COMPLETE,
    FINISHED_INCOMPLETE
}

struct PurgeState {
    1: required PurgeStatus purgeStatus,
    2: required i64 purgeId,

    /**
     * The time at which this status was last updated
     */
    3: required DateTime timeStamp,

    /**
     * The numbers in this set correspond to IDs that were set in the initiating idsToPurge set, where the referenced
     * ID was purged from this application either because it found and successfully removed or because that ID was not
     * found within this application.
     *
     * IDs may exist in both the purged and notPurged set. The central purge service will remove any IDs in the
     * notPurged set from the purged set automatically.
     *
     * The value for this parameter should not be considered valid if status is one of: UNKNOWN_ID or WAITING_TO_START
     */
    4: required set<i64> purged,

    /**
     * The numbers in this set correspond to IDs that were set in the initiating idsToPurge set, where the referenced ID
     * was found within this application's data, but where this application was not able to completely remove data
     * marked with this ID. If this set is of non-zero length, system administrators must contact app administrators to
     * initiate manual purge.
     *
     * The value for this parameter should not be considered valid if status is one of: UNKNOWN_ID or WAITING_TO_START
     */
    5: required set<i64> notPurged,

    /**
     * The suggested minimum period(ms) at which the central purge service should poll the status of a purge. This is
     * only a suggestion and may beignored by the purge service.
     */
    6: required i32 suggestedPollPeriod,

    7: optional CancelStatus cancelStatus = CancelStatus.NOT_CANCELED
}

service EzBakeBaseService {
    /**
     * This method is used to ping a service and can be used for health checking.
     *
     * @returns true or false depending on whether service is healthy or not.
     */
    bool ping();

    /**
     * This method is used to grab a metrics registry
     */
    EzMetrics.MetricRegistryThrift getMetricRegistryThrift();
}

/**
 * This is the base thrift service an application needs to implement to support the centralized purging. The central
 * purge service will call every application's purge service to initiate a purge operation.
 *
 *   +-------------------------+
 *   |                         |
 *   |  Central Purge Service  |
 *   |                         |
 *   +-----------+-------------+
 *               |
 *               |
 *               |
 *   +-----------v-------------+
 *   |                         |
 *   |Application Purge Service|
 *   |                         |
 *   +-----------+-------------+
 *               |
 *               |
 *               |
 *   +-----------v-------------+
 *   |                         |
 *   |    Data Access Layer    |
 *   |                         |
 *   +-------------------------+
 *
 */
service EzBakeBasePurgeService extends EzBakeBaseService {
   /**
    * Start a purge of the given items.  This method will begin purging items
    * that match the given set of IDs and will call back to the
    * purgeCallbackService when the purge has completed. The return of this
    * function without exception indicates that the application has taken
    * responsibility of purging documents matching purgeIds from its data sets.
    * It does not indicate completion of the purge.
    *
    * Returns the state of the new purge request.
    *
    * @param purgeCallbackService ezDiscovery path of the purge service to
    *        call back to.
    * @param purgeId Unique id to use for this purge request. Will be the string
    *        representation of an i64 number in the case of a true purge, or be
    *        prefaced with “AgeOff_<rule#>_<timestamp>” in the case that this
    *        purge is occurring due to age-off processing. The implementing
    *        application typically should not care and should not take any
    *        action based on that fact.
    *
    * @param idsToPurge set<i64> containing all the items to purge. This should
    *        be sent to the data access layer to perform the purge.
    * @param initiatorToken Security token for the service or user that
    *        initiated the purge.
    */
   PurgeState beginPurge(
       1: string purgeCallbackService,
       2: required i64 purgeId,
       3: set<i64> idsToPurge,
       4: EzSecurityToken initiatorToken) throws (1: PurgeException e, 2: EzSecurityTokenException tokenException);

   PurgeState beginVirusPurge(
       1: string purgeCallbackService,
       2: required i64 purgeId,
       3: set<i64> idsToPurge,
       4: EzSecurityToken initiatorToken) throws (1: PurgeException e, 2: EzSecurityTokenException tokenException);

   /**
    * Returns the state of a given purge request.
    *
    * @param purgeId Unique id to use for this purge request
    * @returns Status of the given purge, UNKNOWN_ID if it was not found
    */
   PurgeState purgeStatus(
       1: required EzSecurityToken token, 2: required i64 purgeId) throws (1: EzSecurityTokenException tokenException);

   /**
    * Request cancelling a purge that is currently running. In order to attempt
    * to not leave the application in an unstable state the application may not
    * be able to cancelt the purge.
    *
    * @param token Security token for the service or user that requested the cancel.
    * @param purgeId Unique id for the purge to cancel
    *
    * @returns CancelStatus the enum for the current state of the cancel.
    */
   PurgeState cancelPurge(
       1: required EzSecurityToken token, 2: required i64 purgeId) throws (1: EzSecurityTokenException tokenException);
}
