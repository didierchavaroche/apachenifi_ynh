#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

java_home=$install_dir/jvm
keystorepasswd=$(ynh_string_random --length=12)

run__install_keystore() {
    if [ -f "$install_dir/conf/keystore.jks" ]; then
        rm $install_dir/conf/keystore.jks
    fi

    keytool -genkeypair -alias nifi -keyalg RSA -keystore $install_dir/conf/keystore.jks -storepass $keystorepasswd -keypass $keystorepasswd -validity 365 -keysize 2048 -dname "CN=$domain,OU=users"
}