#!/bin/sh
# This script configures replica set by adding members for Shard and Config server and making mongos router aware of sharded replica set.
config_serverName1=mongoconfig1
config_serverName2=mongoconfig2
config_serverName3=mongoconfig3
config_replicasetName=mongoreplicaset1conf

shard1_name=mongoshard1
shard2_name=mongoshard2
shard3_name=mongoshard3
shard_replicasetName=mongoreplicaset1shard

mongosRouter1_name=mongosrouter1
mongosRouter2_name=mongosrouter2

#Map Config server replica set with rs.initiate
docker exec -it ${config_serverName1} bash -c \
"echo 'rs.initiate({_id: \"${config_replicasetName}\",configsvr: true, \
members: [{ _id : 0, host : \"${config_serverName1}\" },{ _id : 1, host : \"${config_serverName2}\" }, { _id : 2, host : \"${config_serverName3}\" }]})' | mongo" 

echo "Map Config server replica set with rs.initiate ..."

#Map Shard replica set to its associated members with rs.initiate
docker exec -it ${shard1_name} bash -c \
"echo 'rs.initiate({_id : \"${shard_replicasetName}\", \
members: [{ _id : 0, host : \"${shard1_name}\" },{ _id : 1, host : \"${shard2_name}\" },{ _id : 2, host : \"${shard3_name}\" }]})' | mongo" 

echo "Map Shard replica set to its associated members with rs.initiate..."

#source /data/yjayapra/InititeShards.sh
#sleep 20s
#Configure Mongos-router with sh.addShard(config)
#docker exec -it ${mongosRouter1_name} bash -c "echo 'sh.addShard(\"${shard_replicasetName}/${shard1_name}\")' | mongo" 

#echo "Configure Mongos-router with sh.addShard ..."
