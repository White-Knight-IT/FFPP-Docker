FROM mariadb:jammy

ARG TIMEZONE

ARG MARIADB_USER

ARG MARIADB_PASSWORD

COPY my.cnf /etc/alternatives/my.cnf

COPY my.cnf /etc/mysql/mariadb.cnf

ENV MARIADB_RANDOM_ROOT_PASSWORD yes

ENV MARIADB_ROOT_HOST localhost

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get upgrade -yq

RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install tzdata openssl ca-certificates nano net-tools gettext-base

# COPY ./sql-scripts/ /docker-entrypoint-initdb.d/