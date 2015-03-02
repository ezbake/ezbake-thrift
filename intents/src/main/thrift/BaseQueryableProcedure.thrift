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

namespace * ezbake.query.basequeryableprocedure

include "EzBakeBase.thrift"
include "EzBakeBaseProcedures.thrift"
include "QueryIntents.thrift"

struct Page {
    1: required i32 offset;
    2: required i32 pagesize;
}

struct PrepareStats {
    1: required i32 numberOfRowsEstimate;
    2: required list<i32>acceptedConjuncts;
}

union ColumnDataValues {
    1: list<bool> bool_vals;
    2: list<byte> byte_vals;
    3: list<i16> short_vals;
    4: list<i32> int_vals;
    5: list<i64> long_vals;
    6: list<double> double_vals;
    7: list<string> string_vals;
    8: list<binary> binary_vals;
}

struct ColumnData {
    1: required list<bool> is_null;
    2: optional ColumnDataValues values;
}

struct RowBatch {
    1: required list<ColumnData> cols;
}

struct GetPageResult {
    1: optional bool eos;
    2: optional RowBatch rows;
}

exception BaseQueryableProcedureException {
    1: required string message;
}

service BaseQueryableProcedure extends EzBakeBaseProcedures.BaseProcedure {
    GetPageResult getPage(
        1: QueryIntents.IntentType intentType,
        2: Page page,
        3: list<string> columnNames,
        4: list<list<QueryIntents.BinaryPredicate>> predicates,
        5: EzBakeBase.EzSecurityToken security) throws (
            1: BaseQueryableProcedureException failure);

    PrepareStats prepare(
        1: string tableName,
        2: string initString,
        3: list<list<QueryIntents.BinaryPredicate>> predicates,
        4: EzBakeBase.EzSecurityToken security) throws (
            1: BaseQueryableProcedureException failure);
}

