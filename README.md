# Background

This project is an assignment from a pre-employment test for the company Ad Hoc titled "Containerize".

# Containerize - Comments

## Overview

The objective of this repository is to provide a development deployment with Docker for a simple system comprised of a Flask app and a Nginx frontend.




## Service - Nginx

### General Notes

Nginx accepts requests on ports 80 and 443. All HTTP requests redirect to HTTPS.

Any changes to `nginx` files require a Docker image rebuild, except the SSL keypair which requires a `nginx` container restart. A simple build script is included `./nginx/build.sh`, it removes the previous built image before building the new one.

The external SSL keypair is available to the `nginx` container via the following mapped volumes:
```
volumes:
  - "./nginx/external/security/localhost.crt:/etc/nginx/ssl/app.crt"
  - "./nginx/external/security/localhost.key:/etc/nginx/ssl/app.key"
```

The environment variable section for the `nginx` service does not need to be edited from the default. Setting the `LOG_RETENTION` variable to `true` keeps previous log files across restarts by creating a new folder named with the current date and time.
```
x-nginx-environment: &nginx-environment
  LOG_RETENTION: "true"
```

Externalized Logs for `nginx` can be found at this location: `./nginx/external/logs`.

### Settings for nginx.conf

The SSL configuration within `./nginx/service/conf/nginx.conf` uses modern and secure protocols and ciphers. 
```
ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
```

Nginx proxies requests to the Flask app using an `upstream` directive with the following `./nginx/service/conf/nginx.conf` configuration. Any update to the `app` service name or port requires a change here and an image rebuild.
```
upstream app {
    server                      app:8000 fail_timeout=0;
}
```

The important headers `X-Forwarded-For`, `X-Real-IP`, and `X-Forwarded-Proto` are sent to the upstream application with the following `./nginx/service/conf/nginx.conf` configuration:
```
location / {
    proxy_pass              https://$upstream_app;
    proxy_set_header        X-Real-IP           $remote_addr;
    proxy_set_header        X-Forwarded-For     $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto   $scheme;
    proxy_set_header        Host                $host;
}
```

`nginx.conf` contains a custom error page for all HTTP error response codes. Alter this file for customization, `./nginx/service/conf/pages/error.html`, then rebuild the image. The default page is a Status Page template from here `https://better-error-pages.statuspage.io/`.

`nginx.conf` does NOT contain configuration for serving files.
```
location /static/ {
    alias /static/;
}
location /media/ {
    alias /media/;
}
``` 



## Service - App

### General Notes

The Flask app is using a Gunicorn Server. All Flask environment variables can be set under `x-app-environment: &app-environment`. The `app` is running in development mode and listening on port `8000` within the internal Docker network.

The `app` service can run without `nginx` by mapping port `8000` from the `app` service to the Docker host. In this case it's only accesible using the `https` protocol.
In the packaged compose configuration, the `app` service is not reachable directly from the host. 
It can only be accessed through the `nginx` service because of the following configuration in `docker-compose.yml`: 
```
networks:
  frontend:
...
...

app:
    ...
    ...
    networks:
      - frontend

nginx:
    ...
    ...
    networks:
      - frontend
```

Due to the following mapped volume, `- "./app/src:/service/src"`, and these environment variables `GUNICORN_ARGUMENTS: "--reload" , FLASK_ENV: "development" , TESTING: "True" DEBUG: 1` local edits of the `app` source are reflected in the `app` container without restart. Changes to `requirements.txt` need an `app` image rebuild since they constitute an environment change and not a code change. To rebuild you can use the simple build script, `./app/build.sh`, like `nginx` it removes the previous image build.

Inside a Docker container instance, the `src` dir can be found here: `/service/src`



## Deploying the System to a Development Environment

### Pre-Deployment Considerations

`nginx` base image: `nginx:1.19.2`
`app` base image: `python:3.8-slim`

For the absolute minimum image size a base image like `alpine` was not used for both images, but minimum image layer creation was considered. 

The `app` image uses a mult-stage build process in its Dockerfile to save more space. The `nginx` image does not require a multi-stage build. Included is an example single stage Dockerfile for the `app` image to compare the size difference located at `./app/singlestage-dockerfile`. The `app` base image is 194MB, the multi-stage `app` image is 211MB, and the single-stage `app` image is 228MB.

Both containers do not run as root. This is set within the Dockerfile but to be explicit it is set in the `docker-compose.yml` file.

Both images do not specify environment variables, only build time arguments, every necessary environment variable must be set in `docker-compose.yml`, except `export PYTHONUNBUFFERED=1` and `export PYTHONDONTWRITEBYTECODE=1` which is set in the startup script for `app` at `./app/service/init/run.sh`.

The startup scripts for both the `app` and `nginx` services, `./app/service/init/run.sh` and `./nginx/service/init/run.sh`, include logic for Docker secrets if they are used instead of environment variables.

### Optional Pre-build Step
To ensure service file permissions in the Docker containers match the Docker host, set the `uid` and `gid` of the internal user for the Docker containers here `./app/Dockerfile` and here `./nginx/Dockerfile`, then rebuild each image. The default `uid` and `gid` values are set to `1000`. 

### Deploy Time

To run the system issue the following command: `docker-compose up --build -d`

To verify a successful deployment, issue the following command: `curl -k https://localhost/`
Output similar to the following will be displayed.
```Text
It's easier to ask forgiveness than it is to get permission.
X-Forwarded-For: 172.20.0.1
X-Real-IP: 172.20.0.1
X-Forwarded-Proto: https
```