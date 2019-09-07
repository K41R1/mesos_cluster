#!/bin/bash
set -e

echo -ne "=> Install tools"
yum update -y
yum install -y git wget vim curl tar net-tools java-1.8.0-openjdk

echo -ne "=> Update root password [root:root]"
echo -e "root\nroot" | passwd root || true

echo -ne "=> Add Mesosphere repository"
rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm || true

echo -ne "=> Install Mesos"
yum update -y
yum install -y mesos || true

echo -ne "=> Disabling firewall"
systemctl disable firewalld --now

echo -ne "=> Create SymLink for java"
ln -sf /usr/lib/jvm/jre-1.8.0 /usr/lib/jvm/default

echo -ne "=> Add NODES FQND"
if [[ -f /tmp/hosts ]]; then
    cat /tmp/hosts >> /etc/hosts
fi