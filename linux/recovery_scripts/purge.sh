#!/bin/bash

cd ~/FFPP-Docker/linux

sh ~/FFPP-Docker/linux/recovery_scripts/purge_docker.sh

sudo rm -rf ~/FFPP-Docker/persistent/ffpp-db/mariadb_data/*

sudo rm ~/FFPP-Docker/persistent/ffpp/api.zeroconf.aes

sudo rm ~/FFPP-Docker/persistent/ffpp/bootstrap.json

sudo rm ~/FFPP-Docker/persistent/ffpp/unique.entropy.bytes
