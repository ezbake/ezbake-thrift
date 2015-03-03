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

namespace * ezbake.ins.thrift.gen
namespace py ezbake.ins.thriftapi.gen
namespace go ezbake.ins.thriftapi.gen

include "EzBakeBase.thrift"
include "EzSecurityServices.thrift"

const string SERVICE_NAME = "ins";

struct AppAccess {
    /**
     * Set it to false to restrict access and then add apps to map<string, string>, otherwise leave it true and leave
     * map<string, string> empty
     */
    1: optional bool isNotRestricted = true;

    /**
     * map<Application.appName, Application.id> structure represents all apps that have access to a group, depends on
     * isNotRestricted flag set to false.
     */
    2: optional map<string, string> restrictedToApps;
}

struct AppService {
    1: required string applicationName;
    2: required string serviceName;
}

struct BroadcastTopic {
    1: optional string name;
    2: optional string description;
    3: optional string location; //deprecated
    4: optional string thriftDefinition;
}

struct FeedPipeline {
    1: optional string feedName;
    2: optional string description;
    3: optional set<BroadcastTopic> broadcastTopics;
    4: optional string exportingSystem;
    5: optional string type;
    6: optional string maxClassification;
    7: optional string networkInitiated;
    8: optional list<string> physicalServers;
    9: optional string dateAdded;
    10: optional string dataType;
}

struct JobRegistration {
    1: optional string jobName;
    2: optional string feedName;
    3: optional string uriPrefix;
}

struct ListenerPipeline {
    1: optional string feedName;
    2: optional string description;
    3: optional set<string> listeningTopics;
    4: optional set<BroadcastTopic> broadcastTopics;
}

struct WebApplicationLink {
    1: optional string appName;
    2: optional string webUrl;
    3: optional bool includePrefix;
    4: optional string requiredGroupName;
}

struct WebApplication {
    1: optional map<string, WebApplicationLink> urnMap;
    2: optional bool isChloeEnabled;
    3: optional string chloeWebUrl;
    4: optional string externalUri;
    5: optional string requiredGroupName;
}

struct Application {
    1: optional string id;
    2: optional string appName;
    3: optional string poc;
    4: optional set<string> allowedUsers;
    5: optional map<string, string> categories;
    6: optional set<FeedPipeline> feedPipelines;
    7: optional set<ListenerPipeline> listenerPipelines;
    8: optional WebApplication webApp;
    9: optional set<string> authorizations;
    10: optional map<string, set<string>> authorizationBuilder;
    11: optional map<string, string> intentServiceMap;
    12: optional string icgcServicesDN;
    13: optional set<JobRegistration> jobRegistrations;
    14: optional string appIconSrc;
    15: optional string sponsoringOrganization;
    16: optional set<string> communityAuthorizations;
    17: optional AppAccess appAccess;
}

struct ApplicationSummary {
    1: optional string id;
    2: optional string appName;
    3: optional string poc;
    4: optional string appIconSrc;
    5: optional string sponsoringOrganization;
    6: optional string externalUri;
}

enum FeedType {
    APP,
    SYSTEM,
    ALL
}

exception ApplicationNotFoundException {
    1: required string message;
}

service InternalNameService extends EzBakeBase.EzBakeBaseService {
    /**
     * Saves a new or updates an existing application.  Only the INS website or deployer may call this function
     */
    bool saveApplication(
        1: Application application,
        2: EzBakeBase.EzSecurityToken token) throws (1: EzBakeBase.EzSecurityTokenException ex1);

    /**
     * Deletes an existing application.  Only the INS website or deployer may call this function
     */
    bool deleteApplication(
        1: string appId, 2: EzBakeBase.EzSecurityToken token) throws (1: EzBakeBase.EzSecurityTokenException ex1);

    /**
     * Find duplicate application names. Only the INS website or deployer may call this function
     */
    set<Application> getDuplicateAppNames(
        1: string appName, 2: EzBakeBase.EzSecurityToken token) throws (1: EzBakeBase.EzSecurityTokenException ex1);

    /**
     * Gets an existing application with the given Id.  Only the INS website or deployer may call this function
     */
    Application getAppById(
        1: string appId,
        2: EzBakeBase.EzSecurityToken token) throws (
            1: ApplicationNotFoundException ex1,
            2: EzBakeBase.EzSecurityTokenException ex2);

    /**
     * Gets all the applications that the given user is an INS admin of.  Only the INS website or deployer may call this
     * function
     */
    set<Application> getMyApps(
        1: EzBakeBase.EzSecurityToken token) throws (1: EzBakeBase.EzSecurityTokenException ex1);

    /**
     * Gets basic information for the given app name.  Open for all users
     */
    ApplicationSummary getAppByName(
        1: string appName,
        2: EzBakeBase.EzSecurityToken token) throws (
            1: ApplicationNotFoundException ex1,
            2: EzBakeBase.EzSecurityTokenException ex2);

    /**
     * Gets existing applications' summary sans application icon source dump
     */
    set<ApplicationSummary> getAllApplicationsSummary();

    //
    // Category Functions
    //

    /**
     * Gets all Feed categories.  Open for all users
     */
    set<string> getCategories();

    /**
     * Adds a new feed category.  Only the INS website or deployer may call this function
     */
    bool addCategory(
        1: string category, 2: EzBakeBase.EzSecurityToken token) throws (1: EzBakeBase.EzSecurityTokenException ex1);

    /**
     * Removes an existing feed category.  Only the INS website or deployer may call this function
     */
    bool removeCategory(
        1: string category, 2: EzBakeBase.EzSecurityToken token) throws (1: EzBakeBase.EzSecurityTokenException ex1);

    //
    // Topic Functions
    //

    /**
     * Gets all System Topics (topics that anyone can broadcast to).  Open for all users
     */
    set<string> getSystemTopics();

    /**
     * Adds a System Topic.  Only the INS website or deployer may call this function
     */
    bool addSystemTopic(
        1: string systemTopic, 2: EzBakeBase.EzSecurityToken token) throws (1: EzBakeBase.EzSecurityTokenException ex1);

    /**
     * Removes an existing System Topic.  Only the INS website or deployer may call this function
     */
    bool removeSystemTopic(
        1: string systemTopic, 2: EzBakeBase.EzSecurityToken token) throws (1: EzBakeBase.EzSecurityTokenException ex1);

    //
    // Pipeline Functions
    //

    /**
     * Gets all the registered feeds.  Open for all users
     */
    set<FeedPipeline> getPipelineFeeds();

    /**
     * Gets all topics that a given application is registered to broadcast to for a given feed.  Open for all users
     */
    set<string> getTopicsForFeed(
        1: string appId, 2: string feedName) throws (1: ApplicationNotFoundException ex1);

    /**
     * Gets all topics that a given application is approved to broadcast to for a given feed.  Only the INS website or
     * deployer may call this function
     */
    set<string> getApprovedTopicsForFeed(
        1: string appId,
        2: string feedName,
        3: EzBakeBase.EzSecurityToken token) throws (
            1: ApplicationNotFoundException ex1,
            2: EzSecurityServices.RegistrationException ex2,
            3: EzSecurityServices.SecurityIDNotFoundException ex3,
            4: EzSecurityServices.PermissionDeniedException ex4,
            5: EzBakeBase.EzSecurityTokenException ex5);

    /**
     * Gets all topics that a given application is approved to listen to for a given feed.  Only the INS website or
     * deployer may call this function
     */
    set<string> getListeningTopicsForFeed(
        1: string appId,
        2: string feedName,
        3: EzBakeBase.EzSecurityToken token) throws (
            1: ApplicationNotFoundException ex1,
            2: EzSecurityServices.RegistrationException ex2,
            3: EzSecurityServices.SecurityIDNotFoundException ex3,
            4: EzSecurityServices.PermissionDeniedException ex4,
            5: EzBakeBase.EzSecurityTokenException ex5);

    /**
     * Gets all the currently registered broadcast topics based on the type.  Open for all users
     */
    set<string> allBroadcastTopicNames(1: FeedType type);

    //
    // Web App Functions
    //

    /**
     * Gets the prefix for the URI that should be used for the given application and feed name combination.  Open for
     * all users
     */
    string getURIPrefix(
        1: string appId, 2: string categoryKey) throws (1: ApplicationNotFoundException ex1);

    /**
     * Gets all the URI prefixes current registered in the system.  Open for all users
     */
    set<string> getURIPrefixes();

    /**
     * Gets all applications that capable of opening or visualizing the given uri (or uri prefix).  Open for all users
     */
    set<WebApplicationLink> getWebAppsForUri(1: string uri);

    /**
     * Gets all Chloe-enabled applications (applications that support the Chloe API for sharing data).  Open for all
     * users
     */
    set<WebApplicationLink> getChloeWebApps();

    //
    // Other Registration Items
    //

    /**
     * Gets all application services that can answer the given intent.  Open for all users
     */
    set<AppService> appsThatSupportIntent(1: string intentName);

    /**
     * Gets the approved batch jobs for the given application.  Only the INS website or deployer may call this function
     */
    set<JobRegistration> getJobRegistrations(
        1: string appId,
        2: EzBakeBase.EzSecurityToken token) throws (
            1: ApplicationNotFoundException ex1,
            2: EzBakeBase.EzSecurityTokenException ex2);

    //
    // Import/Export Functions
    //

    /**
     * Exports all details of an existing application as a JSON string.  Only the INS website or deployer may call this
     * function
     */
    string exportApplication(
        1: string appId,
        2: EzBakeBase.EzSecurityToken token) throws (
            1: ApplicationNotFoundException ex1,
            2: EzBakeBase.EzSecurityTokenException ex2);

    /**
     * Imports a JSON representation of an application.  Only the INS website or deployer may call this function
     */
    Application importApplication(
        1: string exportedApplication,
        2: EzBakeBase.EzSecurityToken token) throws (
            1: EzBakeBase.EzSecurityTokenException ex1);
}
