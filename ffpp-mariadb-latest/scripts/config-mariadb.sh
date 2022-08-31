#!/bin/bash

envsubst '${ARG_MARIADB_PORT}' < /root/config/templates/my.template > /etc/alternatives/my.cnf

envsubst '${ARG_MARIADB_USER}' < /root/scripts/1-init-script.sql > /docker-entrypoint-initdb.d/1-init-script.sql
