#########################
#global build time variables
#########################

ARG APP_UID=1000
ARG APP_GID=1000
ARG APP_USER=app
ARG APP_GROUP=app
ARG APP_ROOT=/service
ARG APP_SRC=src
ARG CODE_1=service
ARG CODE_2=src




#########################
#builder phase
#########################

#set the source image
#########################
FROM python:3.8-slim AS builder

#set used global variables
#########################
ARG APP_ROOT
ARG APP_SRC
ARG CODE_2

#run as root for setup
#########################
USER root

#create file structure, copy requirements.txt only
#########################
RUN mkdir -p "$APP_ROOT"/"$APP_SRC" && \
    mkdir "$APP_ROOT"/wheel-builder
COPY "$CODE_2"/requirements.txt "$APP_ROOT"/"$APP_SRC"/

#python packages - build wheel
#########################
RUN pip install --upgrade pip && \
    pip wheel --no-cache-dir --no-deps --wheel-dir "$APP_ROOT"/wheel-builder -r "$APP_ROOT"/"$APP_SRC"/requirements.txt




#########################
#final phase
#########################

#set the source image
#########################
FROM python:3.8-slim
LABEL maintainer="chihuahua"

#set used global variables
#########################
ARG APP_UID
ARG APP_GID
ARG APP_USER
ARG APP_GROUP
ARG APP_ROOT
ARG APP_SRC
ARG CODE_1
ARG CODE_2

#create file structure, copy all code
#########################
RUN mkdir -p "$APP_ROOT"/"$APP_SRC" && \
	mkdir "$APP_ROOT"/wheel
COPY "$CODE_1"/ "$APP_ROOT"/
COPY "$CODE_2"/ "$APP_ROOT"/"$APP_SRC"/
COPY --from=builder "$APP_ROOT"/wheel-builder/ "$APP_ROOT"/wheel/

#python packages - use the pre-built wheel
#########################
RUN pip install --upgrade pip && \
	pip install --no-cache "$APP_ROOT"/wheel/* && \
	rm -rf "$APP_ROOT"/wheel

#OS packages - example
#########################
#RUN apt-get update && \
#	rm -rf /var/lib/apt/lists/* \ 
#	set -ex \
#   && RUN_DEPS=" \
#       package1 \
#       package2 \
#   " \
#   && seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{} \
#   && apt-get install -y --no-install-recommends $RUN_DEPS

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