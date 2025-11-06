# Docker CLI is a requirement
FROM docker:28.5.2-cli AS docker

# The actual base image
FROM jlesage/baseimage-gui:alpine-3.21-v4

COPY --chmod=775 startapp.sh /startapp.sh
COPY --chmod=775 /scripts/* /
COPY --from=docker /usr/local/bin/docker /usr/local/bin/docker

# Set the name of the application.
RUN set-cont-env APP_NAME "Nextcloud AIO Container Management"

# hadolint ignore=DL3002
USER root

# hadolint ignore=DL3018
RUN set -ex; \
    \
    apk upgrade --no-cache -a; \
    apk add --no-cache \
        bash sudo xterm grep;

ENV USER_ID=0 \
    GROUP_ID=0 \
    WEB_AUDIO=1 \
    WEB_AUTHENTICATION=1 \
    SECURE_CONNECTION=1 \
    HOME=/root

# Needed for Nextcloud AIO so that image cleanup can work. 
# Unfortunately, this needs to be set in the Dockerfile in order to work.
LABEL org.label-schema.vendor="Nextcloud"
