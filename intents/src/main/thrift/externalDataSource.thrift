// Copyright 2014 Cloudera Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

namespace cpp impala.extdatasource
namespace java com.cloudera.impala.extdatasource.thrift
namespace * impala.extdatasource

include "impalaTypes.thrift"

struct TColumnDesc {
  // The Column name as given in the Create .. statement. Always set.
  1: optional string name

  // The column type. Always set.
  2: optional impalaTypes.TColumnType type
}

// Metadata used to describe the schema (column names, types, comments)
// of result sets.
struct TTableSchema {
  1: optional list<TColumnDesc> cols
}

struct TRowBatch {
  1: optional list<impalaTypes.TColumnData> cols
  2: optional i64 num_rows
}

// Comparison operators used in predicates.
enum TComparisonOp {
  LT, LE, EQ, NE, GE, GT
}

// Binary predicates that can be pushed to the external data source and
// are of the form <col> <op> <val>. Sources can choose to accept or reject
// predicates via the return value of GetStats(), see TGetStatsResult.
struct TBinaryPredicate {
  // Column on which the predicate is applied.
  1: optional TColumnDesc col

  // Comparison operator.
  2: optional TComparisonOp op

  // Value on the right side of the binary predicate.
  3: optional impalaTypes.TColumnValue value
}

// a wrapper struct of List<List<TBinaryPredicate>> so that we
// can serialize
struct TBinaryPredicateList {
  1: required list<list<TBinaryPredicate>> predicates
}

struct TPrepareParams {
  1: optional string table_name
  2: optional string init_string
  3: optional list<list<TBinaryPredicate>> predicates
}

struct TPrepareResult {
  1: required impalaTypes.TStatus status
  2: optional i64 num_rows_estimate
  3: list<i32> accepted_conjuncts
}


// Returned by Open().
struct TOpenResult {
  1: required impalaTypes.TStatus status

  // An opaque handle used in subsequent GetNext()/Close() calls.
  2: optional string scan_handle
}
// Parameter to Open()
struct TOpenParams {
  1: optional impalaTypes.TUniqueId query_id
  2: optional string table_name
  3: optional string init_string
  4: optional string authenticated_user_name
  5: optional TTableSchema row_schema
  6: optional i32 batch_size
  7: optional list<list<TBinaryPredicate>> predicates
}


// Returned by GetNext().
struct TGetNextResult {
  1: required impalaTypes.TStatus status

  // If true, reached the end of the result stream; subsequent calls to
  // GetNext() won’t return any more results
  2: optional bool eos

  3: optional TRowBatch rows
}
// Parameter to GetNext()
struct TGetNextParams {
  1: optional string scan_handle
}

// Returned by Close().
struct TCloseResult {
  1: required impalaTypes.TStatus status
}

// Parameter to Close().
struct TCloseParams {
  1: optional string scan_handle
}
