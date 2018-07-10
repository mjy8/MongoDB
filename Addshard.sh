#!/bin/sh

#Add new Shard with different replicaset
docker run --hostname mongoshard4 --network yjayapra_mongobridge -p 27099:27017 --name mongoshard4 -v /var/lib/docker/volumes/mongodb_shard4/_data:/data/db -d mongo bash -c 'mongod --shardsvr --replSet mongoreplicaset2shard --dbpath /data/db --bind_ip=0.0.0.0,:: --port 27017'
#Initiate the replicaset to set primary
sleep 5s
docker exec -it mongoshard4 bash -c "echo 'rs.initiate({_id : \"mongoreplicaset2shard\", members: [{ _id : 0, host : \"mongoshard4\" }]})' | mongo"
#Add this shard to sam router
docker exec -it mongosrouter1 bash -c "echo 'sh.addShard(\"mongoreplicaset2shard/mongoshard4\")' | mongo "
