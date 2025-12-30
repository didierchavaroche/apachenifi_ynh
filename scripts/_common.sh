#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

#=================================================
#
#=================================================

_install_nifi_env() {
    echo "JAVA_HOME="$(find / -name jdk-21*) > $install_dir/.env
    echo "NIFI_HOME="$install_dir >> $install_dir/.env

    chown $app:$app $install_dir/.env
}