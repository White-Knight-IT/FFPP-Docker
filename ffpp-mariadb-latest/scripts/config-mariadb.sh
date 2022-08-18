#!/bin/bash

envsubst '${MARIADB_PORT}' < /root/config/templates/my.template > /etc/alternatives/my.cnf
