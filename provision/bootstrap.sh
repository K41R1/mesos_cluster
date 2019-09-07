#!/bin/bash
set -e

echo -ne "=> Install tools"
yum update -y
yum install -y git wget vim curl tar net-tools java-1.8.0-openjdk

echo -ne "=> Create new user [mesos:mesos]"
useradd -m mesos -G wheel || true
echo -e "mesos\nmesos" | passwd mesos || true

echo -ne "=> Add Mesosphere repository"
rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm

echo -ne "=> Install Mesos"
yum update -y
yum install -y mesos || true

echo -ne "=> Disabling firewall"
systemctl disable firewalld --now