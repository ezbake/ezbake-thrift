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

namespace * ezbake.quarantine.thrift
namespace py ezbake.quarantine.thriftapi

include "EzBakeBase.thrift"

const string SERVICE_NAME = "quarantine";

/**
 * This exception is thrown whenever a query is made on a quarantined object that does not exist.
 */
exception ObjectNotQuarantinedException {
    1: required string message;
}

/**
 * This exception is thrown whenever a client attempts to update the status of a quarantined object to an invalid state.
 */
exception InvalidUpdateException {
    1: required string message;
}

/**
 * This object represents the result of an import operation.
 */
struct ImportResult {
    1: optional i64 totalRecords;
    2: optional i64 recordsImported;
    3: optional i64 duplicateRecords;
}

/**
 * This enum describes the state of an entry in quarantine.
 */
enum ObjectStatus {
    /**
     * This represents an entry that has been sent to quarantine, but has not been approved for reingest.
     */
    QUARANTINED,

    /**
     * This represents an entry that has been approved by an administrator to be reingested by the source pipeline.
     */
    APPROVED_FOR_REINGEST,

    /**
     * This represents an entry that has not been approved for reingest, but will remain in the system. An entry could
     * move from ARCHIVED back to APPROVED_FOR_REINGEST or QUARANTINED.
     */
    ARCHIVED,

    /**
     * This represents an entry that was sent as raw data to quarantine. If raw data is sent, it cannot be reingested
     * automatically.
     */
    CANNOT_BE_REINGESTED,

    /**
     * This represents an entry that has been approved and sent back to a pipeline to be reingested.
     */
    REINGESTED,

    /**
     * This represents an entry that is being prepared for reingest. We have two states for fault tolerant purposes as
     * well as making sure that one item is not reingested multiple times.
     */
    PREPARED_TO_REINGEST
}

/**
 * This struct encapsulates a piece of data that has been sent to quarantine. The associated metadata is used to
 * reingest the data if possible, as well as provide some context around what happened to cause the data to be
 * quarantined.
 */
struct QuarantinedObject {
    /**
     * The pipeline from which the quarantined object was sent.
     */
    1: optional string pipelineId;

    /**
     * The pipe from which the quarantined object was sent.
     */
    2: optional string pipeId;

    /**
     * The serialized object, or raw content, that is being quarantined.
     */
    3: optional binary content;

    /**
     * Represents if the object being quarantined is serializable. If so, the Quarantine system will attempt to reingest
     * the object back through its originating pipeline.
     */
    4: optional bool   serializable = 1;

    /**
     * The visibility associated with the provided quarantined object.
     */
    5: required EzBakeBase.Visibility visibility;

    /**
     * The application name of the process from which the quarantined object was sent.
     */
    7: optional string applicationName;
}

/**
 * This enum represents a type of event in quarantine.
 */
enum EventType {
    /**
     * This type represents an error that has occurred which has caused an item to become quarantined.
     */
    ERROR,

    /**
     * This type represents an update in status made by human interaction.
     */
    STATUS_UPDATE
}

/**
 * Each metadata entry that can be associated with a particular quarantine event. If a visibility is not provided the
 * metadata entry's visibility will be set at system high visibility.
 */
struct MetadataEntry {
    1: optional string value;
    2: optional EzBakeBase.Visibility visibility;
}

/**
 * Additional metadata that would assist an admin or developer in diagnosing the issue that caused this object to be
 * sent to quarantine. Examples of additional metadata may be metadata from the object being quarantined, a stack trace
 * describing an exception that was thrown during processing, or any other situational data.
 */
struct AdditionalMetadata {
    1: optional map<string, MetadataEntry> entries;
}

/**
 * This struct represents a particular time that the object was placed into quarantine. The timestamp represents the
 * most recent time that the object was quarantined with the given error message.
 *
 * TODO add more docs here
 */
struct QuarantineEvent {
    1: optional string event;
    2: optional EventType type;
    3: optional i64 timestamp;
    4: optional string id;
    5: optional string pipelineId;
    6: optional string pipeId;
    7: optional AdditionalMetadata additionalMetadata;
}

/**
 * This struct is used when we correlate an event with a count for that event.
 */
struct EventWithCount {
    1: optional QuarantineEvent event;
    2: optional ObjectStatus status;
    3: optional i64 count;
}

/**
 * This struct represents a single returned quarantine entry. It includes the ID and timestamp that are generated when
 * an object is placed in quarantine.
 */
struct QuarantineResult {
    1: optional string id;
    2: optional ObjectStatus status;
    3: optional QuarantinedObject object;
    4: optional list<QuarantineEvent> events;
}

/**
 * This struct contains encrypted data that has been exported from an instance of Quarantine. It is to be imported into
 * another instance of Quarantine for testing/debugging purposes.
 */
struct ExportedData {
    1: optional binary salt;
    2: optional binary initializationVector;
    3: optional binary encryptedContent;
}

/**
 * This struct simply wraps a list of QuarantineResult objects.
 */
struct ResultList {
    1: optional list<QuarantineResult> results;
}

/**
 * This struct encapsulates the ID, status, and timestamp for a given Quarantined object.
 */
struct IdAndStatus {
    1: optional string id;
    2: optional ObjectStatus status;
    3: optional i64 timestamp;
}

/**
 * This struct represents the response of an query for IDs.
 */
struct IdsResponse {
    1: optional list<IdAndStatus> ids;
    2: optional i64 totalResults;
}

service Quarantine extends EzBakeBase.EzBakeBaseService {
    /**
     * Send an object to quarantine. The object's status will be set to QUARANTINED if the serializable flag is set to
     * true, otherwise it will be CANNOT_BE_REINGESTED as it cannot be reingested if it is not a serializable object.
     * The error parameter is required and is used to correlate objects that were sent to Quarantine for similar
     * reasons. For example, if the object was quarantined because a service was down, then the error string may read:
     *     "Could not index object because the Warehouse service is down".
     * The additional metadata object is optional (set to null if not used), and can be used to provide additional
     * contextual information. For example, the warehouse URI for the object being parsed may be useful (if the raw
     * data is in the warehouse). One could also add a full stacktrace for more detailed error information.
     */
    oneway void sendToQuarantine(
        1: QuarantinedObject qo,
        2: string error,
        3: AdditionalMetadata additionalMetadata,
        4: EzBakeBase.EzSecurityToken token);

    /**
     * Returns a list of IDs of thrift objects that have the provided status. If the status is ALL then every object
     * for this pipeline will be returned.
     */
    list<string> getObjectsForPipeline(
        1: string pipelineId,
        2: set<ObjectStatus> statuses,
        3: i32 pageNumber,
        4: i32 pageSize,
        5: EzBakeBase.EzSecurityToken token) throws (
            1: ObjectNotQuarantinedException e);

    /**
     * Returns a map of Pipe ID to number of events in that Pipe. The number of events can be faceted based on the
     * object status that is provided in the call.
     */
    set<EventWithCount> getObjectCountPerPipe(
        1: string pipelineId, 2: set<ObjectStatus> statuses, 3: EzBakeBase.EzSecurityToken token);

    /**
     * Gets the latest event for the given pipeline.
     */
    EventWithCount getLatestEventForPipeline(
        1: string pipelineId, 2: set<ObjectStatus> statuses, 3: EzBakeBase.EzSecurityToken token);

    /**
     * Gets the latest event for the given pipeline and pipe.
     */
    QuarantineEvent getLatestEventForPipe(
        1: string pipelineId, 2: string pipeId, 3: set<ObjectStatus> statuses, 4: EzBakeBase.EzSecurityToken token);

    /**
     * Returns a map of Event text to count for a specific pipe in a pipeline. This can be used to get the different
     * error messages, and their corresponding counts per Pipe.
     */
    set<EventWithCount> getEventCountPerPipe(
        1: string pipelineId, 2: string pipeId, 3: set<ObjectStatus> statuses, 4: EzBakeBase.EzSecurityToken token);

    /**
     * Returns count of the aggregated count of events in all pipes for the given pipelineId
     */
    i64 getCountPerPipe(
        1: string pipelineId, 2: string pipeId, 3: set<ObjectStatus> statuses, 4: EzBakeBase.EzSecurityToken token);

    /**
     * Returns a list of IDs of quarantined objects that correspond to the given pipeline ID, pipe ID, event (error or
     * status update message), and status
     */
    IdsResponse getObjectsForPipeAndEvent(
        1: string pipelineId,
        2: string pipeId,
        3: string event,
        4: set<ObjectStatus> statuses,
        5: i32 pageNumber,
        6: i32 pageSize,
        7: EzBakeBase.EzSecurityToken token) throws (
            1: ObjectNotQuarantinedException e);

    /**
     * Gets a list of quarantined objects by ID.
     */
    list<QuarantineResult> getQuarantinedObjects(
        1: list<string> ids, 2: EzBakeBase.EzSecurityToken token) throws (1: ObjectNotQuarantinedException e);

    /**
     * Updates the entries corresponding to the given list of IDs to the provided status.
     */
    void updateStatus(
        1: list<string> ids,
        2: ObjectStatus status,
        3: string updateComment,
        4: EzBakeBase.EzSecurityToken token) throws (
            1: InvalidUpdateException e);

    void updateStatusOfEvent(
        1: string pipelineId,
        2: string pipeId,
        3: ObjectStatus oldStatus,
        4: ObjectStatus newStatus,
        5: string oldEvent,
        6: string updateComment,
        7: EzBakeBase.EzSecurityToken token) throws (
            1: InvalidUpdateException e);

    /**
     * Deletes the provided list of object IDs from quarantine.
     */
    void deleteFromQuarantine(
        1: list<string> ids, 2: EzBakeBase.EzSecurityToken token) throws (1: ObjectNotQuarantinedException e);

    /**
     * Exports quarantined objects so that they can be imported into a different instance of Quarantine.
     */
    binary exportData(
        1: list<string> ids,
        2: string key,
        3: EzBakeBase.EzSecurityToken token) throws (
            1: ObjectNotQuarantinedException e);

    /**
     * Imports quarantined objects that have been exported from another instance of Quarantine.
     */
    ImportResult importData(1: binary dataToImport, 2: string key, 3: EzBakeBase.EzSecurityToken token);

    void deleteObjectsByEvent(
        1: string pipelineId,
        2: string pipeId,
        3: ObjectStatus status,
        4: string eventText,
        5: EzBakeBase.EzSecurityToken token);

    /**
     * Retrieves all pipeline names with data in quarantine for the user associated with the provided token
     */
    list<string> getPipelinesForUser(1: EzBakeBase.EzSecurityToken token);
}
