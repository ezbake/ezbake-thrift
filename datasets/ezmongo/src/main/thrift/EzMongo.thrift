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

namespace * ezbake.data.mongo.thrift
namespace py ezbake.data.mongo.thriftapi
namespace go ezbake.data.mongo.thriftapi

include "EzBakeBase.thrift"
include "BaseDataService.thrift"

exception EzMongoBaseException {
    1: string message
}

struct MongoFindParams {
    1: optional string jsonQuery;
    2: optional string jsonProjection;
    3: optional string jsonSort;
    4: optional i32 skip;
    5: optional i32 limit;
    6: optional bool returnPlainObjectIdString;
}

struct MongoEzbakeDocument {
    1: required string jsonDocument;
    2: required EzBakeBase.Visibility visibility;
}

struct MongoUpdateParams {
    1: optional string jsonQuery;
    2: required MongoEzbakeDocument mongoDocument;
    3: optional bool updateWithOperators;
}

struct MongoDistinctParams {
    1: required string field;
    2: optional string query;
}

service EzMongo extends BaseDataService.BaseDataService {
    /**
     * Ensures index on the collection.
     */
    void ensureIndex(
        1: string collectionName,
        2: string jsonKeys,
        3: string jsonOptions,
        4: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);

    /**
     * Creates index on the collection.
     */
    void createIndex(
        1: string collectionName,
        2: string jsonKeys,
        3: string jsonOptions,
        4: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);

    /**
     * Returns serialized strings of MongoDB's DBObjects representing indexes on the collection.
     */
    list<string> getIndexInfo(
        1: string collectionName,
        2: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);

    /**
     * Checks if the collection exists in the database.
     */
    bool collectionExists(
        1: string collectionName,
        2: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);

    /**
     * Creates the collection in the database.
     */
    void createCollection(
        1: string collectionName,
        2: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);

    /**
     * Drops the collection from the database.
     */
    void dropCollection(
        1: string collectionName,
        2: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);

    /**
     * Returns the count of all records from jsonQuery in the collection.
     *
     */
    i64 getCount(
        1: string collectionName,
        2: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);

    /**
     * Returns the count of records from the jsonQuery in the collection. Note that to pass in the "_id" (ObjectId), the
     * jsonQuery should be in the form of: { "_id" : { "$oid" : "...." } }
     *
     * Also, the jsonQuery cannot have the "$match" and "$where" operators since the MongoDB aggregation pipeline is
     * used in the query.
     */
    i64 getCountFromQuery(
        1: string collectionName,
        2: string jsonQuery,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);

    /**
     * Performs a Text Search using Text Indexes. It expects the necessary text indexes have been created on the
     * collection prior to being called.
     */
    list<string> textSearch(
        1: string collectionName,
        2: string searchText,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);

    /**
     * Returns the records in serialized form of MongoDB's DBObjects from the jsonQuery, using the skip & limit values
     * and projecting the fields in jsonProjection. Note that to pass in the "_id" (ObjectId), the jsonQuery should be
     * in the form of: { "_id" : { "$oid" : "...." } }
     *
     * If returnPlainObjectIdString is true, it returns the _id as plain string instead of the $oid format.
     *
     * The jsonProjection cannot have 0 as the value for non _id fields since the MongoDB aggregation pipeline is used
     * in the query.
     *
     * Also, the jsonQuery cannot have the "$match" and "$where" operators since the MongoDB aggregation pipeline is
     * used in the query.
     */
    list<string> find(
        1: string collectionName,
        2: MongoFindParams mongoFindParams,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);

    /**
     * Returns the distinct values as returned by Mongo's db.collection.distinct(field, query) call. Note that to pass
     * in the "_id" (ObjectId), the jsonQuery should be in the form of: { "_id" : { "$oid" : "...." } }
     *
     * Also, the jsonQuery cannot have the "$match" and "$where" operators since the MongoDB aggregation pipeline is
     * used in the query.
     */
    list<string> distinct(
        1: string collectionName,
        2: MongoDistinctParams mongoDistinctParams,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);


    /**
     * Inserts the jsonDocument in the collection.
     */
    string insert(
        1: string collectionName,
        2: MongoEzbakeDocument mongoDocument,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);

    /**
     * Updates the records in the jsonQuery with the jsonDocument in the collection.
     *
     * If the updateWithOperators boolean parameter is true:
     *     Mongo update operators such as $set, $push, $pull can be used in the jsonDocument.
     * Else (updateWithOperators boolean parameter is false -- this is the default):
     *     Selective update is used (Mongo's "$set" operator is used in the update), meaning, only the fields passed in
     *     the jsonDocument will be updated, not overwriting the whole object.
     *
     * Currently, this uses "upsert" as false and "multi" as true in the Mongo update operation.
     *
     * If you don't wish to update the security fields (_ez* fields) of the document, the Visibility object in the
     * MongoEzbakeDocument can be be empty (no FormalVisibility/AdvancedMarkings set).
     *
     * Note that to pass in the "_id" (ObjectId), the jsonQuery should be in the form of:
     * { "_id" : { "$oid" : "...." } }
     *
     * Also, the jsonQuery cannot have the "$match" and "$where" operators since the MongoDB aggregation pipeline is
     * used in the query.
     */
    i32 update(
        1: string collectionName,
        2: MongoUpdateParams mongoUpdateParams,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);

    /**
     * Removes the records in the jsonQuery in the collection.
     *
     * Note that to pass in the "_id" (ObjectId), the jsonQuery should be in the form of:
     * { "_id" : { "$oid" : "...." } }
     *
     * Also, the jsonQuery cannot have the "$match" and "$where" operators since the MongoDB aggregation pipeline is
     * used in the query.
     */
    i32 remove(
        1: string collectionName,
        2: string jsonQuery,
        3: EzBakeBase.EzSecurityToken security) throws (1: EzMongoBaseException ezMongoBaseException);
}
