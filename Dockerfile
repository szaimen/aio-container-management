# Docker CLI is a requirement
FROM docker:29.6.1-cli AS docker

# The actual base image
FROM jlesage/baseimage-gui:alpine-3.21-v4

COPY --chmod=775 startapp.sh /startapp.sh
COPY --chmod=775 /scripts/* /
COPY --chmod=775 rootfs/ /
COPY --from=docker /usr/local/bin/docker /usr/local/bin/docker

# Set the name of the application.
RUN set-cont-env APP_NAME "Nextcloud AIO Container Management" && \
    add-pkg bash sudo xterm grep

ENV USER_ID=0 \
    GROUP_ID=0 \
    WEB_AUDIO=1 \
    WEB_AUTHENTICATION=1 \
    SECURE_CONNECTION=1 \
    HOME=/root

# hadolint ignore=DL3002
USER 0

# Needed for Nextcloud AIO so that image cleanup can work. 
# Unfortunately, this needs to be set in the Dockerfile in order to work.
LABEL org.label-schema.vendor="Nextcloud"
