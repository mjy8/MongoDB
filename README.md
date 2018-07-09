# MongoDB
MongoDB Sharded Cluster setup in Docker Containers (Docker-compose)


Use Docker-compose to create 8 node (3 node shards + 3 node config server + 2 node mongos router) containers for MongoDB Cluster:

Run this command to start containers with compose : 
- docker-compose -f MongoDB_ClusterConfig.yaml up -d
- MongoDB_ClusterConfig.yaml -> This yaml file creates the entire 8 node containers for MongoDB which includes routers, config servers and shards with replicaset initiated.

Check the container status with:
- bash-4.2$ docker-compose -f MongoDB_ClusterConfig.yaml ps

Initiate the shard and config server replica set with script: ConfigureReplicaset.sh

Check the status for shard and config server replicaset:

- docker exec -it mongoconfig1 bash -c "echo 'rs.status()' | mongo"
- docker exec -it mongoshard1 bash -c "echo 'rs.status()' | mongo"
- docker exec -it mongosrouter1 bash -c "echo 'sh.status()' | mongo "

Add shard to the router with script: InitiateShards.sh ( This will make sure mongos routers are aware of all the sharded replicaset)
