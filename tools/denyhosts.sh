#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

yum install python rsyslog -y
service rsyslog restart


echo "Downloading..."

mkdir src
cd src/
wget -c http://soft.vpser.net/security/denyhosts/DenyHosts-2.6.tar.gz
tar -xzf DenyHosts-2.6.tar.gz
cd DenyHosts-2.6/
echo "Installing..."
python setup.py install

echo "Copy files..."
cd /usr/share/denyhosts/
cp denyhosts.cfg-dist denyhosts.cfg
cp daemon-control-dist daemon-control

chown root daemon-control
chmod 700 daemon-control

echo "Start DenyHosts..."
./daemon-control start


cd /etc/init.d
ln -s /usr/share/denyhosts/daemon-control denyhosts
chkconfig --add denyhosts
chkconfig --level 2345 denyhosts on

#sed -i '/STATE_LOCK_EXISTS\ \=\ \-2/aif not os.path.exists("/var/lock/subsys"): os.makedirs("/var/lock/subsys")' /etc/init.d/denyhosts

echo 'DenyHosts begin works!'
exit 1