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

namespace * ezbake.base.thrift.metrics
namespace py ezbake.base.thriftapi.metrics
namespace go ezbake.base.thriftapi.metrics

struct GaugeThrift {
    1: optional string value;
    2: optional string error;
}

struct CounterThrift {
    1: required i64 count;
}

struct SnapShotThrift {
    1: required i64 max;
    2: required i64 min;
    3: required double mean;
    4: required double median;
    5: required double StdDev;
    6: required double p75;
    7: required double p95;
    8: required double p98;
    9: required double p99;
    10: required double p999;
    11: required list<i64> values;
}

struct HistogramThrift {
    1: required i64 count;
    2: required SnapShotThrift snapshot;
}

struct MeteredThrift {
    1: required i64 count;
    2: required double m15Rate;
    3: required double m5Rate;
    4: required double m1Rate;
    5: required double meanRate;
}

struct TimerThrift {
    1: required i64 count;
    2: required SnapShotThrift snapshot;
    3: required MeteredThrift meter;
}

struct MetricRegistryThrift {
    1: required map<string, GaugeThrift> gauges;
    2: required map<string, CounterThrift> counters;
    3: required map<string, HistogramThrift> histograms;
    4: required map<string, MeteredThrift> meters;
    5: required map<string, TimerThrift> timers;
}
