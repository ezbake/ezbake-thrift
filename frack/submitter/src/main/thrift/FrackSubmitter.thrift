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

namespace * ezbake.frack.submitter.thrift
namespace py ezbake.frack.submitter.thriftapi

include "EzBakeBase.thrift"

const string SERVICE_NAME = "fracksubmitter"

/**
 * This exception signifies that no pipeline was running with the provided name when attempting a shutdown event.
 */
exception PipelineNotRunningException {
    1: optional string message;
}

/**
 * This message will be returned to the caller, and describes the result of jar submission.
 */
struct SubmitResult {
    1: required bool submitted;
    2: required string message;
}

service Submitter extends EzBakeBase.EzBakeBaseService {
    /**
     * This method submits the given buildpack tar.gz file to Frack.
     */
    SubmitResult submit(1: binary zip, 2: string pipelineId);

    /**
     * This method shuts down the pipeline corresponding to the given name.
     */
    void shutdown(1: string pipelineId) throws (1: PipelineNotRunningException e);
}
