FROM mariadb:jammy

ARG TIMEZONE

ARG MARIADB_USER

ARG MARIADB_PASSWORD

ARG MARIADB_PORT

ARG MARIADB_ROOT_PASSWORD

ENV MARIADB_ROOT_PASSWORD=wellknownpassword

ENV MARIADB_MYSQL_LOCALHOST_USER yes

ENV MARIADB_DATABASE ffpp

COPY config /root/config

COPY scripts /root/scripts

WORKDIR /root/scripts

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get upgrade -yq

RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install tzdata openssl ca-certificates nano dnsutils net-tools gettext-base

RUN . /root/scripts/config-mariadb.sh

# COPY ./sql-scripts/ /docker-entrypoint-initdb.d/
