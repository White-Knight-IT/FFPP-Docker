#!/bin/bash

sudo docker image ls -q | xargs -I {} sudo docker image rm -f {}
