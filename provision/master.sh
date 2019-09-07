#!/bin/bash
set -e

VAGRANT_HOME="/home/vagrant"
EXECUTE_AS_VAGRANT="sudo -H -U vagrant -s"

$EXECUTE_AS_VAGRANT "mkdir ~/frameworks ~/bin ~/jars"
$EXECUTE_AS_VAGRANT "tar xzvf /tmp/hadoop.tar.gz -C ~/frameworks"


function hadoop() {
    if [[ -f /tmp/hadoop.sh ]]; then 
        cp -vf /tmp/hadoop.sh /etc/profile.d/hadoop.sh
    fi

    if [[ -f /tmp/hadoop.tar.gz ]]; then
        mv /tmp/hadoop.tar.gz $VAGRANT_HOME/frameworks/
    fi
}