#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install LNMP-Lite"
    exit 1
fi

clear

LNMP_LITE_VER=2.0.0
ADMINER_VER=4.2.5
PHP_VER=7.0.7
MYSQL_VER=5.5.28
TENGINE_VER=2.1.1
JEMALLOC_VER=3.6.0

echo "========================================================================="
echo "LNMP-Lite V${LNMP_LITE_VER} for CentOS Server, Written by hdwo.net"
echo "========================================================================="
echo "A tool to auto-compile & install Nginx+MySQL+PHP on CentOS "
echo ""
echo "For more information please visit http://hdwo.net/"
echo "========================================================================="
cur_dir=$(pwd)


#set mysql root password
echo "==========================="

mysqlrootpwd="root"
echo "Please input the root password of mysql:"
read -p "(Default password: root):" mysqlrootpwd
if [ "$mysqlrootpwd" = "" ]; then
	mysqlrootpwd="root"
fi
echo "==========================="
echo "MySQL root password:$mysqlrootpwd"
echo "==========================="

installinnodb="y"

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
echo "Press any key to start...or Press Ctrl+c to cancel"
char=`get_char`

function InitInstall()
{
	cat /etc/issue
	uname -a
	MemTotal=`free -m | grep Mem | awk '{print  $2}'`
	echo -e "\n Memory is: ${MemTotal} MB "
	#Set timezone
	rm -rf /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

cat >/etc/sysconfig/clock<<eof
ZONE="Asia/Shanghai"
UTC=false
ARC=false
eof

	yum install -y ntp
	ntpdate -u pool.ntp.org
	date

	rpm -qa|grep httpd
	rpm -e httpd
	rpm -qa|grep mysql
	rpm -e mysql
	rpm -qa|grep php
	rpm -e php

	yum -y remove httpd*
	yum -y remove php*
	yum -y remove mysql-server mysql mysql-libs
	yum -y remove php-mysql

	yum -y install yum-fastestmirror
	yum -y remove httpd
	#yum -y update

	#Disable SeLinux
	if [ -s /etc/selinux/config ]; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	fi

	cp /etc/yum.conf /etc/yum.conf.lnmp
	sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf

	for packages in  patch make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal nano fonts-chinese gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils pcre pcre-devel  libiconv  libmcrypt libmcrypt-devel  mcrypt mcrypt-devel  mhash libtool-ltdl libtool-ltdl-devel;
	do yum -y install $packages; done

	mv -f /etc/yum.conf.lnmp /etc/yum.conf
}

function CheckAndDownloadFiles()
{
	echo "============================check files=================================="

	if [ -s php-${PHP_VER}.tar.gz ]; then
	  echo "php-${PHP_VER}.tar.gz [found]"
	else
	  echo "Error: php-${PHP_VER}.tar.gz not found!!!download now......"
	  wget -c http://cn2.php.net/distributions/php-${PHP_VER}.tar.gz
	fi

	#if [ -s pcre-8.12.tar.gz ]; then
	#  echo "pcre-8.12.tar.gz [found]"
	#  else
	#  echo "Error: pcre-8.12.tar.gz not found!!!download now......"
	#  wget -c http://soft.vpser.net/web/pcre/pcre-8.12.tar.gz
	#fi

	if [ -s tengine-${TENGINE_VER}.tar.gz ]; then
	  echo "tengine-${TENGINE_VER}.tar.gz [found]"
	  else
	  echo "Error: tengine-${TENGINE_VER}.tar.gz not found!!!download now......"
	  wget -c http://tengine.taobao.org/download/tengine-${TENGINE_VER}.tar.gz
	fi


	if [ -s p.php ]; then
	  echo "p.php [found]"
	  else
	  echo "Error: p.tar.gz not found!!!download now......"
	  wget -c http://soft.vpser.net/prober/p.tar.gz
	fi


	if [ -s adminer-$ADMINER_VER-mysql.php ]; then
	  echo "adminer-$ADMINER_VER-mysql.php [found]"
	  else
	  echo "Error: adminer-$ADMINER_VER-mysql.php not found!!!download now......"
	  wget -c https://www.adminer.org/static/download/$ADMINER_VER/adminer-$ADMINER_VER-mysql.php
	fi


	if [ -s mysql-$MYSQL_VER.tar.gz ]; then
	  echo "mysql-$MYSQL_VER.tar.gz [found]"
	  else
	  echo "Error: mysql-$MYSQL_VER.tar.gz not found!!!download now......"
	  wget -c http://soft.vpser.net/datebase/mysql/mysql-$MYSQL_VER.tar.gz
	fi


	#if [ -s libiconv-1.14.tar.gz ]; then
	#  echo "libiconv-1.14.tar.gz [found]"
	#  else
	#  echo "Error: libiconv-1.14.tar.gz not found!!!download now......"
	#  wget -c http://soft.vpser.net/web/libiconv/libiconv-1.14.tar.gz
	#fi

	#if [ -s libmcrypt-2.5.8.tar.gz ]; then
	#  echo "libmcrypt-2.5.8.tar.gz [found]"
	#  else
	#  echo "Error: libmcrypt-2.5.8.tar.gz not found!!!download now......"
	#  wget -c  http://soft.vpser.net/web/libmcrypt/libmcrypt-2.5.8.tar.gz
	#fi

	#if [ -s mhash-0.9.9.9.tar.gz ]; then
	#  echo "mhash-0.9.9.9.tar.gz [found]"
	#  else
	#  echo "Error: mhash-0.9.9.9.tar.gz not found!!!download now......"
	#  wget -c http://soft.vpser.net/web/mhash/mhash-0.9.9.9.tar.gz
	#fi

	#if [ -s mcrypt-2.6.8.tar.gz ]; then
	#  echo "mcrypt-2.6.8.tar.gz [found]"
	#  else
	#  echo "Error: mcrypt-2.6.8.tar.gz not found!!!download now......"
	#  wget -c http://soft.vpser.net/web/mcrypt/mcrypt-2.6.8.tar.gz
	#fi


	if [ -s jemalloc-$JEMALLOC_VER.tar.bz2 ]; then
	  echo "jemalloc-$JEMALLOC_VER.tar.bz2 [found]"
	else
	  echo "Error: jemalloc-$JEMALLOC_VER.tar.bz2 not found!!!download now......"
	  wget -c http://www.canonware.com/download/jemalloc/jemalloc-$JEMALLOC_VER.tar.bz2
	fi

	#if [ -s autoconf-2.13.tar.gz ]; then
	#  echo "autoconf-2.13.tar.gz [found]"
	#  else
	#  echo "Error: autoconf-2.13.tar.gz not found!!!download now......"
	#  wget -c http://soft.vpser.net/lib/autoconf/autoconf-2.13.tar.gz
	#fi


	echo "============================check files  finished=================================="
}

function InstallDependsAndOpt()
{
	#cd $cur_dir

	#tar zxf autoconf-2.13.tar.gz
	#cd autoconf-2.13/
	#./configure --prefix=/usr/local/autoconf-2.13
	#make && make install
	#cd ../

	#tar zxf libiconv-1.14.tar.gz
	#cd libiconv-1.14/
	#./configure
	#make && make install
	#cd ../

	#cd $cur_dir
	#tar zxf libmcrypt-2.5.8.tar.gz
	#cd libmcrypt-2.5.8/
	#./configure
	#make && make install
	#/sbin/ldconfig
	#cd libltdl/
	#./configure --enable-ltdl-install
	#make && make install
	#cd ../../

	#cd $cur_dir
	#tar zxf mhash-0.9.9.9.tar.gz
	#cd mhash-0.9.9.9/
	#./configure
	#make && make install
	#cd ../

	ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
	ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
	ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
	ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
	ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
	ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
	ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
	ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
	ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1

	#cd $cur_dir
	#tar zxf mcrypt-2.6.8.tar.gz
	#cd mcrypt-2.6.8/
	#./configure
	#make && make install
	#cd ../

	cd $cur_dir
	tar jxf jemalloc-$JEMALLOC_VER.tar.bz2
	cd jemalloc-$JEMALLOC_VER/
	./configure
	make && make install
	cd ../


	if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
		ln -s /usr/lib64/libpng.* /usr/lib/
		ln -s /usr/lib64/libjpeg.* /usr/lib/
	fi

	ulimit -v unlimited

	if [ ! `grep -l "/lib"    '/etc/ld.so.conf'` ]; then
		echo "/lib" >> /etc/ld.so.conf
	fi

	if [ ! `grep -l '/usr/lib'    '/etc/ld.so.conf'` ]; then
		echo "/usr/lib" >> /etc/ld.so.conf
	fi

	if [ -d "/usr/lib64" ] && [ ! `grep -l '/usr/lib64'    '/etc/ld.so.conf'` ]; then
		echo "/usr/lib64" >> /etc/ld.so.conf
	fi

	if [ ! `grep -l '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
		echo "/usr/local/lib" >> /etc/ld.so.conf
	fi

	ldconfig

cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

	echo "fs.file-max=65535" >> /etc/sysctl.conf

}


function InstallMySQL55()
{
	echo "============================Install MySQL $MYSQL_VER=================================="
	cd $cur_dir

	rm -f /etc/my.cnf
	tar zxf mysql-$MYSQL_VER.tar.gz
	cd mysql-$MYSQL_VER/
	cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_EXTRA_CHARSETS:STRING=utf8
	make && make install

	groupadd mysql
	useradd -s /sbin/nologin -M -g mysql mysql

	cp support-files/my-medium.cnf /usr/local/mysql/my.cnf
	sed '/skip-external-locking/i\datadir = /usr/local/mysql/data' -i /usr/local/mysql/my.cnf
	if [ $installinnodb = "y" ]; then
		sed -i 's:#innodb:innodb:g' /usr/local/mysql/my.cnf
		sed -i 's:/usr/local/mysql/data:/usr/local/mysql/data:g' /usr/local/mysql/my.cnf
	else
		sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /usr/local/mysql/my.cnf
	fi

	sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libjemalloc.so@' /usr/local/mysql/bin/mysqld_safe

	/usr/local/mysql/scripts/mysql_install_db --defaults-file=/usr/local/mysql/my.cnf --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql
	chown -R mysql /usr/local/mysql/data
	chgrp -R mysql /usr/local/mysql/.
	cp support-files/mysql.server /etc/init.d/mysql
	chmod 755 /etc/init.d/mysql

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
	ldconfig

	ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
	ln -s /usr/local/mysql/include/mysql /usr/include/mysql
	if [ -d "/proc/vz" ];then
		ulimit -s unlimited
	fi
	/etc/init.d/mysql start

	ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
	ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
	ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
	ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

	/usr/local/mysql/bin/mysqladmin -u root password $mysqlrootpwd

cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('$mysqlrootpwd') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password='';

DROP USER ''@'%';
flush privileges;
EOF

	/usr/local/mysql/bin/mysql -u root -p$mysqlrootpwd -h localhost < /tmp/mysql_sec_script

	rm -f /tmp/mysql_sec_script

	/etc/init.d/mysql restart
	/etc/init.d/mysql stop
	echo "============================MySQL ${MYSQL_VER} install completed========================="
}


function InstallPHP7()
{
	echo "============================Install PHP ${PHP_VER}================================"
	cd $cur_dir
	#export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
	#export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
	tar zxf php-$PHP_VER.tar.gz
	cd php-$PHP_VER/
	./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --enable-opcache --with-fpm-user=www --with-fpm-group=www  --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd  --with-pdo-sqlite  --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath   --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl  --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --disable-fileinfo --enable-libxml

    #--with-mysql=mysqlnd  configure: WARNING: unrecognized options: --with-mysql
	# --disable-sqlite3

	make ZEND_EXTRA_LIBS='-liconv'
	make install

	rm -f /usr/bin/php
	ln -s /usr/local/php/bin/php /usr/bin/php
	ln -s /usr/local/php/bin/phpize /usr/bin/phpize
	ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm

	echo "Copy new php configure file."
	mkdir -p /usr/local/php/etc
	cp php.ini-production /usr/local/php/etc/php.ini

	cd $cur_dir

	echo "Modify php.ini......"
	sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
	sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
	sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
	sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
	sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
	sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
	sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
	sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
	sed -i 's/register_long_arrays = On/;register_long_arrays = On/g' /usr/local/php/etc/php.ini
	sed -i 's/magic_quotes_gpc = On/;magic_quotes_gpc = On/g' /usr/local/php/etc/php.ini
	sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru/g' /usr/local/php/etc/php.ini
	sed -i '/;open_basedir/i open_basedir = /home/wwwroot/:/tmp/' /usr/local/php/etc/php.ini


	echo "Creating new php-fpm configure file......"
cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/php-fpm.pid
error_log = /usr/local/php/php-fpm.log
log_level = notice

[www]
listen = /dev/shm/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
request_terminate_timeout = 120
request_slowlog_timeout = 0
slowlog = /usr/local/php/slow.log
EOF

	echo "Copy php-fpm init.d file......"
	cp $cur_dir/php-$PHP_VER/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    sed -i 's:php_fpm_PID=${prefix}/var/run/php-fpm\.pid:php_fpm_PID=${prefix}/php-fpm\.pid:g' /etc/init.d/php-fpm
	chmod +x /etc/init.d/php-fpm

	cp $cur_dir/lnmp /root/lnmp
	chmod +x /root/lnmp
	sed -i 's:/usr/local/php/logs:/usr/local/php/var/run:g' /root/lnmp
	echo "============================PHP ${PHP_VER} install completed======================"
}

function InstallNginx()
{
	echo "============================Install Tengine ${TENGINE_VER} ================================="
	groupadd www
	useradd -M -s /sbin/nologin -g www www
	cd $cur_dir
	#tar zxf pcre-8.12.tar.gz
	#cd pcre-8.12/
	#./configure
	#make && make install
	#cd ../

	ldconfig

	tar zxf tengine-$TENGINE_VER.tar.gz
	cd tengine-$TENGINE_VER/
	if [ $TENGINE_VER = '2.1.1' ]; then
		sed -i 's#/x-javascript#/javascript#g' src/http/modules/ngx_http_concat_module.c
	fi
	./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --with-http_concat_module --with-http_sysguard_module=shared  --with-ipv6  --with-jemalloc
	make && make install
	cd ../

	ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

	#rm -f /usr/local/nginx/conf/nginx.conf
	mv /usr/local/nginx/conf/nginx.conf  /usr/local/nginx/conf/nginx.conf.old
	cd $cur_dir
	cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
	cp conf/dabr.conf /usr/local/nginx/conf/dabr.conf
	cp conf/discuz.conf /usr/local/nginx/conf/discuz.conf
	cp conf/sablog.conf /usr/local/nginx/conf/sablog.conf
	cp conf/typecho.conf /usr/local/nginx/conf/typecho.conf
	cp conf/wordpress.conf /usr/local/nginx/conf/wordpress.conf
	cp conf/discuzx.conf /usr/local/nginx/conf/discuzx.conf
	cp conf/none.conf /usr/local/nginx/conf/none.conf
	cp conf/wp2.conf /usr/local/nginx/conf/wp2.conf
	cp conf/phpwind.conf /usr/local/nginx/conf/phpwind.conf
	cp conf/shopex.conf /usr/local/nginx/conf/shopex.conf
	cp conf/dedecms.conf /usr/local/nginx/conf/dedecms.conf
	cp conf/drupal.conf /usr/local/nginx/conf/drupal.conf
	cp conf/ecshop.conf /usr/local/nginx/conf/ecshop.conf
	cp conf/pathinfo.conf /usr/local/nginx/conf/pathinfo.conf

	cd $cur_dir
	cp vhost.sh /root/vhost.sh
	chmod +x /root/vhost.sh

	mkdir -p /home/wwwroot/default
	chmod +w /home/wwwroot/default
	mkdir -p /home/logs
	chmod 777 /home/logs

	chown -R www:www /home/wwwroot/default
}

function CreatPHPTools()
{
	echo "Create PHP Info Tool..."
cat >/home/wwwroot/default/phpinfo.php<<eof
<?
phpinfo();
?>
eof

	echo "Copy PHP Prober..."
	cd $cur_dir
	if [ -s p.php ]; then
	  	cp p.php /home/wwwroot/default/p.php
	else
	  	tar zxvf p.tar.gz
		cp p.php /home/wwwroot/default/p.php
	fi

	cp conf/index.html /home/wwwroot/default/index.html
	echo "============================Install adminer================================="
	mv adminer-$ADMINER_VER-mysql.php /home/wwwroot/default/adminer.php
	echo "============================adminer install completed================================="
}

function AddAndStartup()
{
	echo "============================add nginx and php-fpm on startup============================"
	echo "Download new nginx init.d file......"
	if [ -s conf/init.d.nginx ]; then
	  echo "init.d.nginx [found]"
	else
	  echo "Error: init.d.nginx not found!!!download now......"
	  wget -c http://soft.vpser.net/lnmp/ext/init.d.nginx
	fi

	#wget -c http://soft.vpser.net/lnmp/ext/init.d.nginx
	cp init.d.nginx /etc/init.d/nginx
	chmod +x /etc/init.d/nginx

	chkconfig --level 345 php-fpm on
	chkconfig --level 345 nginx on
	chkconfig --level 345 mysql on
	echo "===========================add nginx and php-fpm on startup completed===================="
	echo "Starting LNMP..."
	/etc/init.d/mysql start
	/etc/init.d/php-fpm start
	/etc/init.d/nginx start

	#add iptables firewall rules
	if [ -s /sbin/iptables ]; then
		/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
		/sbin/iptables -I INPUT -p tcp --dport 3306 -j DROP
		#/sbin/iptables-save  #linodeVPS can't save and this is temporary.
		/sbin/service iptables save
	fi
}

function CheckInstall()
{
	echo "===================================== Check install ==================================="
	clear
	isnginx=""
	ismysql=""
	isphp=""
	echo "Checking..."
	if [ -s /usr/local/nginx/conf/nginx.conf ] && [ -s /usr/local/nginx/sbin/nginx ]; then
	  echo "Nginx: OK"
	  isnginx="ok"
	else
	  echo "Error: /usr/local/nginx not found!!!Nginx install failed."
	fi

	if [ -s /usr/local/mysql/bin/mysql ] && [ -s /usr/local/mysql/bin/mysqld_safe ] && [ -s /usr/local/mysql/my.cnf ]; then
		  echo "MySQL: OK"
		  ismysql="ok"
	else
		echo "Error: /usr/local/mysql not found!!!MySQL install failed."
	fi



	if [ -s /usr/local/php/sbin/php-fpm ] && [ -s /usr/local/php/etc/php.ini ] && [ -s /usr/local/php/bin/php ]; then
	  echo "PHP: OK"
	  echo "PHP-FPM: OK"
	  isphp="ok"
	else
	  echo "Error: /usr/local/php not found!!!PHP install failed."
	fi

	if [ "$isnginx" = "ok" ] && [ "$ismysql" = "ok" ] && [ "$isphp" = "ok" ]; then
		echo "Install LNMP-Lite ${LNMP_LITE_VER} completed! enjoy it."
		echo "========================================================================="
		echo "LNMP-Lite ${LNMP_LITE_VER}  for CentOS Linux Server, Written by hdwo.net "
		echo "========================================================================="
		echo ""
		echo "For more information please visit http://hdwo.net/"
		echo ""
		echo "lnmp status manage: /root/lnmp {start|stop|reload|restart|kill|status}"
		echo "default mysql root password:$mysqlrootpwd"
		echo "phpinfo : http://yourIP/phpinfo.php"
		echo "phpMyAdmin : http://yourIP/adminer-$ADMINER_VER-mysql.php"
		echo "Prober : http://yourIP/p.php"
		echo "Add VirtualHost : /root/vhost.sh"
		echo ""
		echo "The path of some dirs:"
		echo "mysql dir:   /usr/local/mysql"
		echo "php dir:     /usr/local/php"
		echo "nginx dir:   /usr/local/nginx"
		echo "web dir :     /home/wwwroot/default"
		echo ""
		echo "========================================================================="
		/root/lnmp status
		netstat -ntl
	else
		echo "Sorry,Failed to install LNMP-Lite!"
		echo "Please visit http://hdwo.net/guestbook feedback errors and logs."
	fi
}

InitInstall 2>&1 | tee /root/lnmp-install.log
CheckAndDownloadFiles 2>&1 | tee -a /root/lnmp-install.log
InstallDependsAndOpt 2>&1 | tee -a /root/lnmp-install.log

InstallMySQL55 2>&1 | tee -a /root/lnmp-install.log

InstallPHP7 2>&1 | tee -a /root/lnmp-install.log

InstallNginx 2>&1 | tee -a /root/lnmp-install.log
CreatPHPTools 2>&1 | tee -a /root/lnmp-install.log
AddAndStartup 2>&1 | tee -a /root/lnmp-install.log
CheckInstall 2>&1 | tee -a /root/lnmp-install.log