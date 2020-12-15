#set the source image
###################################################
FROM nginx:1.19.2
LABEL maintainer="chihuahua"

#set build time variables
###################################################
ARG APP_UID=1000
ARG APP_GID=1000
ARG APP_USER=nginx
ARG APP_GROUP=nginx
ARG APP_ROOT=/service
ARG CODE=service

#run as root for setup
###################################################
USER root

#copy code
###################################################
RUN mkdir "$APP_ROOT"
COPY "$CODE"/ "$APP_ROOT"/

#modify user/group of existing user
###################################################
RUN usermod -u "$APP_UID" "$APP_USER" && \
    groupmod -g "$APP_GID" "$APP_GROUP"

#remove default nginx config
#add other directories and files
###################################################
RUN rm /etc/nginx/conf.d/default.conf && \
    mkdir /etc/nginx/logs && \
    mkdir /etc/nginx/ssl && \
    mkdir /etc/nginx/pages && \
    touch /var/run/nginx.pid && \
    mv "$APP_ROOT"/conf/nginx.conf /etc/nginx/nginx.conf && \
    mv "$APP_ROOT"/conf/pages/ /etc/nginx

#modify permissions for user
###################################################
RUN chown -R "$APP_USER":"$APP_GROUP" "$APP_ROOT" && \
    chown -R "$APP_USER":"$APP_GROUP" /etc/nginx/* && \
    chown -R "$APP_USER":"$APP_GROUP" /var/cache/nginx && \
    chown -R "$APP_USER":"$APP_GROUP" /var/log/nginx && \
    chown -R "$APP_USER":"$APP_GROUP" /var/run/nginx.pid && \
    chmod +x "$APP_ROOT"/init/run.sh

#set image defaults
###################################################
USER "$APP_USER"
WORKDIR "$APP_ROOT"/init
CMD ["/bin/bash", "/service/init/run.sh"]

#set docker healthcheck
###################################################
HEALTHCHECK NONE