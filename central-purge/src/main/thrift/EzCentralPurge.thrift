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

namespace * ezbake.services.centralPurge.thrift
namespace py ezbake.services.centralPurge.thriftapi
namespace go ezbake.services.centralPurge.thriftapi

include "EzBakeBase.thrift"
include "ProvenanceService.thrift"

const string SERVICE_NAME = "EzCentralPurgeService"

enum CentralPurgeStatus {
    ACTIVE,
    ACTIVE_MANUAL_INTERVENTION_WILL_BE_NEEDED,
    STOPPED_MANUAL_INTERVENTION_NEEDED,
    RESOLVED_AUTOMATICALLY,
    RESOLVED_MANUALLY
}

enum CentralPurgeType {
    NORMAL,
    VIRUS
}

struct ServicePurgeState {
    /**
     * This is a wrapper for ezbakeBasePurgeService.PurgeState to be used by ApplicationPurgeState. It will be where
     * information about a service that is not in PurgeState but is needed by ApplicationPurgeState where it will be
     * stored. Currently the only information that is need is the timestamp for when the purge was first sent to the
     * service (when it was initiated) and when it was last polled. Expect this struct to change as more functionality
     * is added.
     */
    1: required EzBakeBase.PurgeState purgeState,
    2: required EzBakeBase.DateTime timeInitiated,
    3: required EzBakeBase.DateTime timeLastPoll
}

struct ApplicationPurgeState {
    /**
     * This is a wrapper for ServicePurgeState to be used by CentralPurgeState. This is where information about a
     * specific app will be stored. Currently all that is needed is the state of each purge service under this app.
     */
    1: required map<string, ServicePurgeState> servicePurgestates,
}

struct CentralPurgeState {
    /**
     * The state map is a map of application security IDs to the ApplicationPurgeState. It could be the case that this
     * purge has not yet been issued to that application as we don’t want simultaneous purges of all applications to
     * overwhelm the system. If the purge has not yet been initiated for that application, the PurgeState.status would
     * be set to WAITING_TO_START by this central purge service so that it is not necessary to get this structure from
     * the app’s purge service
     */
    1: required map<string,ApplicationPurgeState> applicationStates,
    2: required ProvenanceService.PurgeInfo purgeInfo,
    3: required CentralPurgeStatus centralStatus,
    4: required CentralPurgeType centralPurgeType
}

struct AgeOffEventInfo{
    /**
     * A unique ID generated to represent this age off event
     */
    1: required i64 id,

    /**
     * The time at which this purge event was created
     */
    2: required EzBakeBase.DateTime timeCreated,

    /**
     * The set with positions set corresponding to the found URIs within DocumentUris at time of purge initiation
     */
    3: required set<i64> purgeSet,

    /**
     * The set with i64 corresponding to the URIs that the purge service acknowledges have been completely purged from
     * the system. This set is empty when markForPurge() creates this vertex and is populated by subsequent calls from
     * the purge service.
     */
    4: required set<i64> completelyPurgedSet,

    /**
     * Put the UserInfo.principal value in this field from the EzSecurityToken into this property to indicate who
     * initiated the purge
     */
    5: optional string user

    /**
     * A flag indicating that when true means this purge is no longer being processed
     */
    6 : required bool resolved

    /**
     * A longer text description of the age off.
     */
    7: optional string description
}

struct CentralAgeOffEventState {
    /**
     * The state map is a map of application security IDs to the PurgeState that the base purge service that app
     * returns. It could be the case that this purge has not yet been issued to that application as we do not want
     * simultaneous purges of all applications to overwhelm the system. If the purge has not yet been initiated for that
     * application, the PurgeState.status would be set to WAITING_TO_START by this central purge service so that it is
     * not necessary to get this structure from the app’s purge serivce (Applications treat ageOffEvents the same way
     * they do purges)
     */
    1: required map<string, ApplicationPurgeState> applicationStates,
    2: required AgeOffEventInfo ageOffEventInfo,
    3: required CentralPurgeStatus centralStatus,
    4: required i64 AgeOffRuleId,
}

struct CentralPurgeQueryResults {
    1: required list<CentralPurgeState>  purgeStates,
    2: required i64 count
}

struct CentralAgeOffEventQueryResults {
    1: required list<CentralAgeOffEventState> ageOffEventStates,
    2: required i64 count
}

exception CentralPurgeServiceException {
    1: string message
}

service EzCentralPurgeService extends EzBakeBase.EzBakeBaseService {
    /**
     * This method should use the provided URIs to start a new purge event within the provenance service utilizing that
     * service’s markForPurge(). It should return the ezProvenance.PurgeInitiationResult generated by that service as an
     * indication that the purge has begun, then discover all purge services within the system and begin calling the
     * beginPurge() methods for each of those applications.
     *
     * Initially, it is probably best to call one service, wait for it to complete, then call the next service. The
     * service must not block other requests while the purge is running.
     *
     * Additionally, this method should create some state internal to the EzCentralPurgeService to be able to support
     * getPurgeState() queries while the purge is ongoing and after it has completed.
     *
     * @param token The token must be validated and only requests from within the this same application should be
     *              allowed. Others should throw EzSecurityTokenException.
     * @param uris  This is the list of uris for which we must purge all descendant documents.
     * @param name  A human-readable name for this purge. This service should enforce the uniqueness of names.
     * @param description A human-readable (potentially long) description of why this purge is taking place
     *
     * @returns The method returns the PurgeInitiation result generated by the provenance service’s markForPurge()
     *          method that is called by this method.
     */
    ProvenanceService.PurgeInitiationResult beginPurge(
        1: required EzBakeBase.EzSecurityToken token,
        2: required list<string> uris,
        3: required string name,
        4: required string description) throws (
            1: EzBakeBase.EzSecurityTokenException security,
            2: CentralPurgeServiceException down)

    /**
     * This method should only be used by an anti-virus service to purge a virus from the system. The reason it is
     * different is some applications may want to keep a virus in their DB, for such uses as pen-testing. If they do
     * wish to store it then they just ignore the virus purge. For most every other app, there will be no difference
     * between beginPurge and beginVirusPurge.
     */
    ProvenanceService.PurgeInitiationResult beginVirusPurge(
        1: required EzBakeBase.EzSecurityToken token,
        2: required list<string> uris,
        3: required string name,
        4: required string description) throws (
            1: EzBakeBase.EzSecurityTokenException security,
            2: CentralPurgeServiceException down)

    /**
     * This method is used by the UI to get the detailed status of a list of purge event IDs. The UI can fetch the list
     * of all purge event IDs by calling the provenance service’s getAllPurgeIds().
     *
     * The UI can achieve paging by fetching the entire list from the provenance service’s getAllPurgeIds() and then
     * only requesting a slice of that list from the central purge service.
     *
     * @param token The token must be validated and only requests from within the this same application should be
     *              allowed. Others should throw EzSecurityTokenException.
     * @param purgIds This is the list of purges for which the UI is requesting detailed information
     *
     * @returns PurgeState The state for the selected purgeIds
     */
    list<CentralPurgeState> getPurgeState(
        1: required EzBakeBase.EzSecurityToken token,
        2: list<i64> purgeIds) throws (
            1: EzBakeBase.EzSecurityTokenException security,
            2: CentralPurgeServiceException down)

    /**
     * This method is used by the UI to initate the manual execution of an age off operation on the specified age off
     * rule. The UI should call the provenance service to get the list of age off rules.
     *
     * @param token The token must be validated and only requests from within the this same application should be
     *              allowed. Others should throw EzSecurityTokenException.
     * @param ruleId The ageOffRuleId for the age off
     *
     * @returns AgeOffEventInfo The info regarding the created age off
     */
    AgeOffEventInfo beginManualAgeOff(
        1: required EzBakeBase.EzSecurityToken token,
        2: required i64 ruleId) throws (
            1: EzBakeBase.EzSecurityTokenException security,
            2: ProvenanceService.ProvenanceAgeOffRuleNotFoundException ruleNotFound,
            3: CentralPurgeServiceException down)

    /**
     * This method is called by the individual application services that actually purge data to inform the Central Purge
     * Service of completion of a purge or error.
     *
     * The individual application services should call this method if their purge status changes to one of:
     *     STOPPING,
     *     ERROR,
     *     FINISHED_COMPLETE,
     *     FINISHED_INCOMPLETE
     *
     * The Central Purge Service should also poll the state of the individual application services periodically for this
     * information.
     *
     * @param token The token must be validated and requests from ANY APPLICATION should be allowed. If the token is not
     *              valid, generate a EzSecurityTokenException. The calling application’s security ID can be found in
     *              this token to identify the calling application.
     * @param state This is the purge state that the application is updating.
     * @param applicationName the applicatioName for the service calling the method
     * @param serviceName the serviceName for the service calling the method
     */
    void updatePurge(
        1: required EzBakeBase.EzSecurityToken token,
        2: required EzBakeBase.PurgeState state,
        3: required string applicationName,
        4: required string serviceName) throws (
            1: EzBakeBase.EzSecurityTokenException security,
            2: CentralPurgeServiceException down)

    /**
     * This method allows the UI to mark a a purge as being resolved and supply a note regarding  the resolution of the
     * purge.
     *
     * Manual resolution of a purge through the UI could happen for a couple reasons:
     *     * Not all documents could be automatically purged, so an admin is marking successful completion of the purge.
     *     * One application is not properly responding to a purge and admin interaction is required
     *
     * When this method is called, the Central Purge Service should make final updates to the state of the purge stored
     * in the Provenance SErvice and any state regarding the purge stored elsewhere. This is done via that service’s
     * updatePurge() method.
     *
     * When calling the provenance service’s updatePurge() method, the note should be included and resolved should be
     * set to true.
     *
     * @param token The token must be validated and only requests from within the this same application should be
     *              allowed. Others should throw EzSecurityTokenException.
     * @param purgId This is the purge that is being marked as resolved
     * @param notes Notes as to why this purge was manually resolved.
     */
    void resolvePurge(
        1: required EzBakeBase.EzSecurityToken token,
        2: required i64 purgeId,
        3: required string notes) throws (
            1: EzBakeBase.EzSecurityTokenException security,
            2: CentralPurgeServiceException down)

    /**
     * This method is used by the UI to get the detailed status of a list of ageOff event IDs. The UI can fetch the list
     * of all ageOff event IDs by calling the getAllAgeOffEvents() method.
     *
     * The UI can achieve paging by fetching the entire list from the getAllAgeOffEvents() and then only requesting a
     * slice of that list from this method.
     *
     * @param token The token must be validated and only requests from within the this same application should be
     *              allowed. Others should throw EzSecurityTokenException.
     * @param purgIds This is the list of purges for which the UI is requesting detailed information
     *
     * @returns List<AgeOffEventInfo> The list of info for the selected ageOffEventIds
     */
    list<CentralAgeOffEventState> getAgeOffEventState(
        1: required EzBakeBase.EzSecurityToken token,
        2: list<i64> ageOffEventIds) throws (
            1: EzBakeBase.EzSecurityTokenException security,
            2: CentralPurgeServiceException down)

    /**
     * @param token The token must be validated and only requests from within the this same application should be
     *              allowed. Others should throw EzSecurityTokenException.
     *
     * @returns This method should find all AgeOffEvents and return the ageOffEvent id for each
     */
    list<i64> getAllAgeOffEvents(
        1: required EzBakeBase.EzSecurityToken token) throws (
            1: EzBakeBase.EzSecurityTokenException security,
            2: CentralPurgeServiceException down)

    /**
     * This method allows the UI to mark an ageOffEvent as being resolved and supply a note regarding  the resolution of
     * the purge.
     *
     * Manual resolution of an ageOffEvent through the UI could happen for a couple reasons:
     *     * Not all documents could be automatically purged, so an admin is marking successful completion of the
     *       ageOffEvent.
     *     * One application is not properly responding to a purge and admin interaction is required
     *
     * When this method is called, the Central Purge Service should make final updates to any state regarding the
     * ageOffEvent stored elsewhere. This is done via that service’s updatePurge() method.
     *
     * When calling the provenance service’s updatePurge() method, the note should be included and resolved should be
     * set to True.
     *
     * @param token The token must be validated and only requests from within the this same application should be
     *              allowed. Others should throw EzSecurityTokenException.
     * @param purgId This is the purge that is being marked as resolved
     * @param notes Notes as to why this purge was manually resolved.
     */
    void resolveAgeOffEvent(
        1: required EzBakeBase.EzSecurityToken token,
        2: required i64 ageOffEventId,
        3: required string notes) throws (
            1: EzBakeBase.EzSecurityTokenException security,
            2: CentralPurgeServiceException down)

    CentralPurgeQueryResults getPagedSortedFilteredPurgeStates(
        1: required EzBakeBase.EzSecurityToken token,
        2: list<CentralPurgeStatus> statuses,
        3: i32 pageNum,
        4: i32 numPerPage) throws (
            1: EzBakeBase.EzSecurityTokenException security,
            2: CentralPurgeServiceException down)

    CentralAgeOffEventQueryResults getPagedSortedFilteredAgeOffEventStates(
        1: required EzBakeBase.EzSecurityToken token,
        2: list<CentralPurgeStatus> statuses,
        3: i32 pageNum,
        4: i32 numPerPage) throws (
            1: EzBakeBase.EzSecurityTokenException security,
            2: CentralPurgeServiceException down)
}
