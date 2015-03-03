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

namespace * ezbake.data.base.blob.thrift
namespace py ezbake.data.base.blob.thriftapi
namespace go ezbake.data.base.blob.thriftapi

include "EzBakeBase.thrift"
include "BaseDataService.thrift"

struct Blob {
    1: required string bucket;
    2: required string key;
    3: required binary blob;
    4: required EzBakeBase.Visibility visibility;
}

exception BlobException {
    1: string message
}

service EzBlob extends BaseDataService.BaseDataService {
    void putBlob(1: Blob entry, 2: EzBakeBase.EzSecurityToken security) throws (1: BlobException error);

    set<binary> getBlobs(
        1: string bucketName, 2: string key, 3:EzBakeBase.EzSecurityToken security) throws (1: BlobException error);

    i32 removeBlob(
        1: string bucketName, 2: string key, 3: EzBakeBase.EzSecurityToken security) throws (1: BlobException error);

    void copyBlob(
        1: string sourceBucketName,
        2: string sourceKey,
        3: string destinationBucketName,
        4: string destinationKey,
        5: EzBakeBase.EzSecurityToken security) throws (1: BlobException error);

    string createBucket(
        1: string bucketName,
        2: EzBakeBase.Visibility visibility,
        3: EzBakeBase.EzSecurityToken security) throws (1: BlobException error);

    void deleteBucket(1: string bucketName, 2: EzBakeBase.EzSecurityToken security) throws (1: BlobException error);

    bool doesBucketExist(1: string bucketName, 2: EzBakeBase.EzSecurityToken security) throws (1: BlobException error);

    bool doesBlobExist(
        1: string bucketName, 2: string key, 3: EzBakeBase.EzSecurityToken security) throws (1: BlobException error);

    list<EzBakeBase.Visibility> getBlobVisibility(
        1: string bucketName, 2: string key, 3: EzBakeBase.EzSecurityToken security) throws (1: BlobException error);

    EzBakeBase.Visibility getBucketVisibility(
        1: string bucketName, 2: EzBakeBase.EzSecurityToken security) throws (1: BlobException error);

    set<string> listBuckets(1: EzBakeBase.EzSecurityToken security) throws (1: BlobException error);

    list<Blob> listBlobs(1: string bucketName, 2: EzBakeBase.EzSecurityToken security) throws (1: BlobException error);

    void setBucketVisibility(
        1: string bucketName,
        2: EzBakeBase.Visibility visibility,
        3: EzBakeBase.EzSecurityToken security) throws (1: BlobException error);

    void setBlobVisibility(
        1: string bucketName,
        2: string key,
        3: EzBakeBase.Visibility visibility,
        4: EzBakeBase.EzSecurityToken security) throws (1: BlobException error);
}
