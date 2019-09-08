#!/bin/bash
set -e

yum update -y --quiet
yum install -y mesosphere-zookeeper

VAGRANT_HOME="/home/vagrant"
EXECUTE_AS_VAGRANT="sudo -H -u vagrant bash -c "

$EXECUTE_AS_VAGRANT "mkdir ~/frameworks ~/bin ~/jars"

function hadoop() {
    if [[ -f /tmp/hadoop.sh ]]; then 
        cp -f /tmp/hadoop.sh /etc/profile.d/hadoop.sh
    fi

    if [[ -f /tmp/hadoop.tar.gz ]]; then
        $EXECUTE_AS_VAGRANT "mv /tmp/hadoop.tar.gz $VAGRANT_HOME/frameworks"
    fi
}

function marathon() {
    if [[ -f /tmp/marathon.tar.gz ]]; then
        $EXECUTE_AS_VAGRANT "tar xzf /tmp/marathon.tar.gz -C $VAGRANT_HOME/frameworks"
    fi

    if [[ -f /tmp/marathon.service ]]; then
        cp /tmp/marathon.service /etc/systemd/system/marathon.service
        chmod 644 /etc/systemd/system/marathon.service
        $EXECUTE_AS_VAGRANT "ln -s $VAGRANT_HOME/frameworks/marathon/bin/* $VAGRANT_HOME/bin/ "
    fi

}

hadoop
marathon

systemctl start zookeeper
systemctl enable zookeeper

systemctl start marathon
systemctl enable marathon