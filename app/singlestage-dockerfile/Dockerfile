#set the source image
#########################
FROM python:3.8-slim
LABEL maintainer="chihuahua"

#set vars, build time
#########################
ARG APP_UID=1000
ARG APP_GID=1000
ARG APP_USER=app
ARG APP_GROUP=app
ARG APP_ROOT=/service
ARG APP_SRC=src
ARG CODE_1=service
ARG CODE_2=src

#run as root for setup
#########################
USER root

#copy code
#########################
RUN mkdir -p "$APP_ROOT"/"$APP_SRC"
COPY "$CODE_1"/ "$APP_ROOT"/
COPY "$CODE_2"/ "$APP_ROOT"/"$APP_SRC"

#python packages
#########################
RUN apt-get update && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r "$APP_ROOT"/"$APP_SRC"/requirements.txt

#OS packages
#########################
#RUN set -ex \
#    && RUN_DEPS=" \
#        package1 \
#        package2 \
#    " \
#    && seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{} \
#    && apt-get update && apt-get install -y --no-install-recommends $RUN_DEPS

#add app user/group
#########################
RUN groupadd -g "$APP_GID" "$APP_GROUP" && \
    useradd -u "$APP_UID" -g "$APP_GROUP" "$APP_USER" && \
    mkdir /home/"$APP_USER" && \
    chown -R "$APP_USER":"$APP_GROUP" /home/"$APP_USER"

#modify permissions
#########################
RUN chown -R "$APP_USER":"$APP_GROUP" "$APP_ROOT" && \
    chmod +x "$APP_ROOT"/init/run.sh

#set image defaults
#########################
EXPOSE 8000
USER "$APP_USER"
WORKDIR "$APP_ROOT"/init
CMD ["/bin/bash", "-l", "/service/init/run.sh"]

#set docker healthcheck
#########################
HEALTHCHECK NONE