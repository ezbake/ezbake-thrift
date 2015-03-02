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

namespace * ezbake.data.mongo.driver.thrift
namespace py ezbake.data.mongo.driver.thriftapi

include "EzBakeBase.thrift"
include "EzMongo.thrift"

struct EzInsertRequest {
    1: binary dbObjectList,
    2: binary writeConcern,
    3: binary dbEncoder;
    4: bool isUnitTestMode;
}

struct EzUpdateRequest {
    1: binary query,
    2: binary dbUpdateObject,
    3: bool upsert,
    4: bool multi,
    5: binary writeConcern,
    6: binary dbEncoder;
    7: bool isUnitTestMode;
}

struct EzCreateIndexRequest {
    1: binary dbObjectKeys,
    2: binary dbObjectOptions,
    3: binary dbEncoder;
}

struct EzFindRequest {
    1: binary ref,
    2: binary fields,
    3: i32 numToSkip,
    4: i32 batchSize,
    5: i32 limit,
    6: i32 options,
    7: binary readPref,
    8: binary decoder;
    9: binary encoder;
    10: string collection;
}

struct EzAggregationRequest {
    1: binary pipeline, // in Java: List<DBObject>
    2: binary options, // AggregationOptions
    3: binary readPref; // ReadPreference
}

struct EzWriteResult {
    1: binary writeResult,
    2: optional binary mongoexception;
}

struct ResultsWrapper {
    1: string requestId,
    2: binary resultSet,
    3: binary responseData,
    4: bool resultSetValid,
    5: i16 rowsEffected,
    6: optional binary mongoexception;
}

struct EzGetMoreRequest {
    1: binary outmessage,
    2: binary decoder;
    3: string queryResultIteratorHashcode;
}

struct EzRemoveRequest {
    1: binary dbObjectQuery,
    2: binary writeConcern,
    3: binary dbEncoder;
}

struct EzGetMoreResponse {
    1: binary response,
    2: binary resultSet,
    3: optional binary mongoexception;
}

struct EzParallelScanResponse {
    1: binary listOfCursors,
    2: binary mapOfIterators;
}

struct EzParallelScanOptions {
    1: binary options;
}

exception EzMongoDriverException {
    1: binary ex;
}

service EzMongoDriverService extends EzMongo.EzMongo {
    bool authenticate_driver(1: EzBakeBase.EzSecurityToken security);

    ResultsWrapper find_driver(
        1: string collection,
        2: EzFindRequest request,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoDriverException ezMongoDriverException);

    ResultsWrapper aggregate_driver(
        1: string collection,
        2: EzAggregationRequest request,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoDriverException ezMongoDriverException);

    EzWriteResult insert_driver(
        1: string collection,
        2: EzInsertRequest request,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoDriverException ezMongoDriverException);

    EzWriteResult update_driver(
        1: string collection,
        2: EzUpdateRequest request,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoDriverException ezMongoDriverException);

    ResultsWrapper drop_driver(
        1: string collection,
        2: EzBakeBase.EzSecurityToken security) throws (1: EzMongoDriverException ezMongoDriverException);

    EzWriteResult createIndex_driver(
        1: string collection,
        2: EzCreateIndexRequest request,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoDriverException ezMongoDriverException);

    EzGetMoreResponse getMore_driver(
        1: string collection,
        2: EzGetMoreRequest request,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoDriverException ezMongoDriverException);

    EzParallelScanResponse parallelScan_driver(
        1: string collection,
        2: EzParallelScanOptions options,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoDriverException ezMongoDriverException);

    EzWriteResult remove_driver(
        1: string collection,
        2: EzRemoveRequest request,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoDriverException ezMongoDriverException);

    // DBTCPConnector methods
    i32 getMaxBsonObjectSize_driver(
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoDriverException ezMongoDriverException);
}
