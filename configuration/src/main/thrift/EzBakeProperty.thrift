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

 namespace * ezbake.configuration.constants

//
// Accumulo Constants
//

/**
 * Property which represents the name of the accumulo instance
 */
const string ACCUMULO_INSTANCE_NAME = "accumulo.instance.name";

/**
 * Property which represents the namespace in accumulo we are working in
 */
const string ACCUMULO_NAMESPACE = "accumulo.namespace";

/**
 * Encrypted Property which represents the password for the user to connect to the database with
 */
const string ACCUMULO_PASSWORD = "accumulo.password";

/**
 * Property used to indicate whether our connector is in mock mode
 */
const string ACCUMULO_USE_MOCK = "accumulo.use.mock";

/**
 * Property which is the username we connect to the database with
 */
const string ACCUMULO_USERNAME = "accumulo.username";

/**
 * Property which is a CSV of zookeeper connection strings (host:port) which are the zookeeper servers that accumulo
 * users
 */
const string ACCUMULO_ZOOKEEPERS = "accumulo.zookeepers";

/**
 * Property which specifies the port of the accumulo proxy
 */
const string ACCUMULO_PROXY_PORT = "accumulo.proxy.port";

/**
 * Property which specifies the hostname of the accumulo proxy
 */
const string ACCUMULO_PROXY_HOST = "accumulo.proxy.host";

/**
 * Property which specifies if accumulo clients should use SSL
 */
const string ACCUMULO_USE_SSL = "accumulo.use.ssl";

/**
 * Property which specifies the path to the accumulo truststore
 */
const string ACCUMULO_SSL_TRUSTSTORE_PATH = "accumulo.ssl.truststore.path";

/**
 * Property which specifies the type of the accumulo truststore
 */
const string ACCUMULO_SSL_TRUSTSTORE_TYPE = "accumulo.ssl.truststore.type";

/**
 * Property which specifies the password for the accumulo truststore
 */
const string ACCUMULO_SSL_TRUSTSTORE_PASSWORD = "accumulo.ssl.truststore.password";

//
// Application Constants
//

/**
 * Property which represents the name of the application
 */
const string EZBAKE_APPLICATION_NAME = "application.name";

/**
 * Property which represents the version of the application
 */
const string EZBAKE_APPLICATION_VERSION = "ezbake.application.version";

/**
 * Property which specifies the instance of this install
 */
const string EZBAKE_APPLICATION_INSTANCE_NUMBER = "ezbake.application.instance.number";

//
// Azkaban Constants
//

/**
 * Property which represents url for azkaban
 */
const string AZKABAN_URL = "azkaban.url";

/**
 * Property which represents azkaban password
 */
const string AZKABAN_PASSWORD = "azkaban.password";

/**
 * Property which represents azkaban username
 */
const string AZKABAN_USERNAME = "azkaban.username";

//
// Elasticsearch Constants
//

/**
 * Property which represents Elasticsearch cluster name
 */
const string ELASTICSEARCH_CLUSTER_NAME = "elastic.cluster.name";

/**
 * Property which represents Elasticsearch force refresh
 */
const string ELASTICSEARCH_FORCE_REFRESH_ON_PUT = "elastic.force.refresh";

/**
 * Property which represents Elasticsearch host name
 */
const string ELASTICSEARCH_HOST = "elastic.host.name";

/**
 * Property which represents Elasticsearch Java API port
 */
const string ELASTICSEARCH_PORT = "elastic.port";

/**
 * Property which represents Elasticsearch Thrift API port
 */
const string ELASTICSEARCH_THRIFT_PORT = "elastic.port.thrift";

//
// Hadoop Constants
//

/**
 * Property which represents ezconfig string to get default filesystem name
 */
const string HADOOP_FILESYSTEM_NAME = "fs.default.name";

/**
 * Property which represents ezconfig string to get hdfs implementation
 */
const string HADOOP_FILESYSTEM_IMPL = "fs.hdfs.impl";

/**
 * Property which represents ezconfig string to get filesystem use local value
 */
const string HADOOP_FILESYSTEM_USE_LOCAL = "fs.use.local";

//
// Flume Constants
//

/**
 * Property which represents flume key for agent type
 */
const string FLUME_AGENT_TYPE = "flume.agent.type";

/**
 * Property which represents flume key for backoff
 */
const string FLUME_BACK_OFF = "flume.backoff";

/**
 * Property which represents flume key for batch size
 */
const string FLUME_BATCH_SIZE = "flume.batch.size";

/**
 * Property which represents flume key for connect attempts
 */
const string FLUME_CONNECT_ATTEMPTS = "flume.connect.attempts";

/**
 * Property which represents flume key for connect timeout
 */
const string FLUME_CONNECT_TIMEOUT = "flume.connect.timeout";

/**
 * Property which represents flume key for headers
 */
const string FLUME_HEADERS = "flume.headers";

/**
 * Property which represents flume key for host selector
 */
const string FLUME_HOST_SELECTOR = "flume.host.selector";

/**
 * Property which represents flume key for hosts
 */
const string FLUME_HOSTS = "flume.hosts";

/**
 * Property which represents flume key for max attempts
 */
const string FLUME_MAX_ATTEMPTS = "flume.max.attempts";

/**
 * Property which represents flume key for max backoff
 */
const string FLUME_MAX_BACKOFF = "flume.max.backoff";

/**
 * Property which represents flume key for max events
 */
const string FLUME_MAX_EVENTS = "flume.max.events";

/**
 * Property which represents flume key for request timeout
 */
const string FLUME_REQUEST_TIMEOUT = "flume.request.timeout";

/**
 * Property which represents flume key for run interval
 */
const string FLUME_RUN_INTERVAL = "flume.run.interval";

/**
 * Property which represents flume key for sleep interval
 */
const string FLUME_SLEEP_INTERVAL = "flume.sleep.interval";

//
// Kafka Constants
//

/**
 * Property which represents kafka zookeeper connection string
 */
const string KAFKA_ZOOKEEPER = "kafka.zookeeper.connect";

/**
 * Property which represents kafka broker list ezconfig property
 */
const string KAFKA_BROKER_LIST = "kafka.metadata.broker.list";

/**
 * Property which represents the time that messages stay in memory before flushed to Kafka if using an async producer (in milliseconds)
 */
const string KAFKA_QUEUE_TIME = "kafka.queue.time";

/**
 * Property which represents the amount of messages that are queued in memory before flushing to Kafka if using an async producer
 */
const string KAFKA_QUEUE_SIZE = "kafka.queue.size";

/**
 * Property which represents the type of producer (sync or async) used by Kafka
 */
const string KAFKA_PRODUCER_TYPE = "kafka.producer.type";

/**
 * Property which represents the zookeeper timeout for Kafka consumers
 */
const string KAFKA_ZOOKEEPER_SESSION_TIMEOUT = "kafka.zk.sessiontimeout.ms";

//
// Mongo Configuration Constants
//

/**
 * Property which represents mongo db host name ezconfig key
 */
const string MONGODB_HOST_NAME = "mongodb.host.name";

/**
 * Property which represents mongo db port number key
 */
const string MONGODB_PORT = "mongodb.port";

/**
 * Property which represents mongo db database name ezconfig key
 */
const string MONGODB_DB_NAME = "mongodb.database.name";

/**
 * Property which represents mongo db user name ezconfig key
 */
const string MONGODB_USER_NAME = "mongodb.user.name";

/**
 * Property which represents mongo db password ezconfig key
 */
const string MONGODB_PASSWORD = "mongodb.password";

/**
 * Property which represents mongo db use ssl ezconfig key
 */
const string MONGODB_USE_SSL = "mongodb.use.ssl";

/**
 * Property which represents the connection string that can be used to access mongo
 */
const string MONGODB_CONNECTION_STRING = "mongodb.connection.string";

//
// Postgres Constants
//

/**
 * Property which represents postgres db ezconfig key
 */
const string POSTGRES_DB = "postgres.db";

/**
 * Property which represents postgres host ezconfig key
 */
const string POSTGRES_HOST = "postgres.host";

/**
 * Property which represents postgres password ezconfig key
 */
const string POSTGRES_PASSWORD = "postgres.password";

/**
 * Property which represents postgres port ezconfig key
 */
const string POSTGRES_PORT = "postgres.port";

/**
 * Property which represents postgres username ezconfig key
 */
const string POSTGRES_USERNAME = "postgres.username";

/**
 * Property which represents whether postgres connection uses ssl ezconfig key
 */
const string POSTGRES_USE_SSL = "postgres.use.ssl";

//
// Redis Constants
//

/**
 * Property which represents redis host ezconfig key
 */
const string REDIS_HOST = "redis.host";

/**
 * Property which represents redis post ezconfig key
 */
const string REDIS_PORT = "redis.port";

/**
 * Property which represents redis db index ezconfig key
 */
const string REDIS_DB_INDEX = "redis.db.index";

//
// Security Constants
//

/**
 * Property which represents the security id
 */
const string EZBAKE_SECURITY_ID = "ezbake.security.app.id";

/**
 * Property which represents cache type ezconfig key
 */
const string EZBAKE_USER_CACHE_TYPE = "ezbake.security.cache.type";

/**
 * Property which represents cache ttl ezconfig key
 */
const string EZBAKE_USER_CACHE_TTL = "ezbake.security.cache.ttl";

/**
 * Property which represents cache size ezconfig key
 */
const string EZBAKE_USER_CACHE_SIZE = "ezbake.security.cache.size";

/**
 * Property which represents request expiration ezconfig key
 */
const string EZBAKE_REQUEST_EXPIRATION = "ezbake.security.request.expiration";

/**
 * Property which represents token expiration ezconfig key
 */
const string EZBAKE_TOKEN_EXPIRATION = "ezbake.security.token.ttl";

/**
 * Property which represents how long after being issued a proxy token should be valid
 */
const string EZBAKE_SECURITY_PROXYTOKEN_TTL = "ezbake.security.proxytoken.ttl";

/**
 * Property which represents how long after expiration a token can be re-issued
 */
const string EZBAKE_SECURITY_TOKEN_REFRESH_LIMIT = "ezbake.security.token.refresh.limit";

/**
 * Property which represents app registration implementation ezconfig key
 */
const string EZBAKE_APP_REGISTRATION_IMPL = "ezbake.security.app.service.impl";

/**
 * Property which represents admins file ezconfig key
 */
const string EZBAKE_ADMINS_FILE = "ezbake.security.admins.file";

/**
 * Property which represents service implementation ezconfig key
 */
const string EZBAKE_USER_SERVICE_IMPL = "ezbake.security.user.service.impl";

/**
 * Property which represents mock server ezconfig key
 */
const string EZBAKE_SECURITY_SERVICE_MOCK_SERVER = "ezbake.security.server.mock";

/**
 * Property which represents use forward proxy ezconfig key
 */
const string EZBAKE_USE_FORWARD_PROXY = "ezbake.frontend.use.forward.proxy";

/**
 * Property which represents ssl protocol ezconfig key
 */
const string EZBAKE_SSL_PROTOCOL_KEY = "ezbake.ssl.protocol";

/**
 * Property which represents ssl ciphers ezconfig key
 */
const string EZBAKE_SSL_CIPHERS_KEY = "ezbake.ssl.ciphers";

/**
 * Property which represents peer validation ezconfig key
 */
const string EZBAKE_SSL_PEER_AUTH_REQUIRED = "ezbake.ssl.peer.validation";

/**
 * Property which tells us if we are using the default ssl key
 */
const string EZBAKE_SSL_USE_DEFAULT_SSL_KEY = "ezbake.security.default.ssl";

/**
 * Property which represents the trusted certificates file
 */
const string EZBAKE_APPLICATION_TRUSTED_CERT = "ezbake.ssl.trustedcert.file";

/**
 * Property which represents the private key file
 */
const string EZBAKE_APPLICATION_PRIVATE_KEY_FILE = "ezbake.ssl.privatekey.file";

/**
 * Property which represents the certificates file
 */
const string EZBAKE_APPLICATION_CERT_FILE = "ezbake.ssl.certificate.file";

/**
 * Property which represents the public key file for a service
 */
const string EZBAKE_APPLICATION_PUBLIC_KEY_FILE = "ezbake.ssl.servicekey.file";

//
// SSL Constants
//

/**
 * Property which represents the path to the system keystore
 */
const string SYSTEM_KEYSTORE_PATH = "system.keystore.path";

/**
 * Property which represents the type of the system keystore
 */
const string SYSTEM_KEYSTORE_TYPE = "system.keystore.type";

/**
 * Property which represents the password for the system keystore
 */
const string SYSTEM_KEYSTORE_PASSWORD = "system.keystore.password";

/**
 * Property which represents the path to the system truststore
 */
const string SYSTEM_TRUSTSTORE_PATH = "system.truststore.path";

/**
 * Property which represents the type of the system truststore
 */
const string SYSTEM_TRUSTSTORE_TYPE = "system.truststore.type";

/**
 * Property which represents the password for the system truststore
 */
const string SYSTEM_TRUSTSTORE_PASSWORD = "system.truststore.password";

/**
 * Property which represents keystore file ezconfig key
 */
const string EZBAKE_APPLICATION_KEYSTORE_FILE = "ezbake.ssl.keystore.file";

/**
 * Property which represents keystore type ezconfig key
 */
const string EZBAKE_APPLICATION_KEYSTORE_TYPE = "ezbake.ssl.keystore.type";

/**
 * Property which represents keystore password ezconfig key
 */
const string EZBAKE_APPLICATION_KEYSTORE_PASS = "ezbake.ssl.keystore.pass";

/**
 * Property which represents truststore file ezconfig key
 */
const string EZBAKE_APPLICATION_TRUSTSTORE_FILE = "ezbake.ssl.truststore.file";

/**
 * Property which represents truststore type ezconfig key
 */
const string EZBAKE_APPLICATION_TRUSTSTORE_TYPE = "ezbake.ssl.truststore.type";

/**
 * Property which represents truststore password ezconfig key
 */
const string EZBAKE_APPLICATION_TRUSTSTORE_PASS = "ezbake.ssl.truststore.pass";

//
// Service Constants
//

/**
 * Property representing the location to the certificates directory
 */
const string EZBAKE_CERTIFICATES_DIRECTORY = "ezbake.security.ssl.dir";

/**
 * Property which represents the name of the service
 */
const string EZBAKE_SERVICE_NAME = "service.name";

//
// Storm Constants
//

/**
 * Property representing the nimbus host
 */
const string STORM_NIMBUS_HOST = "storm.nimbus.host";

/**
 * Property representing the nimbus port
 */
const string STORM_NIMBUS_THRIFT_PORT = "storm.nimbus.thrift.port";

//
// System Constants
//

/**
 * Property which represents ezbake admin application deployment ezconfig key
 */
const string EZBAKE_ADMIN_APPLICATION_DEPLOYMENT = "ezbake.system.admin.application.deployment";

/**
 * Property which represents ezbake log directory ezconfig key
 */
const string EZBAKE_LOG_DIRECTORY = "ezbake.log.directory";

/**
 * Property which represents ezbake log standard out ezconfig key
 */
const string EZBAKE_LOG_TO_STDOUT = "ezbake.log.stdout";

/**
 * Property which represents the environment variable for the shared secret
 */
const string EZBAKE_SHARED_SECRET_ENVIRONMENT_VARIABLE = "ezbake.shared.secret.environment.variable";

//
// Thrift Constants
//

/**
 * Property which represents thrifts max idle clients ezconfig key
 */
const string THRIFT_MAX_IDLE_CLIENTS = "thrift.max.idle.clients";

/**
 * Property which represents thrifts max pool clients ezconfig key
 */
const string THRIFT_MAX_POOL_CLIENTS = "thrift.max.pool.clients";

/**
 * Property which represents thrifts milliseconds between client eviction checks ezconfig key
 */
const string THRIFT_MILLIS_BETWEEN_CLIENT_EVICTION_CHECKS = "thrift.millis.between.client.eviction.checks";

/**
 * Property which represents thrifts milliseconds before client eviction ezconfig key
 */
const string THRIFT_MILLIS_IDLE_BEFORE_EVICTION = "thrift.millis.idle.before.eviction";

/**
 * Property which represents thrifts server mode ezconfig key
 */
const string THRIFT_SERVER_MODE = "thrift.server.mode";

/**
 * Property which represents thrifts test pool on borrow ezconfig key
 */
const string THRIFT_TEST_ON_BORROW = "thrift.test.pool.on.borrow";

/**
 * Property which represents thrifts test while idle ezconfig key
 */
const string THRIFT_TEST_WHILE_IDLE = "thrift.test.pool.while.idle";

/**
 * Property which represents thrifts use ssl ezconfig key
 */
const string THRIFT_USE_SSL = "thrift.use.ssl";

/**
 * Property which represents if the client pool should block on exhaustion or throw an exception
 */
const string THRIFT_BLOCK_WHEN_EXHAUSTED = "thrift.block.when.exhausted";

/**
 * Property which tells us to actually pool clients or not
 */
const string THRIFT_ACTUALLY_POOL_CLIENTS = "thrift.actually.pool.clients";

/**
 * Whether to log a stack trace whenever an object is abandoned from the pool
 */
const string THRIFT_LOG_ABANDONED = "thrift.pool.log.abandoned";

/**
 * Whether to abandon objects if they exceed the abandon timeout when borrow is called
 */
const string THRIFT_ABANDON_ON_BORROW = "thrift.pool.abandon.on.borrow";

/**
 * Whether to abandon objects if they exceed the abandon timeout when the evictor runs
 */
const string THRIFT_ABANDON_ON_MAINTENANCE = "thrift.pool.abandon.on.maintenance";

/**
 * Timeout in seconds before an abandoned object is removed
 */
const string THRIFT_ABANDON_TIMEOUT = "thrift.pool.abandon.timeout";

/**
 * Whether or not to use the thrift framed transport
 */
const string THRIFT_FRAMED_TRANSPORT = "tframe.transport";

//
// Web Application Constants
//

/**
 * Property which represents web application external domain ezconfig key
 */
const string EZBAKE_WEB_APPLICATION_EXTERNAL_DOMAIN = "web.application.external.domain";

/**
 * Property which represents web application metrics endpoint ezconfig key
 */
const string EZBAKE_WEB_APPLICATION_METRICS_ENDPOINT = "web.application.metrics.endpoint";

/**
 * Property which represents web application metrics siteid ezconfig key
 */
const string EZBAKE_WEB_APPLICATION_METRICS_SITEID = "web.application.metrics.siteid";

/**
 * Property which represents security description banner: text
 */
const string EZBAKE_WEB_APPLICATION_BANNER_TEXT = "web.application.security.banner.text";

/**
 * Property which represents security description banner: background color
 */
const string EZBAKE_WEB_APPLICATION_BANNER_BGCOLOR = "web.application.security.banner.background.color";

/**
 * Property which represents security description banner: text color
 */
const string EZBAKE_WEB_APPLICATION_BANNER_TEXTCOLOR = "web.application.security.banner.text.color";

//
// Zookeeper Constants
//

/**
 * Property which is a CSV of zookeeper servers (host:port)
 */
const string ZOOKEEPER_CONNECTION_STRING = "zookeeper.connection.string";

//
// MonetDB Constants
//

/**
 * Property which represents the MonetDB username
 */
const string MONETDB_USERNAME = "monetdb.username";

/**
 * Property which represents the MonetDB password
 */
const string MONETDB_PASSWORD = "monetdb.password";

/**
 * Property which represents the hostname of the MonetDB server
 */
const string MONETDB_HOSTNAME = "monetdb.hostname";

/**
 * Property which represents the port number on which MonetDB is running
 */
const string MONETDB_PORT = "monetdb.port";
