#!/bin/bash

envsubst '${MARIADB_PORT}' < /root/config/templates/my.template > /etc/alternatives/my.cnf

cp /etc/alternatives/my.cnf /etc/mysql/mariadb.cnf
