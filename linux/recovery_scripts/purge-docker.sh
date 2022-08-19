#!/bin/bash

# Stop all running containers
sudo docker stop $(sudo docker ps -a -q)

# Delete all containers
sudo docker rm $(sudo docker ps -a -q)

# Delete all images
sudo docker image ls -q | xargs -I {} sudo docker image rm -f {}
