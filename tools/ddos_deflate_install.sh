#!/bin/sh
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'

cp ../conf/ddos.conf /usr/local/ddos/ddos.conf

cp ../conf/ignore.ip.list /usr/local/ddos/ignore.ip.list 
/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:" >>  /usr/local/ddos/ignore.ip.list;
chattr +i /usr/local/ddos/ignore.ip.list;

cp ../conf/ddos.sh /usr/local/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'

echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1

echo; echo 'DOS-Deflate Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'ignore ip is at /usr/local/ddos/ignore.ip.list '
echo 'if you want edit it please use chattr -i /usr/local/ddos/ignore.ip.list first'

echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'
echo
cat /usr/local/ddos/LICENSE | less
