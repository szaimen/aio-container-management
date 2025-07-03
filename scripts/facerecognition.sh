#!/bin/bash

NC_USERS_NEW=$(docker exec --user www-data nextcloud-aio-nextcloud php occ user:list | sed 's|^  - ||g' | sed 's|:.*||')
mapfile -t NC_USERS_NEW <<< "$NC_USERS_NEW"
for user in "${NC_USERS_NEW[@]}"
do
    docker exec --user www-data nextcloud-aio-nextcloud php occ user:setting "$user" facerecognition full_image_scan_done false
    docker exec --user www-data nextcloud-aio-nextcloud php occ user:setting "$user" facerecognition enabled true
done
