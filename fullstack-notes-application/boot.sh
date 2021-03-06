#!/bin/bash
set -e

printf "creating backend network --->\n"
docker network create fullstack-notes-application-network-backend;
printf "network backend created --->\n"

printf "\n"

printf "starting db container --->\n"
docker container run \
    --detach \
    --name=db \
    --env POSTGRES_DB=notesdb \
    --env POSTGRES_PASSWORD=secret \
    --network=fullstack-notes-application-network-backend \
    postgres:12;
printf "db container started --->\n"

printf "\n"

cd api;
printf "creating api image --->\n"
docker image build . --tag notes-api;
printf "api image created --->\n"
printf "starting api container --->\n"
docker container run \
    --detach \
    --name=api \
    --env-file .env \
    --network=fullstack-notes-application-network-backend \
    notes-api;
docker container exec api npm run db:migrate;
printf "api container started --->\n"

cd ..
printf "\n"

printf "creating frontend network --->\n"
docker network create fullstack-notes-application-network-frontend;
printf "network frontend created --->\n"

printf "\n"

cd client;
printf "creating client image --->\n"
docker image build . --tag notes-client;
printf "client image created --->\n"
printf "starting client container --->\n"
docker container run \
    --detach \
    --name=client \
    --network=fullstack-notes-application-network-frontend \
    notes-client;
printf "client container started --->\n"

cd ..
printf "\n"

cd nginx;
printf "creating router image --->\n"
docker image build . --tag notes-router;
printf "router image created --->\n"
printf "creating router container --->\n"
docker container create \
    --publish=8080:80 \
    --name=router \
    notes-router;
printf "router container created --->\n"
printf "adding router to backend network --->\n"
docker network connect fullstack-notes-application-network-backend router
printf "router added to backend network --->\n"
printf "adding router to frontend network --->\n"
docker network connect fullstack-notes-application-network-frontend router
printf "router added to frontend network --->\n"
printf "starting router container --->\n"
docker container start router;
printf "router container started --->\n"

cd ..
printf "\n"

printf "all containers are up and running"