FROM mariadb:jammy

ARG TIMEZONE

ARG MARIADB_USER

ARG MARIADB_PASSWORD

ARG MARIADB_PORT

COPY config /root/config

COPY scripts /root/scripts

WORKDIR /root/scripts

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get upgrade -yq

RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install tzdata openssl ca-certificates nano dnsutils net-tools gettext-base

RUN . /root/scripts/config-mariadb.sh

ENV MARIADB_RANDOM_ROOT_PASSWORD yes

ENV MARIADB_ROOT_HOST 127.0.0.1

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

# COPY ./sql-scripts/ /docker-entrypoint-initdb.d/
