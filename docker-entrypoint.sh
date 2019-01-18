#!/bin/bash


KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD:-"almighty"}
KEYCLOAK_SERVER_DOMAIN=${KEYCLOAK_SERVER_DOMAIN:-"localhost"}
INTERNAL_POD_IP=${INTERNAL_POD_IP:-"127.0.0.1"}
KEYSTORE_ALIAS=${KEYSTORE_ALIAS}

#openssl pkcs12 -export -in /tmp/cert/c4e5b0dd1a0dd7c7.crt -inkey /tmp/cert/wildcard.gamerefinery.key -certfile /tmp/cert/c4e5b0dd1a0dd7c7.crt -out keycloak.p12 -passin file:/tmp/cert/inpass -passout pass:foobar
#keytool -importkeystore -srckeystore keycloak.p12 -srcstoretype pkcs12 -destkeystore keycloak.jks -deststoretype JKS -srcstorepass $KEYSTORE_PASSWORD -deststorepass $KEYSTORE_PASSWORD -deststoretype pkcs12
#keytool -import -keystore keycloak.jks -file /tmp/cert/gd_bundle-g2-g1.crt -alias root -storepass $KEYSTORE_PASSWORD -trustcacerts -noprompt
#keytool -import -keystore keycloak.jks -file /tmp/rdscert/rds-combined-ca-bundle.der -alias rds -storepass $KEYSTORE_PASSWORD -trustcacerts -noprompt

#mv keycloak.jks ./standalone/configuration

# Set the password of the keystore to the configuration file
sed -i -e "s/%%KEYSTORE_PASSWORD%%/${KEYSTORE_PASSWORD}/" ./standalone/configuration/standalone-ha.xml

if [ $KEYCLOAK_USER ] && [ $KEYCLOAK_PASSWORD ]; then
    echo "Adding a new user..."
    /opt/jboss/keycloak/bin/add-user-keycloak.sh --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD
fi


echo "Starting keycloak-server on clustered mode..."
exec /opt/jboss/keycloak/bin/standalone.sh --server-config=standalone-ha.xml -bmanagement=$INTERNAL_POD_IP -bprivate=$INTERNAL_POD_IP ${1+"$@"}
exit $?
