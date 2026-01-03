#!/bin/bash

#=================================================
# INSTALL KEYSTORE
#=================================================
__install_keystore() {
    if [ -f "$install_dir/conf/keystore.jks" ]; then
        rm $install_dir/conf/keystore.jks
    fi

   # Convertit le certificat Let's Encrypt en format PKCS12
    openssl pkcs12 -export -in /etc/yunohost/certs/$domain/crt.pem -inkey /etc/yunohost/certs/$domain/key.pem -out $install_dir/conf/nifi-keystore.p12 -name nifi -passout pass:$keystorepasswd

    # Convertit le fichier PKCS12 en keystore JKS
    keytool -importkeystore -srckeystore $install_dir/conf/nifi-keystore.p12 -srcstoretype PKCS12 -destkeystore $install_dir/conf/keystore.jks -deststoretype JKS -srcstorepass $keystorepasswd -deststorepass $keystorepasswd
}

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

java_home=$install_dir/jvm
keystorepasswd=$(ynh_string_random --length=12)
