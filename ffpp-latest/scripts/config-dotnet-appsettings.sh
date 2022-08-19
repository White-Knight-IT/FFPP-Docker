#!/bin/bash

envsubst '${FFPP_DOMAIN} ${MARIADB_USER} ${MARIADB_PASSWORD} ${MARIADB_SERVER} ${MARIADB_PORT} ${SHOW_DEV_ENDPOINTS} ${DNS_PROVIDER}' < /root/config/templates/appsettings.template > /root/ffpp/built/appsettings.json

cp /root/ffpp/built/appsettings.json /root/ffpp/src/FFPP/appsettings.json
