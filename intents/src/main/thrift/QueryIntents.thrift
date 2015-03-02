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

namespace * ezbake.query.intents

include "EzBakeBase.thrift"
include "BaseIntents.thrift"
include "cli_service.thrift"

enum IntentType {
    ACTIVITY,
    EQUIPMENT,
    EVENT,
    FACILITY,
    IMAGE,
    ISSUE,
    LOCATION,
    PERSON,
    REPORT,
    RELATIONSHIP,
    STATE,
    UNIT
}

enum BinaryOperator {
    LT, LE, EQ, NE, GE, GT
}

struct Activity {
    1: required BaseIntents.StandardObject base;
    2: optional string name;
    3: optional string country;
    4: optional string type;
}

struct Equipment {
    1: required BaseIntents.StandardObject base;
    2: optional string name;
    3: optional string equipmentCode;
    4: optional string country;
    5: optional bool isTransient;
}

struct Event {
    1: required BaseIntents.StandardObject base;
    2: optional string name;
    3: optional string country;
    4: optional string type;
}

struct Facility {
    1: required BaseIntents.StandardObject base;
    2: optional string name;
    3: optional string BENumber;
    4: optional string type;
    5: optional list<EzBakeBase.Coordinate> coordinates;
}

struct Image {
    1: required BaseIntents.BaseContext base;
    2: required string name;
    3: optional string URI;
}

struct Issue {
    1: required BaseIntents.StandardObject base;
    2: optional string name;
    3: optional string type;
    4: optional bool isTransient;
}

struct Location {
    1: required BaseIntents.BaseContext base;
    2: required double latitude;
    3: required double longitude;
    4: optional double altitude;

    /**
     * Degrees CW
     */
    5: optional double lineOfBearing;

    /**
     * Latitude of collectors position
     */
    6: optional double lobLatitude;

    /**
     * Longitude of collectors position
     */
    7: optional double lobLongitude;

    /**
     * Possibly BE number
     */
    8: optional string placeName;

    /**
     * Error ellipse semi-major axis (nmi)
     */
    9: optional double semimajorErrorAxis;

    /**
     * Error ellipse semi-minor axis (nmi)
     */
    10: optional double semiminorErrorAxis;

    /**
     * Circular error for error ellipse
     */
    11: optional double circularErrorProb;

    /**
     * Degrees CW from true north of error ellipse
     */
    12: optional double orientationAngle;

    /**
     * Course angle in degrees CW from true north (extrapolated)
     */
    13: optional double course;

    14: optional double speed;
    15: optional string serialNumber;
    16: optional string collectionType;
    17: optional string locationConfidence;
    18: optional string description;
}

struct Operator {
    1: required BinaryOperator name;
    2: required string text;
    3: required string notation;
}

enum ColumnType {
    STRING,
    BOOLEAN,
    INT,
    LONG,
    DOUBLE,
    DATETIME
}

struct ColumnDef {
    1: required string name;
    2: required string text;
    3: required ColumnType type;
}

struct IntentTypeTable {
    1: required IntentType name;
    2: required string text;
    3: required list<ColumnDef> columns;
}

struct Metadata {
    1: required list<Operator> operators;
    2: required list<string> relations;
    3: required list<IntentTypeTable> intentTypes;
}

struct Person {
    1: required BaseIntents.StandardObject base;
    2: optional string firstName;
    3: optional string middleName;
    4: optional string lastName;
    5: optional list<string> aliases;
    6: optional string country;
    7: optional string type;
    8: optional string tkbId;
    9: optional string tideId;
    10: optional EzBakeBase.DateTime birthDate;
}

union ColumnValue {
    1: bool boolValue;
    2: i32 integerValue;
    3: i64 longValue;
    4: double doubleValue;
    5: string stringValue;
}

union PredicateValue {
    1: string column;
    2: ColumnValue value;
}

struct BinaryPredicate {
    1: required string columnName;
    2: required BinaryOperator binaryOperator;
    3: required ColumnValue value;
}

struct UnaryPredicate {
    1: required string predicateName;
    2: required list<PredicateValue> values;
}

union Predicate {
    1: BinaryPredicate binaryPredicate;
    2: UnaryPredicate unaryPredicate;
}

struct QueryAtom {
    1: required IntentType intent;
    // A list of conjunctive (AND) clauses, each of which contains a list of disjunctive (OR) binary predicates.
    2: required list<list<Predicate>> predicates;
}

struct QueryJoin {
    1: required QueryAtom query;
    2: required string joinColumn;
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
 * Sort order for sorting; ascending is A-Z, descending is Z-A lexicographically
 */
enum SortOrder {
    ASCENDING,
    DESCENDING
}

/**
 * Which end of the results to place the items that do not have the sorting field.
 */
enum MissingOrder {
    FIRST,
    LAST
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
     * What to do with missing values
     */
    3: optional MissingOrder missing;

}

/**
 * The query to run
 */
struct Query {
    /**
     * The columns to retrieve
     */
    1: required list<string> requestedColumns;
    /**
     * The primary query
     */
    2: required QueryAtom primaryQuery;
    /**
     * The optional page of results to retrieve
     */
    3: optional Page page;
    /**
     * The sort criteria
     */
    4: optional list<FieldSort> sortCriteria;
}

/**
 * The query result to return
 */
struct QueryResult {
    /**
     * The result row set
     */
    1: required list<cli_service.TRow> resultSet;
    /**
     * The optional paging offset
     */
    2: optional i32 offset;
    /**
     * The optional paging size
     */
    3: optional i16 pageSize;
}

enum RelationshipType {
    // Heirarchy
    IN_COMMAND_OF,
    IS_SUBORDINATE_TO,
    SISTER_AIRFIELD,
    // Collaborators
    DEPLOYS_WITH,
    TRAINS_WITH,
    WORKS_WITH,
    TRANSMITS_TO,
    RECEIVES_FROM,
    // Locations
    DEPLOYS_FROM,
    DEPLOYS_FROM_HERE,
    DEPLOYS_TO,
    DEPLOYS_TO_HERE,
    GARRISONED_AT,
    GARRISONED_HERE,
    HOMEPORTED_AT,
    HOMEPORTED_HERE,
    PATROLS_AREA,
    PATROLLED_BY,
    TRAINS_AT,
    TRAINS_HERE,
    LOCATED_NEAR,
    LOCATED_NEARBY,
    // Equipment
    COMPONENT_OF,
    COMPONENTS_INCLUDE,
    USES,
    USED_BY,
    IS_USED_IN,
    IS_USED_FOR,
    TESTED_AT,
    TESTED_HERE,
    REPAIRED_AT,
    REPAIRED_HERE,
    // Actions/events
    AFFECTS,
    REACTS_TO,
    ATTENDS,
    ATTENDED_BY,
    PARTICIPATES_IN,
    PARTICIPANTS,
    SUPPORTS,
    SUPPORTED_BY
}

struct Relationship {
    1: required BaseIntents.BaseContext base;
    2: required string relatedId;
    3: required RelationshipType type;
}

union ReportContent {
    1: binary fullText;
    2: string uri;
}

struct Report {
    1: required BaseIntents.BaseContext base;
    2: required string name;
    3: optional string type;
    4: optional string serialNumber;
    5: optional ReportContent content;
}

enum ObjectState {
    ACTIVE,
    AT_AIRFIELD,
    DECOMMISSIONED,
    DEPLOYED,
    FITTING_OUT,
    IN_FLIGHT,
    IN_GARRISON,
    IN_PORT,
    INACTIVE,
    OUT_OF_GARRISON,
    OUT_OF_PORT,
    UNDERWAY
}

struct State {
    1: required BaseIntents.BaseContext base;
    2: required ObjectState state;
}

struct Unit {
    1: required BaseIntents.StandardObject base;
    2: optional string name;
    3: optional string country;
    4: optional string type;
    5: optional string echelon;
    6: optional string unitId;
    7: optional string tkbId;
    8: optional bool isTransient;
}

union Intent {
    1: Activity activity;
    2: Equipment equipment;
    3: Event event;
    4: Facility facility;
    5: Image image;
    6: Issue issue;
    7: Location location;
    8: Person person;
    9: Relationship relationship;
    10: Report report;
    11: State state;
    12: Unit unit;
}