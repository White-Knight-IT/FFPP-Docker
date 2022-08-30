#!/bin/bash

cd ~/FFPP-Docker/linux

sh ~/FFPP-Docker/linux/recovery_scripts/purge_docker.sh

sudo rm -rf ~/FFPP-Docker/shared_persistent_volume/mariadb_data/*

sudo rm ~/FFPP-Docker/shared_persistent_volume/api.zeroconf.aes

sudo rm ~/FFPP-Docker/shared_persistent_volume/bootstrap.json

sudo rm ~/FFPP-Docker/shared_persistent_volume/unique.entropy.bytes
