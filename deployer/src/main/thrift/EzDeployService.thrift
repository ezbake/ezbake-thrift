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

include "EzBakeBase.thrift"

namespace * ezbake.services.deploy.thrift
namespace py ezbake.services.deploy.thriftapi
namespace go ezbake.services.deploy.thriftapi

const string SERVICE_NAME = "ezdeployer"

enum ArtifactType {
    WebApp = 0,    // Will get deployed to the OpenShift PaaS
    Thrift = 1,    // Will get deployed to the Mesos cloud
    DataSet = 2,   // Will deploy a dataset to the Mesos cloud
    Frack = 3,     // Will deploy via the Frack service
    Custom = 4,    // Will deploy a custom application to the Mesos cloud
    Batch = 5
}

enum Language {
    Java = 0,
    NodeJs = 1,
    Python = 2
}

enum DeploymentStatus {
    Deployed = 0,
    Staged = 1,
    Denied = 2,
    Undeployed = 3
}

// This is reserved for later
struct ControlScripts {
    1: required string startScript;
    2: required string stopScript;
}

enum ResourceReq {
    small = 1000,  // Small amount of resources
    medium = 2000, // medium amount of resources
    large = 3000,  // large amount of resources
}

struct ResourceRequirements {
    1: optional ResourceReq cpu = ResourceReq.small;
    2: optional ResourceReq mem = ResourceReq.small;
    3: optional ResourceReq disk = ResourceReq.small;
}

struct ApplicationInfo {
   1: optional string applicationId;
   2: optional string serviceId;
   3: optional list<string> datasets;
   4: optional string securityId;
   5: optional set<string> auths;
}

struct ArtifactInfo {
    1: optional ResourceRequirements resourceRequirements = { };

    /**
     * The language the artifact is written in. This will determine the runtime used to launch the thrift runner for
     * instance, or the web container for OpenShift
     */
    2: optional Language language = Language.Java

    3: optional string bin
    4: optional set<string> config
    5: optional bool purgeable = false
    6: optional bool systemLogfileDisabled
}

struct Scaling {
    1: optional i16 numberOfInstances
}

struct WebAppInfo {
    1: optional string externalWebUrl
    2: optional string internalWebUrl
    3: optional string hostname

    // See EzReverseProxy.thrift for the meaning of the next 4 properties
    4: optional i32 timeout
    5: optional i32 timeoutRetries
    7: optional i32 uploadFileSize
    8: optional bool stickySession

    9: optional string preferredContainer
    10: optional bool chunkedTransferEncodingDisabled
    11: optional bool websocketSupportDisabled
}

struct BatchJobInfo {
    1: optional string startDate
    2: optional string startTime
    3: optional string repeat
    4: optional string flowName
}

struct ThriftServiceInfo {
    1: optional string reserved
}

struct FrackServiceInfo {
    1: optional string reserved
}

struct CustomServiceInfo {
    /**
     * Use this to instead of using the default containers (ThriftRunner -or- a WebContainer) to specify how to control
     * your application manually
     */
    1: optional ControlScripts controlScripts
}

struct DatabaseInfo {
    1: optional string databaseType
}

struct ArtifactManifest
{
    1: optional ApplicationInfo applicationInfo
    2: optional ArtifactInfo artifactInfo
    3: optional ArtifactType artifactType
    4: optional Scaling scaling
    5: optional string user
    6: optional WebAppInfo webAppInfo
    7: optional ThriftServiceInfo thriftServiceInfo
    8: optional FrackServiceInfo frackServiceInfo
    9: optional CustomServiceInfo customServiceInfo
   10: optional DatabaseInfo databaseInfo
   11: optional BatchJobInfo batchJobInfo
}

struct DeploymentMetadata {
    /**
     * The metadata of the artifact deployed
     */
    1: required ArtifactManifest manifest

    /**
     * The version of the application deployed (timestamp of the application deployment time)
     */
    2: required string version

    /**
     * The status of this deployment
     */
    3: optional DeploymentStatus status
}

/**
 * For internal use.  This will be used to serialize to the backing datastore
 */
struct DeploymentArtifact {
    1: required DeploymentMetadata metadata
    2: required binary artifact
}

exception DeploymentException {
    1: required string message
}

service EzBakeServiceDeployer extends EzBakeBase.EzBakeBaseService {
    /**
     * Deploy a service by appId to the EzBake platform. A unique version based on the timestamp will be used for this
     * deployment of the application. The SSL private client keys will be added to the config directory for this
     * application automatically upon successful call to this RPC.
     *
     * @param metaData The application metadata to be deployed
     * @param artifact A 'tar.gz' file of the application to be deployed. The tar file should be in the following
     *                 format:
     *                 +- app
     *                 |  +- application.jar
     *                 +- config
     *                 |  +- Any Application config files
     *
     * @return Metadata about the application that has been deployed.
     */
    DeploymentMetadata deployService(
        1: ArtifactManifest manifest,
        2: binary artifact,
        3: EzBakeBase.EzSecurityToken token) throws (1: DeploymentException problem)

    /**
     *  Undeploys an application using the applicationId/serviceId.  This will remove the application from the public
     *  view. The application is still residing in the deployment database for auditing and restoring of an application
     *  that has been undeployed.
     */
    void undeploy(
        1: string applicationId,
        2: string serviceId,
        3: EzBakeBase.EzSecurityToken token) throws (1: DeploymentException problem)

    /**
     * Get Latest deployed version of an application
     *
     * @param applicationId Application id to get the latest version for
     *
     * @return The latest deployment information of application
     */
    DeploymentMetadata getLatestApplicationVersion(
        1: string applicationId,
        2: string serviceId,
        3: EzBakeBase.EzSecurityToken token) throws (1: DeploymentException problem)

    /**
     * Get the list of matching DeploymentMetadatas
     *
     * @param fieldName The field to search - Leave empty to list everything
     * @param fieldValue The field value to search on  - Leave empty to list everything
     *
     * @return The list deployment information matching the query
     */
    list<DeploymentMetadata> listDeployed(
        1: string fieldName,
        2: string fieldValue,
        3: EzBakeBase.EzSecurityToken token) throws (1: DeploymentException problem)

    /**
     * Get the current and all previous versions of an application's metadata
     *
     * @param applicationId Application id to get the versions for
     *
     * @return The list of all deployment metadata of the given application id
     */
    list<DeploymentMetadata> getApplicationVersions(
        1: string applicationId,
        2: string serviceId,
        3: EzBakeBase.EzSecurityToken token) throws (1: DeploymentException problem)

    /**
     * Sends the current version of the application ID to the PaaS (Mesos or OpenShift) as defined by the application
     * metadata.
     */
    void publishArtifactLatestVersion(
        1: string applicationId,
        2: string serviceId,
        3: EzBakeBase.EzSecurityToken token) throws (1: DeploymentException problem)

    /**
     * Sends the specified version of the application ID to the PaaS (Mesos or OpenShift) as defined by the application
     * metadata.
     *
     * @param applicationId Application id to publish
     * @param version Version of application to publish
     */
    void publishArtifact(
        1: string applicationId,
        2: string serviceId,
        3: string version,
        4: EzBakeBase.EzSecurityToken token) throws (1: DeploymentException problem)

    /**
     * Deletes all artifact versions from the store
     *
     * @param applicationId Application id to remove
     * @param serviceId The service that is being removed
     */
    void deleteArtifact(
        1: string applicationId,
        2: string serviceId,
        3: EzBakeBase.EzSecurityToken token) throws (1: DeploymentException problem)

    /**
     * Stages this artifact for deployment but won't actually deploy it
     *
     * @param manifest Metadata for this artifact
     * @param artifact The actual deployment package binary
     */
    void stageServiceDeployment(
        1: ArtifactManifest manifest,
        2: binary artifact,
        3: EzBakeBase.EzSecurityToken token) throws (1: DeploymentException problem)

    /**
     * Removes the artifact from the list of staged deployments
     *
     * @param applicationId Application id to remove
     * @param serviceId The service that is being removed
     */
    void unstageServiceDeployment(
        1: string applicationId,
        2: string serviceId,
        3: EzBakeBase.EzSecurityToken token) throws (1: DeploymentException problem)

    /**
     * Update deployment metadata
     */
    void updateDeploymentMetadata(
        1: DeploymentMetadata metadata,
        2: EzBakeBase.EzSecurityToken token) throws (1: DeploymentException problem)

    /**
     * Re-registers the given application with the Frontend.
     *
     * @param applicationId Application id to re-register
     * @param serviceId The service that is being re-register
     * @param token The caller's security token
     **/
    void reregister(
        1: string applicationId,
        2: string serviceId,
        3: EzBakeBase.EzSecurityToken token) throws (1: DeploymentException problem)
        
    
    /**
     * Get latest version of deployment artifact
     *
     * @param applicationId - Application id of the artifact
     * @param serviceId - service id of the artifact
     * @param token - caller's security token
    */
    DeploymentArtifact getLatestVersionOfDeploymentArtifact(
        1: string applicationId, 
        2: string serviceId,
        3: EzBakeBase.EzSecurityToken token) throws (1: DeploymentException problem)
}
