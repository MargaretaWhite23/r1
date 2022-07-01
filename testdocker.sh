####COMMANDS FOR TESTING BUILD IN DOCKER CONTAINER
####REPLACE STRINGS WITH ACTUALS IDS FROM IMAGE/CONTAINER LIST

docker pull debian:unstable

#docker image list
docker run -dit b7ea56f7177f
docker attach b6f07fce1f62

##OLD UNUSUED
#docker container create b7ea56f7177f
#docker container list -a
