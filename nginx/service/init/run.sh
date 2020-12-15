#!/bin/bash

#set vars, run.sh
########################################################################

DATETIME=$(date +%m-%d-%Y_%H-%M-%S)
LOGS_DIR=/etc/nginx/logs
CONF_FILE=/etc/nginx/nginx.conf

#wait for docker's DNS to be stable
########################################################################

echo "[INFO] waiting five seconds for docker dns to stabilize"
sleep 5

#set variables
########################################################################

if [ -d "/run/secrets" ]; then
	echo "[INFO] parsing docker secrets"
    for f in $(ls /run/secrets)
	do
	  export "$f"=$(cat /run/secrets/$f)
	done
else 
    echo "[INFO] /run/secrets does not exist, if env vars are not set in docker-compose the container will fail"
fi

#clear previous logs or keep them
########################################################################

if [[ "$LOG_RETENTION" == "false" ]]
then
   rm -rf $LOGS_DIR/*
   echo "[INFO] cleared previous log files"
fi

if [[ "$LOG_RETENTION" == "true" ]]
then
   mkdir $LOGS_DIR/$DATETIME
   cp $LOGS_DIR/*.log $LOGS_DIR/$DATETIME
   echo "[INFO] saved previous log files"
fi

#start nginx
########################################################################
nginx -c $CONF_FILE -g 'daemon off;'