#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install Redis!"
    exit 1
fi

clear
printf "=======================================================================\n"
printf "Install Redis for LNMP-Lite V2.0.0  ,  Written by hdwo.net \n"
printf "=======================================================================\n"
printf "This script is a tool to install Redis for LNMP-Lite \n"
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
echo "Press any key to start install Redis..."
char=`get_char`

printf "=========================== install Redis ======================\n"

if [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-20151012/redis.so ]; then
	rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20151012/redis.so
fi

cur_php_version=`/usr/local/php/bin/php -v`

if echo "$cur_php_version" | grep -q "7.0."
then
sed -i 's#extension_dir = "./"#extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20151012/"\nextension = "redis.so"\n#' /usr/local/php/etc/php.ini
else
	echo "Error: can't get php version!"
	echo "Maybe your php was didn't install or php configuration file has errors.Please check."
	sleep 3
	exit 1
fi


echo "============================Install Redis ${REDIS_VER} ================================="
groupadd redis
useradd -M -s /sbin/nologin -g redis redis
cd $cur_dir
ldconfig


echo "Install php_redis extension..."
wget -c http://pecl.php.net/get/redis-3.1.4.tgz
tar -zxvf redis-3.1.4.tgz
cd redis-3.1.4/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../



echo "Install Redis..."
wget -c http://download.redis.io/releases/redis-3.2.11.tar.gz
tar xzf redis-3.2.11.tar.gz
cd redis-3.2.11/
make
mkdir /usr/local/redis
cp src/redis-server  /usr/local/redis/
cp src/redis-cli  /usr/local/redis/
cp src/redis-sentinel  /usr/local/redis/
cp src/redis-benchmark  /usr/local/redis/
cp src/redis-check-aof  /usr/local/redis/
cp src/redis-check-rdb  /usr/local/redis/
cp redis.conf /usr/local/redis/
cp sentinel.conf /usr/local/redis/
#cp utils/redis_init_script   /etc/init.d/redis
cd $cur_dir
cp redis.init  /etc/init.d/redis
chmod a+x /etc/init.d/redis
chkconfig --add redis
chkconfig --level 345 redis on
cd ../

ln   /usr/local/redis/redis-cli /usr/bin/redis-cli


if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
	echo "Restart Apache......"
	/etc/init.d/httpd -k restart
else
	echo "Restart php-fpm......"
	/etc/init.d/php-fpm restart
fi

echo "Starting redis..."
/etc/init.d/redis start

printf "===================== install Redis completed =====================\n"
printf "Install Redis completed,enjoy it!\n"
printf "=======================================================================\n"