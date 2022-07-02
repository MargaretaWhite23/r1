####COMMANDS FOR TESTING BUILD IN DOCKER CONTAINER
####REPLACE STRINGS WITH ACTUALS IDS FROM IMAGE/CONTAINER LIST

docker pull debian:unstable

#docker image list

#Map TCP port 22 in the container to port 2280 on the Docker host.
docker run -dit b7ea56f7177f -p 2280:22
docker attach b6f07fce1f62

#install software
apt install -y screen vim ssh unzip curl
cp ~/config-5.18.0-2-amd64 /

##add port mapping
#docker port b6f07fce1f62 80
#https://www.cloudbees.com/blog/docker-expose-port-what-it-means-and-what-it-doesnt-mean

##OLD UNUSUED
#docker container create b7ea56f7177f
#docker container list -a
