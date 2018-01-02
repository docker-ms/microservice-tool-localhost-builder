#!/bin/bash

#
## This script is only used for localhost building.
#

run_mode=''
service_tag=''

export RUN_NPM_INSTALL="$RUN_NPM_INSTALL"

#
## Reset in case getopts has been used previously in the shell.
#
OPTIND=1

while getopts "npw:" opt; do
  case "$opt" in
    n )
      export RUN_NPM_INSTALL=$(uuidgen)
      ;;
    p )
      run_mode='PROD'
      ;;
    w )
      service_tag="${pb_service_name}-localhost-$OPTARG"
      service_tag_suffix="localhost-$OPTARG"
      ;;
  esac
done

if [[ -n "$service_tag" ]]; then
  # Remove the old container if there is
  docker ps -a -q --filter=ancestor="$service_tag" | xargs -I {} docker rm -f {}

  #
  ## Build image.
  #
  docker build \
    --build-arg PORTS_END=53547 \
    --build-arg "RUN_NPM_INSTALL=$RUN_NPM_INSTALL" \
    --tag "$service_tag" \
    .

  #
  ## Run the container.
  #
  ## Since this is only for localhost testing purpose, so expose one port only, no matter how many cores your cpu has.
  #
  docker run -d -P \
    --env "RUN_MODE=$run_mode" \
    --env "SERVICE_NAME=$service_tag" \
    --env "MS_SERVICE_TAG=$service_tag" \
    --env "SERVICE_TAG_SUFFIX=$service_tag_suffix" \
    "$service_tag"

else
  echo "Error: please specify the env owner with '-w' option."
fi


