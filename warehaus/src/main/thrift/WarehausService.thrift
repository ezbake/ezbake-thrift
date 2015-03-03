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

namespace * ezbake.warehaus

include "EzBakeBase.thrift"

/**
 * Type of data to return from a get call.
 */
enum GetDataType {
    RAW = 0,
    PARSED = 1,
    VIEW = 2
}

/**
 * Insert object.
 */
struct Repository {
    1: required string uri;
    2: required binary rawData;
    3: required binary parsedData;

    /**
     * Update visibility of old versions of this uri if its different from the new one. Old visibility is changed even
     * when making exclusive parsed or raw updates.
     */
    4: optional bool updateVisibility = false;
}

/**
 * Update object, the only difference being that the fields are optional.
 */
struct UpdateEntry {
    1: required string uri;
    2: optional binary rawData;
    3: optional binary parsedData;

    /**
     * Update visibility of old versions of this uri if its different from the new one. Old visibility is changed even
     * when making exclusive parsed or raw updates.
     */
    4: optional bool updateVisibility = false;
}

/**
 * URI with version/time info.
 */
struct DatedURI {
    1: required EzBakeBase.DateTime timestamp;
    2: required string uri;
    3: required EzBakeBase.Visibility visibility;
}

/**
 * ID for arbitrary data storage.
 */
struct ViewId {
    1: required string uri;
    2: required string spacename;
    3: required string view;
    //Pass in a specific timestamp to update a specific view
    4: optional EzBakeBase.DateTime timestamp;
    //Set this to true if this view should update the previous views with the same uri/spacename/view
    5: optional bool squashPrevious;
}

/**
 * Data return.
 */
struct BinaryReplay {
    1: required EzBakeBase.DateTime timestamp;
    2: required string uri;
    3: required binary packet;
    4: optional EzBakeBase.Visibility visibility;
}

/**
 * Stores versioning information (such as writer and reason).
 */
struct VersionControl {
    1: required binary packet;
    2: required string name; // this really is a misnomer, what's in here is the security ID
}

/**
 * Contains all the data to be stored for import/export for convenient serialization.
 */
struct ExportFile {
    1: required Repository data;
    2: required EzBakeBase.Visibility visibility;
    3: required string name;
    4: required i64 timestamp;
}

/**
 * Contains parameters based on which to get request.
 */
struct RequestParameter {
    1: required string uri;
    2: optional EzBakeBase.DateTime timestamp;
    3: optional string spacename; // required if requesting a View
    4: optional string view; // required if requesting a View
}

/**
 * Contains fields to request batch data by.
 */
struct GetRequest {
    1: required list<RequestParameter> requestParams;
    2: optional GetDataType getDataType = GetDataType.RAW;

    /**
     * true will get latest version of each uri, false will get a version based on uri timestamp
     */
    3: optional bool latestVersion = true;
}

/**
 * Encapsulates update entries to make bulk update.
 */
struct PutUpdateEntry {
    1: required UpdateEntry entry;
    2: required EzBakeBase.Visibility visibility;
}

/**
 * Contains fields needed to make a bulk insert.
 */
struct PutRequest {
    1: required list<PutUpdateEntry> entries;
}

/**
 * Contains details pertaining to a particular version of an entry.
 */
struct VersionDetail {
    1: required string uri;
    2: required i64 timestamp;
    3: required EzBakeBase.Visibility visibility;
    4: required string securityId;
}

/**
 * Contains all version details pertaining to a warehaus entry.
 */
struct EntryDetail {
    1: required string uri;
    2: required list<VersionDetail> versions;
}

/**
 * Enum to capture status of an ingest.
 */
enum IngestStatusEnum {
    /**
     * All requested documents were successfully ingested
     */
    SUCCESS = 0,

    /**
     * A partial set of documents were ingested
     */
    PARTIAL = 1,

    /**
     * All documents failed to ingest
     */
    FAIL = 2
}

/**
 * Encapsulates status of an ingest. Has the status, list of failed URIs (in case there are any failures) and the time
 * of ingest.
 */
struct IngestStatus {
    1: required i64 timestamp;
    2: required IngestStatusEnum status;
    3: optional list<string> failedURIs;
    4: optional string failureReason;
}

/**
 * Thrown if the given data type and URI do no exist in the warehaus.
 */
exception EntryNotInWarehausException {
    1: required string message;
}

/**
 * Thrown if data requested from get is greater than allowed max size.
 */
exception MaxGetRequestSizeExceededException {
    1: required string message;
}

const string SERVICE_NAME = "warehaus";

service WarehausService extends EzBakeBase.EzBakeBasePurgeService {
    /**
     * Insert a record.
     */
    IngestStatus insert(
        1: Repository data, 2: EzBakeBase.Visibility visibility, 3: EzBakeBase.EzSecurityToken security);

    /**
     * Get latest version of the relevant data segment.
     */
    BinaryReplay getLatestRaw(
        1: string uri, 2: EzBakeBase.EzSecurityToken security) throws (1: EntryNotInWarehausException e);

    BinaryReplay getLatestParsed(
        1: string uri, 2: EzBakeBase.EzSecurityToken security) throws (1: EntryNotInWarehausException e);

    /**
     * Get a specific version (using timestamp versioning) of the relevant data segment.
     */
    BinaryReplay getRaw(
        1: string uri,
        2: i64 version,
        3: EzBakeBase.EzSecurityToken security) throws (
            1: EntryNotInWarehausException e);

    BinaryReplay getParsed(
        1: string uri,
        2: i64 version,
        3: EzBakeBase.EzSecurityToken security) throws (
            1: EntryNotInWarehausException e);

    /**
     * Get a list of binary replays, given a GetRequest with list of uris of interest.
     */
    list<BinaryReplay> get(
        1: GetRequest getRequest,
        2: EzBakeBase.EzSecurityToken security) throws (
            1: MaxGetRequestSizeExceededException e);

    /**
     * Returns a list of URIs that have been ingested with the given URI prefix for the provided time period. URIs will
     * only be returned for parsed objects that have been ingested in that time period. The URI prefix is a required
     * parameter, while the start and finish parameters are optional. If start or finish are omitted, the time range
     * will be from the beginning of time or to the end of time respectively. The type parameter is also optional, and
     * defaults to PARSED. Currently we do not support replaying a VIEW type, so that will throw an exception if
     * selected. Returns in ascending temporal order. The uriPrefix is expected to conform to the URI schema e.g.
     * "CATEGORY://feed_name".
     */
    list<DatedURI> replay(
        1: string uriPrefix,
        2: bool replayOnlyLatest,
        3: EzBakeBase.DateTime start,
        4: EzBakeBase.DateTime finish,
        5: GetDataType type,
        6: EzBakeBase.EzSecurityToken security);

    /**
     * As replay but returns a count. ATM this actually gets the results and counts them as a placeholder so using it is
     * a bad idea.
     */
    i32 replayCount(
        1: string uriPrefix,
        2: EzBakeBase.DateTime start,
        3: EzBakeBase.DateTime finish,
        4: GetDataType type,
        5: EzBakeBase.EzSecurityToken security);

    /**
     * Returns a list of timestamps for the various versions to make sure the user knows what are valid version numbers.
     */
    list<i64> getVersions(1: string uri, 2: EzBakeBase.EzSecurityToken security);

    /**
     * As insert and get but for arbitrary data.
     */
    IngestStatus insertView(
        1: binary data,
        2: ViewId id,
        3: EzBakeBase.Visibility visibility,
        4: EzBakeBase.EzSecurityToken security);

    BinaryReplay getLatestView(
        1: ViewId id, 2: EzBakeBase.EzSecurityToken security) throws (1: EntryNotInWarehausException e);

    BinaryReplay getView(
        1: ViewId id,
        2: i64 timestamp,
        3: EzBakeBase.EzSecurityToken security) throws (
            1: EntryNotInWarehausException e);

    /**
     * Convenience function to import data from hadoop instead of across the wire.
     */
    void importFromHadoop(
        1: string filename, 2: EzBakeBase.Visibility visibility, 3: EzBakeBase.EzSecurityToken security);

    /**
     * Update data for a specific data type. This updates the document with updated raw/parsed data by adding a new
     * version of the entry.
     */
    IngestStatus updateEntry(
        1: UpdateEntry update, 2: EzBakeBase.Visibility visibility, 3: EzBakeBase.EzSecurityToken security);

    /**
     * Bulk update, given a PutRequest with list of entries.
     */
    IngestStatus put(1: PutRequest putRequest, 2: EzBakeBase.EzSecurityToken security);

    /**
     * Fetches all version details pertaining to an entry.
     */
    EntryDetail getEntryDetails(1: string uri, 2: EzBakeBase.EzSecurityToken security);
}
