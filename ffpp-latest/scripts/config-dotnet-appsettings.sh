#!/bin/bash
rm -rf /root/ffpp/src/FFPP/appsettings*

envsubst '${ARG_FFPP_DOMAIN} ${ARG_MARIADB_USER} ${ARG_MARIADB_PASSWORD} ${ARG_MARIADB_SERVER} ${ARG_MARIADB_PORT} ${ARG_SHOW_DEV_ENDPOINTS} ${ARG_DNS_PROVIDER}' < /root/config/templates/appsettings.template > /root/ffpp/built/appsettings.json

cp /root/ffpp/built/appsettings.json /root/ffpp/src/FFPP/appsettings.json
