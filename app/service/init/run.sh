#!/bin/bash

#set vars, run.sh
########################################################################

DATETIME=$(date +%m-%d-%Y_%H-%M-%S)

APP_DIR=/service
BASE_NAME=src
SSL_CERT=/service/conf/app.crt
SSL_KEY=/service/conf/app.key

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

export PYTHONUNBUFFERED=1
export PYTHONDONTWRITEBYTECODE=1
echo "[INFO] set PYTHONUNBUFFERED and PYTHONDONTWRITEBYTECODE to 1"

#start the web server with multiple http request threads
########################################################################

cd ${APP_DIR}/${BASE_NAME}
echo "[INFO] starting web server"

gunicorn \
--bind 0.0.0.0:${FLASK_PORT} \
--workers ${GUNICORN_HTTP_WORKER_THREADS} \
--certfile ${SSL_CERT} \
--keyfile ${SSL_KEY} \
${GUNICORN_ARGUMENTS} ${FLASK_APP}