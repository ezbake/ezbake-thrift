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

namespace * ezbake.groups.thrift
namespace py ezbake.groups.thriftapi

include "EzBakeBase.thrift"

/**
 * Define local aliases for types defined in other thrift files
 */
typedef EzBakeBase.EzSecurityToken EzSecurityToken
typedef EzBakeBase.TokenType TokenType
typedef set<string> GroupMembers

// Core Group name constants
const string GROUP_NAME_SEP = ".";
const string ROOT = "root";
const string APP_GROUP = "app";
const string APP_ACCESS_GROUP = "appaccess";

/*
 * App Special group names
 *
 * By convention, these will be created under:
 *
 *     root.app.<appName>.<special group name>
 *
 * ex:
 *     root.app.EzBake.ezbAudits
 *     root.app.EzBake.ezbMetrics
 *     root.app.EzBake.ezbDiagnostics
 *
 */
const string AUDIT_GROUP = "ezbAudits";
const string METRICS_GROUP = "ezbMetrics";
const string DIAGNOSTICS_GROUP = "ezbDiagnostics";


struct AllGroupMembers {
    1: optional GroupMembers apps;
    2: optional GroupMembers users;
}

struct GroupInheritancePermissions {
    1: required bool dataAccess = false;
    2: required bool adminRead = false;
    3: required bool adminWrite = false;
    4: required bool adminManage = false;
    5: required bool adminCreateChild = false;
}

struct UserGroupPermissions {
    1: optional bool dataAccess = true;
    2: optional bool adminRead = false;
    3: optional bool adminWrite = false;
    4: optional bool adminManage = false;
    5: optional bool adminCreateChild = false;
}

struct Group {
    1: required i64 id;
    2: required string groupName;
    3: optional GroupInheritancePermissions inheritancePermissions;
    4: optional bool requireOnlyUser = true;
    5: optional bool requireOnlyAPP = false;
    6: optional bool isActive = true;
}

struct UserGroup {
    1: required Group group;
    2: required UserGroupPermissions permissions;
}

enum AuthorizationError {
    GROUP_NOT_FOUND,
    USER_NOT_FOUND,
    ACCESS_DENIED
}

exception AuthorizationException {
    1: required string message;
    2: required AuthorizationError error;
}

enum OperationError {
    GROUP_EXISTS,
    GROUP_NOT_FOUND,
    PARENT_GROUP_NOT_FOUND,
    USER_EXISTS,
    USER_NOT_FOUND,
    INDEX_UNAVAILABLE,
    UNRECOVERABLE_ERROR
}

exception EzGroupOperationException {
    1: required string message;
    2: required OperationError operation;
}

enum GroupQueryError {
    USER_NOT_FOUND,
    GROUP_NOT_FOUND,
}

exception GroupQueryException {
    1: required string message;
    2: required GroupQueryError errorType;
}

enum UserType {
    USER,
    APP_USER
}

struct User {
    /**
     * User or app user name
     */
    1: required string name;

    /**
     * User or app user ID
     */
    2: required string principal;

    /**
     * Whether or not is active
     */
    3: required bool isActive;
}

/**
 * Service name constant. This is how EzGroups is identified in service discovery
 */
const string SERVICE_NAME = "ezgroups"

/**
 * EzGroups, the Ezbake Object Permission Service
 */
service EzGroups extends EzBakeBase.EzBakeBaseService {
    /* ---------------------------------------------------------------------------------- */
    /* ---------------------------------------------------------------------------------- */
    /*                                 Group Operations                                   */
    /* ---------------------------------------------------------------------------------- */
    /* ---------------------------------------------------------------------------------- */

    /**
     * Create a new group
     *
     * @return the newly created group's unique ID
     */
    i64 createGroup(
        1: required EzSecurityToken token,
        2: string parent,
        3: required string name,
        4: required GroupInheritancePermissions parentGroupInheritance) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    /**
     * @return the newly created group's unique ID
     */
    i64 createGroupWithInclusion(
        1: required EzSecurityToken token,
        2: string parent,
        3: required string name,
        4: required GroupInheritancePermissions parentGroupInheritance,
        5: bool includeOnlyRequiresUser=false,
        6: bool includedIfAppInChain=true) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    void deactivateGroup(
        1: required EzSecurityToken token,
        2: required string groupName,
        3: bool andChildren=false) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    void activateGroup(
        1: required EzSecurityToken token,
        2: required string groupName,
        3: bool andChildren=false) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    void changeGroupInheritance(
        1: required EzSecurityToken token,
        2: required string group,
        3: required GroupInheritancePermissions inheritance) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    void changeGroupName(
        1: required EzSecurityToken token,
        2: required string group,
        3: required string newstring) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    set<i64> getGroupsMask(
        1: required EzSecurityToken token,
        2: required set<string> groupNames) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: EzGroupOperationException createError);

    /* ---------------------------------------------------------------------------------- */
    /* ---------------------------------------------------------------------------------- */
    /*                                  User Operations                                   */
    /* ---------------------------------------------------------------------------------- */
    /* ---------------------------------------------------------------------------------- */

    /**
     * Create a new user. EzSecurityToken must be an EzAdmin token in order to create users
     *
     * @param token EzSecurityToken, must be an EzAdmin token in order to perform this action
     * @param userID User's unique external ID
     * @param name optionally associate a name with this user
     *
     * @return the newly created user's group unique ID
     */
    i64 createUser(
        1: required EzSecurityToken token,
        2: required string userID,
        3: string name) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    /**
     * Modify a user principal.
     *
     * @param token EzSecurityToken, must be an EzAdmin token in order to perform this action
     * @param userID Original principal of user to modify
     * @param newUserID New principal for the user
     */
    void modifyUser(
        1: required EzSecurityToken token,
        2: required string userID,
        3: required string newUserID) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    /**
     * Deactivate a user
     *
     * @param token EzSecurityToken. Must be an EzAdmin to perform this action
     * @param userID ID of user being acted upon
     */
    void deactivateUser(
        1: required EzSecurityToken token,
        2: required string userID) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    /**
     * Activate a user
     *
     * @param token EzSecurityToken. Must be an EzAdmin to perform this action
     * @param userID ID of user being acted upon
     */
    void activateUser(
        1: required EzSecurityToken token,
        2: required string userID) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    /**
     * Delete a user
     *
     * @param token EzSecurityToken. Must be an EzAdmin to perform this action
     * @param userID ID of user being acted upon
     */
    void deleteUser(
        1: required EzSecurityToken token,
        2: required string userID) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    /**
     * Get a user
     *
     * @param token EzSecurityToken.
     * @param userType type of user as defined in UserType enum
     * @param userID ID of user being acted upon
     */
    User getUser(
        1: required EzSecurityToken token,
        2: required UserType userType,
        3: required string userID) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError);

    /**
     * Create a new app user. EzSecurityToken must be an EzAdmin token in order to create users
     *
     * @param token EzSecurityToken. Must be an EzAdmin to perform this action
     * @return the newly created user's group unique ID
     */
    i64 createAppUser(
        1: required EzSecurityToken token,
        2: required string securityID,
        3: string name) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    /**
     * Create a new app user and immediately return the user's authorizations. This function may only be called by
     * EzSecurity, and uses SSL/X509 certs to verify the EzSecurity identity
     */
    set<i64> createAppUserAndGetAuthorizations(
        1: required EzSecurityToken token,
        2: required list<string> appChain,
        3: required string securityId,
        4: string appName) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError,
            4: GroupQueryException queryError);

    /**
     * Modify an app user - change their security ID or name
     *
     * @param token EzSecurityToken. Must be an EzAdmin to perform this action
     */
    void modifyAppUser(
        1: required EzSecurityToken token,
        2: required string securityID,
        3: string newSecurityId,
        4: string newstring) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    /**
     *  Deactivate an app user
     *
     *  @param token EzSecurityToken. Must be an EzAdmin to perform this action
     *  @param securityID ID of user being acted upon
     */
    void deactivateAppUser(
        1: required EzSecurityToken token,
        2: required string securityID) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    /**
     *  Activate an app user
     *
     *  @param token EzSecurityToken. Must be an EzAdmin to perform this action
     *  @param securityID ID of user being acted upon
     */
    void activateAppUser(
        1: required EzSecurityToken token,
        2: required string securityID) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    /**
     * Delete an app user
     *
     * @param token EzSecurityToken. Must be an EzAdmin to perform this action
     * @param securityID ID of user being acted upon
     */
    void deleteAppUser(
        1: required EzSecurityToken token,
        2: required string securityID) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);


    /* ---------------------------------------------------------------------------------- */
    /* ---------------------------------------------------------------------------------- */
    /*                             User Group Operations                                  */
    /* ---------------------------------------------------------------------------------- */
    /* ---------------------------------------------------------------------------------- */

    /**
     * Add an existing user to an existing group. The user/app user belonging to the token must have admin write on the
     * group in order for the user to be added
     */
    void addUserToGroup(
        1: required EzSecurityToken token,
        2: required string groupName
        3: required string userID,
        4: required UserGroupPermissions permissions) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);


    /**
     * Remove a user from a group. The user/app user belongign to the token must have admin write permissions on the
     * group in order for the user to be removed
     */
    void removeUserFromGroup(
        1: required EzSecurityToken token,
        2: required string groupName,
        3: required string userId) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    /**
     * Add an existing user to an existing group. The user/app user belonging to the token must have admin write on the
     * group in order for the user to be added
     */
    void addAppUserToGroup(
        1: required EzSecurityToken token,
        2: required string groupName,
        3: required string securityID,
        4: required UserGroupPermissions permissions) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);

    /**
     * Remove a user from a group. The user/app user belongign to the token must have admin write permissions on the
     * group in order for the user to be removed
     */
    void removeAppUserFromGroup(
        1: required EzSecurityToken token,
        2: required string groupName,
        3: required string securityId) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError);


    /* ---------------------------------------------------------------------------------- */
    /* ---------------------------------------------------------------------------------- */
    /*                                    Queries                                         */
    /* ---------------------------------------------------------------------------------- */
    /* ---------------------------------------------------------------------------------- */

    /**
     * Get all child groups from the given parent group. This will only return children that inherit an admin_read
     * edge from the parent vertex.
     *
     * @param token EzSecurityToken belonging to the party performing the query. The user must have admin_read on the
     *              parent groupName
     * @param groupName the parent group name from which to start the child groups query
     * @param recurse if not true, will only return direct child groups of the parent
     *
     * @return set of child group names
     */
    set<Group> getChildGroups(
        1: required EzSecurityToken token,
        2: required string groupName,
        3: bool recurse) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: GroupQueryException createError);

    /**
     * Get given group metadata, i.e. whether or not group is active
     *
     * @param token EzSecurityToken belonging to the party performing the query. The user must have admin_read on the
     *              parent groupName
     * @param groupName the group name for which metadata is being requested
     *
     * @return group metadata
     */
    Group getGroup(
        1: required EzSecurityToken token,
        2: required string groupName) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError);

    /**
     * Get all members belonging to a group, including Users and App Users
     *
     * @param token EzSecurityToken belonging to the party performing the query
     * @param groupName the name of the group being queried
     *
     * @return set of group member principals
     */
    AllGroupMembers getGroupMembers(
        1: required EzSecurityToken token,
        2: required string groupName,
        3: bool explicitMembers) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: GroupQueryException createError);

    /**
     * Get all members belonging to a group, including Users and App Users
     *
     * @param token EzSecurityToken belonging to the party performing the query
     * @param groupName the name of the group being queried
     *
     * @return set of group member principals
     */
    GroupMembers getGroupApps(
        1: required EzSecurityToken token,
        2: required string groupName,
        3: bool explicitMembers) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: GroupQueryException createError);

    /**
     * Get all members belonging to a group, including Users and App Users
     *
     * @param token EzSecurityToken belonging to the party performing the query
     * @param groupName the name of the group being queried
     *
     * @return set of group member principals
     */
    GroupMembers getGroupUsers(
        1: required EzSecurityToken token,
        2: required string groupName,
        3: bool explicitGroups) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: GroupQueryException createError);

    /**
     * Return the set of group IDs the principal in the token has access to. This could be either a user
     * or an app
     */
    set<i64> getAuthorizations(
        1: required EzSecurityToken token) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: GroupQueryException createError);

    /**
     * Return the set of groups (group name + group id) the user has access to, along with the users
     */
    set<UserGroup> getUserGroups(
        1: required EzSecurityToken token,
        3: required bool explicitOnly) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: GroupQueryException createError)

    set<string> getUserDiagnosticApps(
        1: required EzSecurityToken token) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: GroupQueryException createError);

    set<string> getUserMetricsApps(
        1: required EzSecurityToken token) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: GroupQueryException createError);

    set<string> getUserAuditorApps(
        1: required EzSecurityToken token) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: GroupQueryException createError);

    set<UserGroup> getAppUserGroups(
        1: required EzSecurityToken token,
        3: required bool explicitOnly) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: GroupQueryException createError);

    /**
     * Check whether or not the principal in the token has access to the named group
     *
     * @param token the token for the user who's groups are being checked
     * @param groupName the name for which the user's access is being checked
     *
     * @return true if the user has access to the group
     */
    bool checkUserAccessToGroup(
        1: required EzSecurityToken token,
        2: required string groupName) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: GroupQueryException createError);

    /* ---------------------------------------------------------------------------------- */
    /* ---------------------------------------------------------------------------------- */
    /*                               Privileged Actions                                   */
    /* ---------------------------------------------------------------------------------- */
    /*  These should only be executed by privileged system services, usually that         */
    /*  mean EzSecurity. The restriction can be enforced in two different ways (or both)  */
    /*      1) Token Security ID must be 02 or _Ez_Security                               */
    /*      2) Peer X509 cert CN must be _Ez_Security                                     */
    /* ---------------------------------------------------------------------------------- */
    /* ---------------------------------------------------------------------------------- */

    /**
     * Create a new user and immediately return the user's authorizations.
     *
     * @param token an EzSecurity token that has been issuedFor EzGroups
     * @param appChain the apps in the request chain. These are used to filter the returned groups
     * @param userId the id of the user being queried
     * @param name name of the user, used when creating the user
     *
     * @return a set of group ids
     */
    set<i64> createUserAndGetAuthorizations(
        1: required EzSecurityToken token,
        2: required list<string> appChain,
        3: required string userId,
        4: string name) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: EzGroupOperationException createError,
            4: GroupQueryException queryError);

    /**
     * Return the set of group IDs the user has data access to, limited by the groups the user in the token has data
     * access to
     */
    set<i64> getUserAuthorizations(
        1: required EzSecurityToken token,
        2: required TokenType userType,
        3: required string userID,
        4: required list<string> appChain) throws (
            1: EzBakeBase.EzSecurityTokenException tokenError,
            2: AuthorizationException authorizationError,
            3: GroupQueryException createError);
}
