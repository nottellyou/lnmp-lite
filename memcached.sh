#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install memcached!"
    exit 1
fi

clear
printf "=======================================================================\n"
printf "Install Memcached for LNMP-Lite V2.0.0  ,  Written by hdwo.net \n"
printf "=======================================================================\n"
printf "This script is a tool to install memcached for LNMP-Lite \n"
printf "\n"
printf "For more information please visit http://hdwo.net \n"
printf "=======================================================================\n"
cur_dir=$(pwd)

get_char()
{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
}
echo ""
echo "Press any key to start install Memcached..."
char=`get_char`

printf "=========================== install memcached ======================\n"

if [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-20151012/memcache.so ]; then
	rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20151012/memcache.so
fi

cur_php_version=`/usr/local/php/bin/php -v`

if echo "$cur_php_version" | grep -q "7.0."
then
sed -i 's#extension_dir = "./"#extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20151012/"\nextension = "memcache.so"\n#' /usr/local/php/etc/php.ini
else
	echo "Error: can't get php version!"
	echo "Maybe your php was didn't install or php configuration file has errors.Please check."
	sleep 3
	exit 1
fi

echo "Install memcache php extension..."
wget -c http://mirrors.linuxeye.com/oneinstack/src/pecl-memcache-php7.tgz
#git clone https://github.com/websupport-sk/pecl-memcache.git
tar zxvf pecl-memcache-php7.tgz
cd pecl-memcache-php7/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

wget -c http://soft.vpser.net/lib/libevent/libevent-2.0.21-stable.tar.gz
tar zxvf libevent-2.0.21-stable.tar.gz
cd libevent-2.0.21-stable/
./configure --prefix=/usr/local/libevent
make&& make install
cd ../

echo "/usr/local/libevent/lib/" >> /etc/ld.so.conf
ln -s /usr/local/libevent/lib/libevent-2.0.so.5  /lib/libevent-2.0.so.5
ldconfig

cd $cur_dir
echo "Install memcached..."
wget -c http://memcached.org/files/memcached-1.4.25.tar.gz
tar xzf memcached-1.4.25.tar.gz
cd memcached-1.4.25/
./configure --prefix=/usr/local/memcached
make && make install
cd ../

ln   /usr/local/memcached/bin/memcached /usr/bin/memcached

cd $cur_dir
cp conf/memcached-init /etc/init.d/memcached
chmod +x /etc/init.d/memcached
useradd -s /sbin/nologin nobody

if [ ! -d /var/lock/subsys ]; then
  mkdir -p /var/lock/subsys
fi

if [ -s /etc/debian_version ]; then
update-rc.d -f memcached defaults
elif [ -s /etc/redhat-release ]; then
chkconfig --level 345 memcached on
fi

#echo "Copy Memcached PHP Test file..."
#cp conf/memcached.php /home/wwwroot/default/memcached.php

if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
	echo "Restart Apache......"
	/etc/init.d/httpd -k restart
else
	echo "Restart php-fpm......"
	/etc/init.d/php-fpm restart
fi

echo "Starting Memcached..."
/etc/init.d/memcached start

printf "===================== install Memcached completed =====================\n"
printf "Install Memcached completed,enjoy it!\n"
printf "=======================================================================\n"