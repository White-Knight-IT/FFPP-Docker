#!/bin/bash

cd ~/FFPP-Docker/linux

sudo rm -rf ~/FFPP-Docker/shared_persistent_volume/mariadb_data/*

sudo rm ~/FFPP-Docker/shared_persistent_volume/api.zeroconf.aes

sh ~/FFPP-Docker/linux/recovery_scripts/purge_docker.sh
