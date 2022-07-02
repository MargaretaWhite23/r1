####COMMANDS FOR TESTING BUILD IN DOCKER CONTAINER
####REPLACE STRINGS WITH ACTUALS IDS FROM IMAGE/CONTAINER LIST

docker pull debian:unstable

#docker image list

#Map TCP port 22 in the container to port 2280 on the Docker host.
docker run -dit b7ea56f7177f -p 2280:22 60000-61000:60000-61000/udp
#https://stackoverflow.com/questions/28717464/docker-expose-all-ports-or-range-of-ports-from-7000-to-8000
#https://stackoverflow.com/questions/27596409/how-do-i-publish-a-udp-port-on-docker

docker attach b6f07fce1f62


#install software
apt install -y screen vim ssh unzip curl
cp ~/config-5.18.0-2-amd64 /

##install locale on docker (for mosh)
#https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-debian-ubuntu-docker-container
#apt install -y locales
#locale-gen en_GB.UTF-8
#sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen &&     locale-gen
#LC_ALL="en_US.UTF-8" mosh-server

##add port mapping
#docker port b6f07fce1f62 80
#https://www.cloudbees.com/blog/docker-expose-port-what-it-means-and-what-it-doesnt-mean

##OLD UNUSUED
#docker container create b7ea56f7177f
#docker container list -a
