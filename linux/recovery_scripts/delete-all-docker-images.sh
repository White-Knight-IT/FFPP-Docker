#!/bin/bash

# Stop all running containers
sudo docker stop $(sudo docker ps -a -q)

# Delete all images (which also deletes containers)
sudo docker image ls -q | xargs -I {} sudo docker image rm -f {}
