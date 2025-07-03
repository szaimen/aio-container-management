#!/bin/bash

# Get Base
NC_DOMAIN="$(docker inspect nextcloud-aio-nextcloud | grep NC_DOMAIN | grep -oP '[a-z.-]+' | head -1)"
if [ -z "$NC_DOMAIN" ]; then
    echo "NC_DOMAIN is empty. Please report this to https://github.com/szaimen/aio-container-management/issues"
    exit 1
fi
BASE_DN="dc=${NC_DOMAIN//./,dc=}"

# Create a new empty ldap config
CONF_NAME=$(docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:create-empty-config -p)

if [ -z "$CONF_NAME" ]; then
    echo "CONF_NAME is empty. Most likely the ldap app is not enabled."
    exit 1
fi

# Check that the base DN matches your domain and retrieve your configuration name
echo "Base DN: $BASE_DN, Config name: $CONF_NAME"

# Set the ldap password
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapAgentPassword "<your-password>"

# Set the ldap config: Host and connection
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapAdminGroup       lldap_admin
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapAgentName        "cn=admin,ou=people,$BASE_DN"
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapBase             "$BASE_DN"
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapHost             "ldap://nextcloud-aio-lldap"
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapPort             3890
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapTLS              0
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" turnOnPasswordChange 0

# Set the ldap config: Users
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapBaseUsers             "ou=people,$BASE_DN"
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapEmailAttribute        mail
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapGidNumber             gidNumber
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapLoginFilter           "(&(|(objectclass=person))(|(uid=%uid)(|(mailPrimaryAddress=%uid)(mail=%uid))))"
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapLoginFilterEmail      1
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapLoginFilterUsername   1
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapUserAvatarRule        default
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapUserDisplayName       cn
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapUserFilter            "(|(objectclass=person))"
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapUserFilterMode        0
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapUserFilterObjectclass person

# Set the ldap config: Groups
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapBaseGroups                "ou=groups,$BASE_DN"
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapGroupDisplayName          cn
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapGroupFilter               "(&(|(objectclass=groupOfUniqueNames)))"
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapGroupFilterMode           0
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapGroupFilterObjectclass    groupOfUniqueNames
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapGroupMemberAssocAttr      uniqueMember
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" useMemberOfToDetectMembership 1

# Optional : Check the configuration
#docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:show-config "$CONF_NAME"

# Test the ldap config
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:test-config "$CONF_NAME"

# Enable ldap config
docker exec --user www-data nextcloud-aio-nextcloud php occ ldap:set-config "$CONF_NAME" ldapConfigurationActive 1
