#!/bin/bash
set -e
IFNAME=$1
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

# remove ubuntu-bionic entry
sed -e '/^.*ubuntu-bionic.*/d' -i /etc/hosts

# Update /etc/hosts about other hosts
cat >> /etc/hosts <<EOF
192.168.5.11  master-1
192.168.5.12  master-2
192.168.5.13  master-3
192.168.5.14  master-4
192.168.5.15  master-5
192.168.5.16  master-6
192.168.5.17  master-7
192.168.5.18  master-8
192.168.5.19  master-9
192.168.5.21  worker-1
192.168.5.22  worker-2
192.168.5.23  worker-3
192.168.5.24  worker-4
192.168.5.25  worker-5
192.168.5.26  worker-6
192.168.5.27  worker-7
192.168.5.28  worker-8
192.168.5.29  worker-9
EOF


#Manual Changes
echo -e "root\nroot" | sudo passwd root

echo -e "vagrant\nvagrant" | sudo passwd vagrant

sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

sudo systemctl restart sshd

ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''

cat >> /root/.ssh/config << EOF
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF

#chown vagrant:vagrant /home/vagrant/.ssh/config
#chown vagrant:vagrant /home/vagrant/.ssh/id_rsa
#chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
#chown vagrant:vagrant /home/vagrant/.ssh/id_rsa.pub

#chmod 664 /home/vagrant/.ssh/config
#chmod 600 /home/vagrant/.ssh/id_rsa
#chmod 600 /home/vagrant/.ssh/authorized_keys
#chmod 644 /home/vagrant/.ssh/id_rsa.pub
