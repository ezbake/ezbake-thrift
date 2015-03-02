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

namespace * ezbake.data.elastic.thrift
namespace py ezbake.data.elastic.thriftapi

include "EzBakeBase.thrift"
include "BaseDataService.thrift"

union ScriptValue {
    1: string textValue;
    2: i32 intValue;
    3: double doubleValue;
    4: i64 longValue;
    5: bool booleanValue;
}

struct ScriptParam {
    1: string paramName;
    2: ScriptValue paramValue;
}

struct ValueScript {
    1: string script;
    2: list<ScriptParam> params;
}

struct KeyValueFacet {
    1: required string key_field_name;
    2: required string value_field;
}

struct KeyValueScript {
    1: required string keyScript;
    2: required string valueScript;
    3: optional list<ScriptParam> scriptParams;
}

union BaseFacetValue {
    1: string facetField;
    2: KeyValueFacet keyValueFacet;
    3: KeyValueScript keyValueScript;
}

// Histogram Facet
struct HistogramFacet {
    1: required i32 interval;
    2: required BaseFacetValue facetValue;
}

struct HistogramFacetEntry {
    1: i64 key;
    2: i64 count;
    3: double mean;
    4: double min;
    5: double max;
    6: double total;
    7: i64 totalCount;
}

struct HistogramFacetResult {
    1: list<HistogramFacetEntry> entries;
}

// Date Histogram Facet

enum DateIntervalType {
    YEAR = 1,
    QUARTER,
    MONTH,
    WEEK,
    DAY,
    HOUR,
    MINUTE
}

struct KeyValueDateScript {
    1: required string key_field;
    2: required string value_script;
    3: optional list<ScriptParam> scriptParams;
}

union DateField {
    1: string _field;
    2: KeyValueFacet keyValueDateField;
    3: KeyValueDateScript keyValueDateScript;
}

union DateInterval {
    1: string customInterval;
    2: DateIntervalType staticInterval;
}

struct DateHistogramFacet {
    1: required DateField field;
    2: required DateInterval interval;
    3: optional i32 factor;
    4: optional i16 post_zone_hours;
    5: optional i16 pre_zone_hours;
}

struct DateHistogramFacetEntry {
    1: i64 time;
    2: i64 count;
    3: double mean;
    4: double min;
    5: double max;
    6: double total;
    7: i64 totalCount;
}

struct DateHistogramFacetResult {
    1: list<DateHistogramFacetEntry> entries;
}

// Filter Facet

struct FilterFacet {
    1: required string luceneQuery;
}

struct FilterFacetResult {
    1: i64 count;
}

// Range Facet
enum RangeType {
    INTEGER,
    DOUBLE,
    DATE
}

struct FacetRange {
    1: required RangeType rangeType;
    2: optional string from;
    3: optional string to;
}

struct RangeFacet {
    1: required list<FacetRange> ranges;
    2: required BaseFacetValue field;
}

struct RangeFacetEntry {
    1: string from;
    2: string to;
    3: double min;
    4: double max;
    5: double mean;
    6: i64 count;
}

struct RangeFacetResult {
    1: list<RangeFacetEntry> entries;
}

// Terms Facet

enum FacetOrder {
    COUNT,
    TERM,
    REVERSE_COUNT,
    REVERSE_TERM
}

struct TermsFacet {
    1: required list<string> fields;
    2: optional FacetOrder order;
    3: optional list<string> exclude;
    4: optional string regex;
    5: optional i32 size;
    6: optional bool isScriptField;
    7: optional bool allTerms;
}

struct TermsFacetEntry {
    1: string term;
    2: i64 count;
}

struct TermsFacetResult {
    1: i64 totalCount;
    2: i64 otherCount;
    3: i64 missingCount;
    4: list<TermsFacetEntry> entries;
}

// Terms Script Facet

struct TermsScriptFacet {
    1: optional ValueScript script;
    2: optional string scriptField;
    3: optional list<string> fields;
    4: optional FacetOrder order;
    5: optional list<string> exclude;
    6: optional string regex;
    7: optional i32 size;
    8: optional bool allTerms;
}

// Statistical Facet

union StatisticalFacet {
    1: list<string> fields;   // Used for single or multi field Statistical Facet
    2: ValueScript script;    // Used for Statistical Script Facet
}

struct StatisticalFacetResult {
    1: i64 count;
    2: double max;
    3: double mean;
    4: double min;
    5: double stdDeviation;
    6: double sumOfSquares;
    7: double total;
    8: double variance;
}

// Terms Stats Facet

enum TermStatOrder {
    TERM,
    REVERSE_TERM,
    COUNT,
    REVERSE_COUNT,
    TOTAL,
    REVERSE_TOTAL,
    MIN,
    REVERSE_MIN,
    MAX,
    REVERSE_MAX,
    MEAN,
    REVERSE_MEAN
}

union TermsStatsValue {
    1: string valueField;
    2: ValueScript valueScript;
}

struct TermsStatsFacet {
    1: string keyField;
    2: TermsStatsValue valueField;
    3: TermStatOrder order;
    4: i32 size;
    5: bool allTerms;
}

struct TermsStatsFacetResultEntry {
    1: i64 count;
    2: i64 totalCount;
    3: double total;
    4: double mean;
    5: double max;
    6: double min;
    7: double termAsNumber;
    8: string term;
}

struct TermsStatsFacetResult {
    1: list<TermsStatsFacetResultEntry> entries;
}

// Facet

union FacetRequest {
    1: HistogramFacet histogramFacet;
    2: RangeFacet rangeFacet;
    3: FilterFacet filterFacet;
    4: TermsFacet termsFacet;
    5: DateHistogramFacet dateHistogramFacet;
    6: TermsStatsFacet termsStatsFacet;
    7: StatisticalFacet statisticalFacet;
    8: TermsScriptFacet termsScriptFacet;
}

union FacetResult {
    1: TermsFacetResult termsFacetResult;
    2: RangeFacetResult rangeFacetResult;
    3: DateHistogramFacetResult dateFacetResult;
    4: HistogramFacetResult histogramFacetResult;
    5: FilterFacetResult filterFacetResult;
    6: TermsStatsFacetResult termsStatsFacetResult;
    7: StatisticalFacetResult statisticalFacetResult;
}

struct Facet {
    1: required string label;
    2: required FacetRequest facet;
    3: optional string filterJSON;
}

/**
 * Sort order for sorting; ascending is A-Z, descending is Z-A lexicographically
 */
enum SortOrder {
    ASCENDING,
    DESCENDING
}

/**
 * Sort mode for arrays/multi-fields
 * @see: http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-sort.html
 */
enum SortMode {
    AVG,
    MAX,
    MIN,
    SUM
}

/**
 * Which end of the results to place the items that do not have the sorting field.
 */
enum MissingOrder {
    FIRST,
    LAST
}

/**
 * Specified the way to sort items when they are missing the sorting field. If custom is specified that value will be
 * used to sort any items that are missing.
 */
union MissingSort {
    1: MissingOrder basic;
    2: string custom;
}

/**
 * A geo value used for comparisons  in sorting. For example, to sort by a distance from a point `coordinate`.
 */
union GeoSortValue {
    1: string geoHash;
    2: EzBakeBase.Coordinate coordinate;
}

/**
 * Unit of distance to use for sorting
 */
enum DistanceUnit {
    CENTIMETERS,
    INCH,
    KILOMETERS,
    METERS,
    MILES,
    MILLIMETERS,
    YARD
}

/**
 * Defines a geo-distance sort on a field mapped as a geospatial type.
 */
struct GeoDistanceSort {
    /**
     * The name of the field to sort on (must be mapped as a geospatial type)
     */
    1: required string field;

    /**
     * The order to sort
     */
    2: required SortOrder order;

    /**
     * The unit of distance to use
     */
    3: required DistanceUnit unit;

    /**
     * The value to compare against to compute distance
     */
    4: required GeoSortValue value;

    /**
     * Sort mode (geo supports MIN, MAX, and AVG)
     */
    5: optional SortMode mode;
}

/**
 * Defines a lexicographic sort on a given field
 */
struct FieldSort {
    /**
     * The name of the field to sort on
     */
    1: required string field;

    /**
     * The order to sort
     */
    2: required SortOrder order;

    /**
     * The sorting mode for array/multi-value fields
     */
    3: optional SortMode mode;

    /**
     * What to do with missing values
     */
    4: optional MissingSort missing;

    /**
     * If true ES will ignore sorting fields that are not mapped on the type
     */
    5: optional bool ignoreUnmapped;
}

/**
 * Sorting criteria for a query, either a geo sort or a normal field sort.
 */
union SortCriteria {
    1: GeoDistanceSort geoSort;
    2: FieldSort fieldSort;
}

/**
 * Options for an update operation
 */
struct UpdateOptions {
    /**
     * Number of times to retry an update before failing
     */
    1: optional i32 retryCount = 0;
}

/**
 * A script to update an existing document.
 */
struct UpdateScript {
    /**
     * The MVEL script to execute
     */
    1: optional string script;

    /**
     * Parameters to pass to the script (surround strings in quotes)
     */
    2: optional map<string, string> parameters;
}

/**
 * A field to return for highlighting including parameters for surrounding fragments to return.
 */
struct HighlightedField {
    /**
     * Name of the field to highlight
     */
    1: required string field;

    /**
     * Approximate characters to return for the fragment
     */
    2: optional i32 fragmentSize = 100;

    /**
     * Number of fragments
     */
    3: optional i32 numberOfFragments = 5;
}

/**
 * A request to highlight a set of fields
 */
struct HighlightRequest {
    /**
     * Set of fields to highlight
     */
    1: required set<HighlightedField> fields;

    /**
     * Order to highlight
     */
    2: optional string order;

    /**
     * Tags to begin fragments (default <em>)
     */
    3: optional list<string> pre_tags;

    /**
     * Tags to end fragments (default </em>)
     */
    4: optional list<string> post_tags;

    /**
     * Schema for tags
     */
    5: optional string tags_schema;

    /**
     * Whether to require a field match to highlight
     */
    6: optional bool requireFieldMatch;
}

/**
 * Result of highlighting
 */
struct HighlightResult {
    /**
     * Map from field name => [fragments...]
     */
    1: required map<string, list<string>> results;
}

/**
 * Defines options for percolating documents upon insert
 */
struct PercolateRequest {
    /**
     * Filter JSON to filter out queries that should not applySettings
     */
    1: optional string filterJson;

    /**
     * Maximum number of queries to return
     */
    2: optional i32 maxMatches = 50;

    /**
     * Facets to request for the returned queries
     */
    3: optional list<Facet> facets;
}

/**
 * A percolate query to be registered with the percolator
 */
struct PercolateQuery {
    /**
     * The query to register as an ES query (used only during insertion, not percolation)
     */
    1: optional string queryDocument;

    /**
     * The visibility of this query
     */
    2: optional EzBakeBase.Visibility visibility;

    /**
     * The id of this percolate query
     */
    3: optional string id;

    /**
     * The id of the matching document (used only during percolation, not insertion)
     */
    4: optional string matchingDocId

    /**
     * The authorizations to use when adding the visibility filter to this percolator query
     * (used only during insertion, not percolation)
     */
    5: optional EzBakeBase.Authorizations authorizations
}

/**
 * A page of results
 */
struct Page {
    /**
     * Offset as the number of items since the start of the result list
     */
    1: required i32 offset;

    /**
     * Number of items in this page
     */
    2: required i16 pageSize;
}

/**
 * Query object for use with searching.
 */
struct Query {
    /**
     * A Lucene query string or ES JSON query
     */
    1: required string searchString;

    /**
     * A type to restrict the search to
     */
    2: optional string type;

    /**
     * A page of results to request
     */
    3: optional Page page;

    /**
     * Sorting criteria
     */
    4: optional list<SortCriteria> sortCriteria;

    /**
     * Requests for facets on the results
     */
    5: optional list<Facet> facets;

    /**
     * A subset of the fields to return
     */
    6: optional set<string> returnedFields;

    /**
     * ES filter JSON to add
     */
    7: optional string filterJson;

    /**
     * Highlighting information to return
     */
    8: optional HighlightRequest highlighting;
}

/**
 * A document to insert
 */
struct Document {
    /**
     * Elastic type to search
     */
    1: required string _type;

    /**
     * Visibility to control who has access to this document
     */
    2: required EzBakeBase.Visibility visibility;

    /**
     * JSON of document
     */
    3: required string _jsonObject

    /**
     * Elastic Version ID
     */
    4: optional i64 _version;

    /**
     * Elastic document ID
     */
    5: optional string _id;

    /**
     * Percolate request
     */
    6: optional PercolateRequest percolate;
}

/**
 * Results of a search
 */
struct SearchResult {
    /**
     * Documents matching the search
     */
    1: required list<Document> matchingDocuments;

    /**
     * Total number of results across all pages
     */
    2: required i64 totalHits;

    /**
     * Paging offset
     */
    3: required i32 offset;

    /**
     * Page size
     */
    4: required i16 pagesize;

    /**
     * JSON query that created these results
     */
    5: required string actualQuery;

    /**
     * Map of facet name (from ImageSearch) to its results
     */
    6: optional map<string, FacetResult> facets;

    /**
     *  Maps from doc id => highlight result
     */
    7: optional map<string, HighlightResult> highlights;
}

/**
 * This is the response when a document is indexed (inserted).
 */
struct IndexResponse {
    /**
     * The type the document was inserted under
     */
    1: required string _type;

    /**
     * The id of the inserted document
     */
    2: required string _id;

    /**
     * The ES version (unrelated to EzElastic)
     */
    3: required i64 _version;

    /**
     * True if the index operation succeeded, otherwise false.
     */
    4: optional bool success = true;

    /**
     * If percolation was requested this holds the queries that matched
     */
    5: optional list<PercolateQuery> percolateResults;
}

/**
 * Used to pass unique document identifiers around
 */
struct DocumentIdentifier {
    /**
     * Elastic document ID
     */
    1: required string id;

    /**
     * Elastic type
     */
    2: optional string type;
}

/**
 * Exception thrown when requested field(s) could not be found in the document
 */
exception FieldsNotFound {
    /**
     * Elastic ID for document for which field(s) were missing
     */
    1: required string _id;

    /**
     * Elastic type field for document for which field(s) were missing
     */
    2: required string _type;

    /**
     * The field(s)s that were missing
     */
    3: required list<string> fields;

    /**
     * Message giving context to why and where error occurred
     */
    4: optional string message;
}

/**
 * Exception thrown when a document could not be indexed/inserted into Elasticsearch
 */
exception DocumentIndexingException {
    /**
     * Elastic type field into which the document indexing attempt occurred
     */
    1: required string _type

    /**
     * Message giving context to why and where error occurred
     */
    2: required string message

    /**
     * Elastic ID for document
     */
    3: optional string _id
}

/**
 * Exception thrown when a search query could not be parsed and is otherwise invalid
 */
exception MalformedQueryException {
    /**
     * Query string that was malformed
     */
    1: required string query

    /**
     * Message giving context to why and where error occurred
     */
    2: required string message
}

service EzElastic extends BaseDataService.BaseDataService {
    //
    // Index Operations - Insert and Update
    //

    /**
     * If no document exists with the supplied id (or if no id was specified), the document will be added.
     */
    IndexResponse put(
        1: Document document, 2: EzBakeBase.EzSecurityToken userToken) throws (1: DocumentIndexingException failure);

    /**
     * Updates a document using a script
     */
    IndexResponse update(
        1: DocumentIdentifier id,
        2: UpdateScript script,
        3: UpdateOptions options,
        4: EzBakeBase.EzSecurityToken userToken);

    //
    // Get Operations
    //

    /**
     * Retrieves the document with the supplied ID
     */
    Document get(1: string _id, 2: EzBakeBase.EzSecurityToken userToken);

    /**
     * Retrieves the document with the supplied ID and type
     */
    Document getWithType(1: string _id, 2: string _type, 3: EzBakeBase.EzSecurityToken userToken);

    /**
     * Retrieves a subset of fields for the document with the supplied ID and type
     */
    Document getWithFields(
        1: string _id,
        2: string _type,
        3: set<string> fields,
        4: EzBakeBase.EzSecurityToken userToken) throws (1: FieldsNotFound invalidFields);

    //
    // Query Operations
    //

    /**
     * Retrieves documents based on the given Query including sorting and paging.
     */
    SearchResult query(
        1: Query query,
        2: EzBakeBase.EzSecurityToken userToken) throws (1: MalformedQueryException malformedQueryException);

    //
    // Delete Operations
    //

    /**
     * Deletes documents with the given ID across all types
     */
    void deleteById(1: string _id, 2: EzBakeBase.EzSecurityToken userToken);

    /**
     * Deletes the document with the given ID within the supplied type
     */
    void deleteWithType(1: string _id, 2: string _type, 3: EzBakeBase.EzSecurityToken userToken);

    /**
     * Deletes documents matching the given query across all types
     */
    void deleteByQuery(
        1: string query,
        2: EzBakeBase.EzSecurityToken userToken) throws (1: MalformedQueryException malformedQueryException);

    /**
     * Deletes documents matching the given query within the supplied type
     */
    void deleteByQueryWithType(
        1: string query,
        2: string _type,
        3: EzBakeBase.EzSecurityToken userToken) throws (1: MalformedQueryException malformedQueryException);

    //
    // Bulk Operations
    //

    /**
     * Insert multiple documents. For each document, if no document exists with the supplied id (or if no id was
     * specified), the document will be added.
     */
    list<IndexResponse> bulkPut(
        1: list<Document> documents,
        2: EzBakeBase.EzSecurityToken userToken) throws (1: DocumentIndexingException failure);

    /**
     * Retrieves multiple documents with the given IDs within the supplied type
     */
    list<Document> bulkGetWithType(1: set<string> ids, 2: string _type, 3: EzBakeBase.EzSecurityToken userToken);

    /**
     * Deletes multiple documents with the given IDs across all types
     */
    void bulkDelete(1: set<string> ids, 2: EzBakeBase.EzSecurityToken userToken);

    /**
     * Deletes multiple documents with the given IDs within the supplied type
     */
    void bulkDeleteWithType(1: set<string> ids, 2: string _type, 3: EzBakeBase.EzSecurityToken userToken);

    //
    // Count Operations
    //

    /**
     * Counts the number of documents matching the query across all types
     */
    i64 countByQuery(
        1: string query,
        2: EzBakeBase.EzSecurityToken userToken) throws (1: MalformedQueryException malformedQueryException);

    /**
     * Counts the number of documents within the given types
     */
    i64 countByType(1: set<string> types, 2: EzBakeBase.EzSecurityToken userToken);

    /**
     * Counts the number of documents matching the given query across the supplied types
     */
    i64 countByQueryAndType(
        1: set<string> types,
        2: string query,
        3: EzBakeBase.EzSecurityToken userToken) throws (1: MalformedQueryException malformedQueryException);

    //
    // Percolate Operations
    // These operations deal specifically with ElasticSearch's Percolator Query's. Here is the link to the official
    // documentation: http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-percolate.html
    //

    /**
     * Add a percolate query to the index
     *
     * PercolateQuery is the thrift wrapper for the query to be stored. The document id field is not used for this
     * method.
     *
     * Note: If the authorization field in PercolateQuery is set then that will be used as the authorization
     * for the query. That authorization is checked against the token passed in to verify the query's authorizations.
     * If the percolateQuery authorizations field is null then the usertoken's authorizations will be used.
     * IndexResponse is the thrift wrapper for the ElasticSearch response to the insertion.
     */
    IndexResponse addPercolateQuery(1: PercolateQuery query, 2: EzBakeBase.EzSecurityToken userToken);

    /**
     * Remove a percolate query by the given ID
     *
     * Id is the id of the percolator to be removed.
     * The bool thats returned says whether the method succeeded or not.
     */
    bool removePercolateQuery(1: string id, 2: EzBakeBase.EzSecurityToken userToken);

    /**
     * Performs a multi-percolate operation with the given documents
     *
     * List<Documents> is the documents that will be percolated.
     * List<PercolateQuery> is the PercolateQueries that match the documents. Each PercolateQuery will have the
     * document id field set with the document it matched (one to one relationship).
     *
     * Note: if the ezelastic.post.filter.percolate.queries config parameter is true then a post filter will be applied
     * in EzElastic to verify that the user can has access to the percolateQueries returned
     */
    list<PercolateQuery> percolate(1: list<Document> documents, 2: EzBakeBase.EzSecurityToken userToken);

    /**
     * Performs a multi-percolate operation with the given ids
     *
     * List<String> the ids of documents that are already in ElasticSearch and to be percolated
     *  List<PercolateQuery> is the PercolateQueries that match the documents. Each PercolateQuery will have the
     * document id field set with the document it matched (one to one relationship).
     *
     * Note: if the ezelastic.post.filter.percolate.queries config parameter is true then a post filter will be applied
     * in EzElastic to verify that the user can has access to the percolateQueries returned
     */
    list<PercolateQuery> percolateByIds(
        1: list<string> ids, 2: string type, 3: i32 maxMatches, 4: EzBakeBase.EzSecurityToken userToken);

    /**
     * Retrieves documents based on the given Query including sorting and paging.
     *
     * Query is a thrift wrapper for numerous variables when searching ElasticSearch
     * SearchResult is a thrift wrapper for numerous variables when returning a search from ElasticSearch
     */
    SearchResult queryPercolate(
        1: Query query,
        2: EzBakeBase.EzSecurityToken userToken) throws (1:MalformedQueryException malformedQueryException);

    //
    // Index Admin Operations
    //

    /**
     * Open the index for use
     */
    void openIndex(1: EzBakeBase.EzSecurityToken userToken);

    /**
     * Close the index
     */
    void closeIndex(1: EzBakeBase.EzSecurityToken userToken);

    /**
     * Apply the given settings to the index
     */
    void applySettings(1: string settingsJson, 2: EzBakeBase.EzSecurityToken userToken);

    /**
     * Set/add a type mapping to the index
     */
    void setTypeMapping(1: string type, 2: string mappingJson, 3: EzBakeBase.EzSecurityToken userToken);

    /**
     * Force a refresh of the index
     */
    void forceIndexRefresh(1: EzBakeBase.EzSecurityToken userToken);
}
