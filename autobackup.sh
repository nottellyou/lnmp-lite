#!/bin/bash
#你要修改的地方从这里开始
MYSQL_USER=root                             #mysql用户名
MYSQL_PASS=123456                      #mysql密码
#你要修改的地方从这里结束

#定义数据库的名字和旧数据库的名字
data1=diyibushen_data_$(date +"%Y-%m-%d").sql
#web1=diyibushen_web_$(date +%Y-%m-%d).tar.gz

data2=hdwo.net_data_$(date +"%Y-%m-%d").sql
web2=hdwo.net_web_$(date +%Y-%m-%d).zip

data3=zblog_data_$(date +"%Y-%m-%d").sql
web3=zblog_web_$(date +%Y-%m-%d).zip

#data4=uc_data_$(date +"%Y-%m-%d").sql
#web4=uc_web_$(date +%Y-%m-%d).zip


/usr/local/mysql/bin/mysqldump -u$MYSQL_USER -p$MYSQL_PASS diyibushen_com > /home/wwwroot/hdwo.net/$data1
/usr/local/mysql/bin/mysqldump -u$MYSQL_USER -p$MYSQL_PASS wordpress37 > /home/wwwroot/hdwo.net/$data2
/usr/local/mysql/bin/mysqldump -u$MYSQL_USER -p$MYSQL_PASS zblog > /home/wwwroot/jia.hdwo.net/$data3
#/usr/local/mysql/bin/mysqldump -u$MYSQL_USER -p$MYSQL_PASS phpok > /home/backup/$data3

#压缩sql
#cd /home/backup/
#tar zcf /home/backup/sql_$(date +%Y-%m-%d).tar.gz    $data1  $data2 
#tar zcf /home/backup/sql_$(date +%Y-%m-%d).tar.gz    $data1  $data2 $data4  $data3

#压缩网站数据
#cd /home/wwwroot/www.diyibushen.com/
#tar zcf /home/backup/$web1  *

cd /home/wwwroot/hdwo.net/
zip -q -r /home/backup/$web2  * 
rm  -f  $data1
rm  -f  $data2


cd /home/wwwroot/jia.hdwo.net/
zip -q -r /home/backup/$web3  *

#cd /home/wwwroot/uc.holl.cn/
#zip -q -r   /home/backup/$web4  *

rm  -f  /home/wwwroot/jia.hdwo.net/$data3

find  /home/backup/  -mtime +20  -name "hdwo.net_web*"  -exec  rm  -rf {} \;
find  /home/backup/  -mtime +20  -name "zblog_web*"     -exec  rm  -rf {} \; 

##################################################
#30  4  *  *  * /root/autobackup.sh