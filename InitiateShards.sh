#!/bin/sh

mongosRouter1_name=mongosrouter1
mongosRouter2_name=mongosrouter2
shard_replicasetName=mongoreplicaset1shard
shard1_name=mongoshard1

#Configure Mongos-router with sh.addShard(config)
docker exec -it ${mongosRouter1_name} bash -c "echo 'sh.addShard(\"${shard_replicasetName}/${shard1_name}\")' | mongo" 

echo "Configure Mongos-router with sh.addShard ..."

