#!/bin/bash

#=================================================
# INSTALL KEYSTORE AND TRUST STORE
# Form wlkthrougt : https://nifi.apache.org/docs/nifi-docs/html/walkthroughs.html#securing-nifi-with-provided-certificates
#=================================================
__install_keystore() {
    if [ -f "$1/conf/keystore.jks" ]; then
        rm $1/conf/keystore.jks
    fi

    if [ -f "$1/conf/truststore.jks" ]; then
        rm $1/conf/truststore.jks
    fi

    # Extraire le certificat racine (le dernier certificat dans la chaîne)
    awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' /etc/yunohost/certs/$domain/crt.pem | awk 'NR>1,/-----END CERTIFICATE-----/' | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > $install_dir/nifi-cacert.pem

    # Form the PKCS12 keystore from the certificate chain and private key.
    openssl pkcs12 -export -out $install_dir/nifi.p12 -inkey /etc/yunohost/certs/$domain/key.pem -in /etc/yunohost/certs/$domain/crt.pem -name nifi-key -passout pass:$keystorepasswd

    # Convert the PKCS12 keystore for the NiFi instance into the Java KeyStore file (keystore.jks).
    keytool -storepasswd -new $keystorepasswd -importkeystore -srckeystore $install/nifi.p12 -srcstoretype pkcs12 -srcalias nifi-key -destkeystore $install_dir/conf/keystore.jks -deststoretype jks -destalias nifi-key

    # Convert the CA certificate into the NiFi truststore (truststore.jks) to allow trusted incoming connections.
    keytool -storepasswd -new $keystorepasswd -importcert -alias nifi-cert -file $install_dir/nifi-cacert.pem -keystore $install_dir/conf/truststore.jks

    # remove temporary certificate
    ynh_safe_rm $install_dir/nifi-cacert.pem

    #add reading permissions to user
    chmod o+r $install_dir/conf/keystore.jks
    chmod o+r $install_dir/conf/truststore.jks
}

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

java_home=$install_dir/jvm
keystorepasswd=$(ynh_string_random --length=12)
