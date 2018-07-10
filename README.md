# MongoDB in Docker Containers
MongoDB Sharded Cluster setup in Docker Containers (Docker-compose)


Use Docker-compose to create 8 node (3 node shards + 3 node config server + 2 node mongos router) containers for MongoDB Cluster:

Run this command to start containers with compose : 
- docker-compose -f MongoDB_ClusterConfig.yaml up -d
- MongoDB_ClusterConfig.yaml -> This yaml file creates the entire 8 node containers for MongoDB which includes routers, config servers and shards with replicaset initiated.

Check the container status with:
- bash-4.2$ docker-compose -f MongoDB_ClusterConfig.yaml ps

Initiate the shard and config server replica set with script: 
- ConfigureReplicaset.sh

Check the status for shard and config server replicaset:

- docker exec -it mongoconfig1 bash -c "echo 'rs.status()' | mongo"
- docker exec -it mongoshard1 bash -c "echo 'rs.status()' | mongo"
- docker exec -it mongosrouter1 bash -c "echo 'sh.status()' | mongo "

Add shard to the router with script: 
- InitiateShards.sh ( This will make sure mongos routers are aware of all the sharded replicaset)

------------------------------------------------------------------------------------------------------------
OR

# Manually run Docker commands to setup the MongoDB cluster in Containers:

- docker network create mongo_bridge --driver bridge
Docker does not support automatic service discovery on the default bridge network and the user defined network can resolve containers IP addresses by name.

- docker volume create --name mongodb_shard (similar for mongodb_shard2 and mongodb_shard3)
These data volumes are created for Shard nodes which maps to /data/db ( using --dbpath for mongod nodes).

- docker volume inspect mongodb_shard

Create Shard nodes:

- docker run --hostname mongoshard1 --network mongo_bridge -p 27017:27017 --name mongoshard1 
-v /var/lib/docker/volumes/mongodb_shard/_data:/data/db -d mongo bash -c 'mongod --shardsvr --replSet mongoreplicaset1shard --dbpath /data/db --bind_ip=0.0.0.0,:: --port 27017'

docker run --hostname mongoshard2 --network mongo_bridge -p 27027:27017 --name mongoshard2 
-v /var/lib/docker/volumes/mongodb_shard2/_data:/data/db -d mongo bash -c 'mongod --shardsvr --replSet mongoreplicaset1shard --dbpath /data/db --bind_ip=0.0.0.0,:: --port 27017'

docker run --hostname mongoshard3 --network mongo_bridge -p 27037:27017 --name mongoshard3 
-v /var/lib/docker/volumes/mongodb_shard3/_data:/data/db -d mongo bash -c 'mongod --shardsvr --replSet mongoreplicaset1shard --dbpath /data/db --bind_ip=0.0.0.0,:: --port 27017'

- These Shards can be primary, secondary/arbiter which stores collection of documents.

- Documents or chunks are distributed across multiple shards based on the shard key, more shards (replica set)  can be added added to scale these data nodes horizontally.
--shardsvr: define these nodes as Shards and added to the replica set with --replset parameter.
--bind_ip=0.0.0.0,:: -> This will bind all ipv4 and ipv6 address for mongod/mongos so the containers can talk to each other, by default mongod/mongos binds to only localhost.

Create Config nodes:

docker volume create --name mongoconfig1 (similar for mongoconfig2 and mongoconfig3)

docker run --hostname mongoconfig1 --network mongo_bridge -p 27047:27017 --name mongoconfig1 
-v /var/lib/docker/volumes/mongoconfig1/_data:/data/db -d mongo bash -c 'mongod --configsvr --replSet mongoreplicaset1conf --dbpath /data/db --bind_ip=0.0.0.0,:: --port 27017'

docker run --hostname mongoconfig2 --network mongo_bridge -p 27057:27017 --name mongoconfig2 
-v /var/lib/docker/volumes/mongoconfig2/_data:/data/db -d mongo bash -c 'mongod --configsvr --replSet mongoreplicaset1conf --dbpath /data/db --bind_ip=0.0.0.0,:: --port 27017'
 
docker run --hostname mongoconfig3 --network mongo_bridge -p 27067:27017 --name mongoconfig3 
-v /var/lib/docker/volumes/mongoconfig3/_data:/data/db -d mongo bash -c 'mongod --configsvr --replSet mongoreplicaset1conf --dbpath /data/db --bind_ip=0.0.0.0,:: --port 27017'

- These Config server replica set stores all metadata and cluster configuration.
--configsvr : define these nodes as config server and are added to same replica set mongoreplicaset1conf. 

Create Routers:


docker run --hostname mongosrouter1 --network mongo_bridge -p 27077:27017 --name mongosrouter1 -d mongo 
bash -c 'mongos --configdb mongoreplicaset1conf/mongoconfig1:27017,mongoconfig2:27017,mongoconfig3:27017 --bind_ip=0.0.0.0,:: --port 27017'

docker run --hostname mongosrouter2 --network mongo_bridge -p 27087:27017 --name mongosrouter2 -d mongo 
bash -c 'mongos --configdb mongoreplicaset1conf/mongoconfig1:27017,mongoconfig2:27017,mongoconfig3:27017 --bind_ip=0.0.0.0,:: --port 27017'

These routers acts as an interface between client application and shards.
 Mongos routers are dependent on config server, so with --configdb param to get metadata and config information from config server replicaset.
docker run --hostname mongosrouter1 --network mongo_bridge -p 27077:27017 --name mongosrouter1 -d mongo 
bash -c 'mongos --configdb mongoreplicaset1conf/mongoconfig1:27017,mongoconfig2:27017,mongoconfig3:27017 --bind_ip=0.0.0.0,:: --port 27017'

docker run --hostname mongosrouter2 --network mongo_bridge -p 27087:27017 --name mongosrouter2 -d mongo 
bash -c 'mongos --configdb mongoreplicaset1conf/mongoconfig1:27017,mongoconfig2:27017,mongoconfig3:27017 --bind_ip=0.0.0.0,:: --port 27017'

Inititate the Config node replica set:
On one of the config server try to initiate the replica set with rs.initiate(config) members which started with --replSet param.
This will assign primary and secondary replica set for config servers.

docker exec -it mongoconfig1 bash -c 
"echo 'rs.initiate({_id: \"mongoreplicaset1conf\",configsvr: true, 
members: [{ _id : 0, host : \"mongoconfig1\" },{ _id : 1, host : \"mongoconfig2\" }, { _id : 2, host : \"mongoconfig3\" }]})' | mongo"


Inititate the Shard node replica set:
On one of the Shard node try to initiate the replica set with rs.initiate(config) members which started with --replSet param.
This will assign primary and secondary replica set for Shard nodes.

 docker exec -it mongoshard1 bash -c 
"echo 'rs.initiate({_id : \"mongoreplicaset1shard\", 
members: [{ _id : 0, host : \"mongoshard1\" },{ _id : 1, host : \"mongoshard2\" },{ _id : 2, host : \"mongoshard3\" }]})' | mongo"

Add shards to Router:
Finally we make mongos-router aware of sharded replicaset by sh.addshard().
Need to run this addshard() on one of the mongos-routers, which initiates the sharded-replicaset in routers so they can talk to these shards.

docker exec -it mongosrouter1 bash -c "echo 'sh.addShard(\"mongoreplicaset1shard/mongoshard1\")' | mongo "



