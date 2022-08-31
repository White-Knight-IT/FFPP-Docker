#!/bin/bash

envsubst '${ARG_MARIADB_PORT}' < /root/config/templates/my.template > /etc/alternatives/my.cnf
