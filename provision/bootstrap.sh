#!/bin/bash
set -e

echo -ne "=> Install tools"
yum update -y --quiet
yum install -y --quiet git wget vim curl tar net-tools java-1.8.0-openjdk

echo -ne "=> Update root password [root:root]"
echo -e "root\nroot" | passwd root || true

echo -ne "=> Create mesos user [mesos:mesos]"
useradd mesos -G wheel -m || true
echo -e "mesos\nmesos" | passwd mesos || true

echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo -ne "=> Add Mesosphere repository"
rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm || true

echo -ne "=> Install Mesos"
yum update -y --quiet
yum install -y --quiet mesos || true

echo -ne "=> Disabling firewall"
systemctl disable firewalld --now

echo -ne "=> Create SymLink for java"
ln -sf /usr/lib/jvm/jre-1.8.0/ /usr/lib/jvm/default

echo -ne "=> Export JAVA_HOME"
echo "export JAVA_HOME=/usr/lib/jvm/default" | sudo tee /etc/profile.d/java.sh

echo -ne "=> Add NODES FQND"
if [[ -f /tmp/hosts ]]; then
    cat /tmp/hosts >> /etc/hosts
fi

echo -ne "=> Allow connection between nodes"
if [[ -f /tmp/sshd_config ]]; then
    cp -f /tmp/sshd_config /etc/ssh/sshd_config
fi

echo -ne "=> Restart SSH server"
sudo systemctl restart sshd