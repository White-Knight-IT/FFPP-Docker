#!/bin/bash

# **************************************************************************************************
# Configuration Options ******************* EDIT THESE OPTIONS TO YOUR REQUIREMENTS ****************
# **************************************************************************************************

# Forces the --build condition with docker compose which rebuilds the containers every time they are started
# not super useful for every day use
export CONF_ALWAYS_FORCE_CONTAINER_REBUILD=false

# **************************************************************************************************
# ********************************** DO NOT EDIT BELOW THIS LINE ***********************************
# **************************************************************************************************




















































































































if $CONF_ALWAYS_FORCE_CONTAINER_REBUILD
then
  # Run our docker containers - they will always build
  echo "Rebuild the containers"
  sudo docker-compose up -d --build
else
  # Run our docker containers - they only build if they are not already built
  sudo docker-compose up -d
fi
