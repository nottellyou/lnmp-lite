#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

read -p "Input your email using receive baned IP:" receiveemail
if [ "${receiveemail}" = "" ]; then
	$receiveemail = "root@localhost.localdomain"
fi

# 0.9.x require python 2.7
FAIL_2_BAN_VER=0.8.14

yum install python iptables tcp-wrapper shorewall Gamin gamin-python sendmail logwatch rsyslog -y

echo "Downloading..."
cd ../src
wget -c http://soft.vpser.net/security/fail2ban/fail2ban-$FAIL_2_BAN_VER.tar.gz
tar zxf fail2ban-$FAIL_2_BAN_VER.tar.gz && cd fail2ban-$FAIL_2_BAN_VER/
echo "Installing..."
python setup.py install


sed -i 's/# \[sshd\]/\[sshd\]/g' /etc/fail2ban/jail.conf
sed -i 's/# enabled = true/enabled = true/g' /etc/fail2ban/jail.conf
sed -i 's#%(sshd_log)s#/var/log/secure#g' /etc/fail2ban/jail.conf


if [ -s /usr/local/pureftpd/etc/pure-ftpd.conf.tttttttttt ]; then
cat >>/etc/fail2ban/jail.conf<<eof
######以下三段需要手工来改
[ssh-iptables]
enabled = true
filter  = sshd
action  = iptables[name=SSH, port=ssh, protocol=tcp]
          sendmail-whois[name=SSH, dest=${receiveemail}]
logpath = /var/log/secure
maxretry = 3
findtime = 300
bantime = 864000

[pure-ftpd]
enabled = true
port = ftp,ftp-data,ftps,ftps-data
filter = pure-ftpd
action = iptables[name=PUREFTP, port=ftp, protocol=tcp]
         sendmail-whois[name=PUREFTP, dest=${receiveemail}]
logpath = /var/log/messages
maxretry= 3
eof
fi

#protect wordpress : http://drops.wooyun.org/tips/3029
if [ -s /home/wwwroot/wordpress37/wp-config.php ]; then
cat >>/etc/fail2ban/jail.conf<<eof
[wordpress]
enabled = true
port = http,https
filter = nginx
logpath = /var/log/nginx/access_log
findtime =60
bantime =86400
maxretry =50
action = iptables[name=nginx, port=http, protocal=tcp]
         sendmail[name=nginx, dest=${receiveemail}]
eof

cat >/etc/fail2ban/filter.d/nginx.conf<<eof
[Definition]
failregex =<HOST>.*-.*-.*POST.*/wp-login.php.* HTTP\/1.*.*$
ignoreregex =
eof
fi


#############
#sed -i 's/logtarget = SYSLOG/logtarget = /var/log/fail2ban.log/g' /etc/fail2ban/fail2ban.conf

echo "Copy init files..."
mkdir /var/run/fail2ban
cp ../../init.d/init.d.fail2ban /etc/init.d/fail2ban


chmod +x /etc/init.d/fail2ban

chkconfig --add fail2ban
chkconfig fail2ban on

echo "Start fail2ban..."
/etc/init.d/fail2ban start