#!/bin/sh

#Create DB
docker exec -it mongosrouter1 bash -c "echo 'use nbxDB' | mongo"
#Enable sharding on DB
docker exec -it mongosrouter1 bash -c "echo 'sh.enableSharding(\"nbxDB\")' | mongo"
#Create Collection 
docker exec -it mongosrouter1 bash -c "echo 'db.createCollection(\"nbxDB.nbximage\")' | mongo "
#Create Collection based on the hased shard key _id
docker exec -it mongosrouter1 bash -c "echo 'sh.shardCollection(\"nbxDB.nbximage\", {\"_id\" : \"hashed\"})' | mongo"
