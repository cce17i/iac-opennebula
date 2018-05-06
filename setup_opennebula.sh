#!/bin/bash

VERSION=5.4
CENTOS_VERSION=7
VMBR0_IP="IP"


### ADD OpenNebula Repositories ###
cat << EOT > /etc/yum.repos.d/opennebula.repo
[opennebula]
name=opennebula
baseurl=https://downloads.opennebula.org/repo/$VERSION/CentOS/$CENTOS_VERSION/x86_64/
enabled=1
gpgkey=https://downloads.opennebula.org/repo/repo.key
gpgcheck=1
EOT

### SETUP OpenNebula Frontend ###
yum -y upgrade
yum -y install opennebula-server opennebula-sunstone

for package in opennebula opennebula-sunstone
do
  systemctl enable ${package}
  systemctl start ${package}
done

### SETUP OpenSSH for OpenNebula Node ###
su - oneadmin
cat << EOT > ~/.ssh/config
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOT

chmod 600 ~/.ssh/config
logout

# Node Installation
yum -y install opennebula-node-kvm

### Configure VM Bridge
cat <<EOF >/etc/sysconfig/network-scripts/ifcfg-vmbr0
DEVICE=vmbr0
TYPE=Bridge
IPADDR=${VMBR0_IP}
NETMASK=255.255.255.0
ONBOOT=yes
BOOTPROTO=static
NM_CONTROLLED=no

EOF

# Bring Up vmbr0
ifup vmbr0