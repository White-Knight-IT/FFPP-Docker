#!/bin/bash

sudo rm -rf ~/FFPP-Docker/shared_persistent_volume/mariadb_data/*

sudo rm ~/FFPP-Docker/shared_persistent_volume/api.zeroconf

sudo sh ~/FFPP-Docker/linux/recovery_scripts/purge_docker.sh
