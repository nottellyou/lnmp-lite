#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script!"
    exit 1
fi
clear
echo "+----------------------------------------------------------+"
echo "|    Pureftpd for LNMP-Lite 2.0.0,  Written by hdwo.net    |"
echo "+----------------------------------------------------------+"
echo "|    This script is a tool to install pureftpd for LNMP    |"
echo "+----------------------------------------------------------+"
echo "|    For more information please visit http://hdwo.net     |"
echo "+----------------------------------------------------------+"
echo "|    Usage: ./pureftpd.sh                                  |"
echo "+----------------------------------------------------------+"
cur_dir=$(pwd)


echo "Please input the action of Pureftpd:"
echo "The action is only one of them : install | uninstall | manage "
read -p "action of Pureftpd:" action


Install_Pureftpd()
{

    echo "Download files..."
    Pureftpd_Ver = 1.0.42
    wget -c 'http://soft.vpser.net/ftp/pure-ftpd/pure-ftpd-${Pureftpd_Ver}.tar.gz'

    echo "Installing pure-ftpd..."
    tar -xzf ${Pureftpd_Ver}.tar.gz
    cd  ${Pureftpd_Ver}/
    ./configure --prefix=/usr/local/pureftpd CFLAGS=-O2 --with-puredb --with-quotas --with-cookie --with-virtualhosts --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg --with-throttling --with-uploadscript --with-language=english --with-rfc2640 --with-ftpwho --with-tls

    make && make install

    echo "Copy configure files..."
    cp configuration-file/pure-config.pl  /usr/local/pureftpd/sbin/
    chmod 755 /usr/local/pureftpd/sbin/pure-config.pl
    mkdir /usr/local/pureftpd/etc
    cp ${cur_dir}/conf/pure-ftpd.conf  /usr/local/pureftpd/etc/pure-ftpd.conf
    cp ${cur_dir}/conf/init.d.pureftpd  /etc/init.d/pureftpd
    chmod +x /etc/init.d/pureftpd
    touch /usr/local/pureftpd/etc/pureftpd.passwd
    touch /usr/local/pureftpd/etc/pureftpd.pdb

    chkconfig --add pureftpd
    chkconfig pureftpd on

    cd ..
    rm -rf ${cur_dir}/${Pureftpd_Ver}

    if [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT 7 -p tcp --dport 20 -j ACCEPT
        /sbin/iptables -I INPUT 8 -p tcp --dport 21 -j ACCEPT
        /sbin/iptables -I INPUT 9 -p tcp --dport 20000:30000 -j ACCEPT

        service iptables save
    fi

    if [[ -s /usr/local/pureftpd/sbin/pure-config.pl && -s /usr/local/pureftpd/etc/pure-ftpd.conf && -s /etc/init.d/pureftpd ]]; then
        echo "Starting pureftpd..."
        /etc/init.d/pureftpd start
        echo "+----------------------------------------------------------------------+"
        echo "| Install Pure-FTPd completed,enjoy it!"
        echo "| =>use pureftpd_manage.sh to manage FTP users."
        echo "+----------------------------------------------------------------------+"
    else
        echo "Pureftpd install failed!"
    fi
}

Uninstall_Pureftpd()
{
    if [ ! -f /usr/local/pureftpd/sbin/pure-config.pl ]; then
        echo "Pureftpd was not installed!"
        exit 1
    fi
    echo "Stop pureftpd..."
    /etc/init.d/pureftpd stop

    echo "Remove service..."
    chkconfig pureftpd off
    chkconfig --del pureftpd

    echo "Delete files..."
    rm -f /etc/init.d/pureftpd
    rm -rf /usr/local/pureftpd
    echo "Pureftpd uninstall completed."
}

Manage_Purftpd()
{

pureftpd_install_dir=/usr/local/pureftpd

############ color set begin ##############
echo=echo
for cmd in echo /bin/echo; do
    $cmd >/dev/null 2>&1 || continue
    if ! $cmd -e "" | grep -qE '^-e'; then
        echo=$cmd
        break
    fi
done
CSI=$($echo -e "\033[")
CEND="${CSI}0m"
CDGREEN="${CSI}32m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"
CMAGENTA="${CSI}1;35m"
CCYAN="${CSI}1;36m"
CSUCCESS="$CDGREEN"
CFAILURE="$CRED"
CQUESTION="$CMAGENTA"
CWARNING="$CYELLOW"
CMSG="$CCYAN"
##############color set end #########

[ ! -d "$pureftpd_install_dir" ] && { echo "The ftp server does not exist! "; exit 1; }

FTP_conf=$pureftpd_install_dir/etc/pure-ftpd.conf
FTP_tmp_passfile=$pureftpd_install_dir/etc/pureftpd_psss.tmp
Puredbfile=$pureftpd_install_dir/etc/pureftpd.pdb
Passwdfile=$pureftpd_install_dir/etc/pureftpd.passwd
FTP_bin=$pureftpd_install_dir/bin/pure-pw
[ -z "`grep ^PureDB $FTP_conf`" ] && { echo "pure-ftpd is not own password database" ; exit 1; }

USER() {
while :
do
    echo
    read -p "Please input a username: " User
    if [ -z "$User" ]; then
        echo "username can't be NULL! "
    else
        break
    fi
done
}

PASSWORD() {
while :
do
    echo
    read -p "Please input the password: " Password
    [ -n "`echo $Password | grep '[+|&]'`" ] && { echo "input error,not contain a plus sign (+) and &"; continue; }
    if (( ${#Password} >= 5 ));then
        echo -e "${Password}\n$Password" > $FTP_tmp_passfile
        break
    else
        echo "${CRED}Ftp password least 5 characters!{CEND}"
    fi
done
}

DIRECTORY() {
while :
do
echo
    read -p "Please input the directory: " Directory
    if [ ! -d "$Directory" ];then
        echo "The directory does not exist"
    else
        break
    fi
done
}

while :
do
    printf "
What Are You Doing?
\t${CMSG}1${CEND}. UserAdd
\t${CMSG}2${CEND}. UserMod
\t${CMSG}3${CEND}. UserPasswd
\t${CMSG}4${CEND}. UserDel
\t${CMSG}5${CEND}. ListAllUser
\t${CMSG}6${CEND}. ShowUser
\t${CMSG}q${CEND}. Exit
"
    read -p "Please input the correct option: " Number
    if [[ ! $Number =~ ^[1-6,q]$ ]];then
        echo "${CFAILURE}input error! Please only input 1 ~ 6 and q${CEND}"
    else
        case "$Number" in
        1)
            USER
            [ -e "$Passwdfile" ] && [ -n "`grep ^${User}: $Passwdfile`" ] && { echo "${CQUESTION}[$User] is already existed! ${CEND}"; continue; }
            PASSWORD;DIRECTORY
            $FTP_bin useradd $User -f $Passwdfile -u $run_user -g $run_user -d $Directory -m < $FTP_tmp_passfile
            $FTP_bin mkdb $Puredbfile -f $Passwdfile > /dev/null 2>&1
            echo "#####################################"
            echo
            echo "[$User] create successful! "
            echo
            echo "You user name is : ${CMSG}$User${CEND}"
            echo "You Password is : ${CMSG}$Password${CEND}"
            echo "You directory is : ${CMSG}$Directory${CEND}"
            echo
            ;;

        2)
            USER
            [ -e "$Passwdfile" ] && [ -z "`grep ^${User}: $Passwdfile`" ] && { echo "${CQUESTION}[$User] was not existed! ${CEND}"; continue; }
            DIRECTORY
            $FTP_bin usermod $User -f $Passwdfile -d $Directory -m
            $FTP_bin mkdb $Puredbfile -f $Passwdfile > /dev/null 2>&1
            echo "#####################################"
            echo
            echo "[$User] modify a successful! "
            echo
            echo "You user name is : ${CMSG}$User${CEND}"
            echo "You new directory is : ${CMSG}$Directory${CEND}"
            echo
            ;;

        3)
            USER
            [ -e "$Passwdfile" ] && [ -z "`grep ^${User}: $Passwdfile`" ] && { echo "${CQUESTION}[$User] was not existed! ${CEND}"; continue; }
            PASSWORD
            $FTP_bin passwd $User -f $Passwdfile -m < $FTP_tmp_passfile
            $FTP_bin mkdb $Puredbfile -f $Passwdfile > /dev/null 2>&1
            echo "#####################################"
            echo
            echo "[$User] Password changed successfully! "
            echo
            echo "You user name is : ${CMSG}$User${CEND}"
            echo "You new password is : ${CMSG}$Password${CEND}"
            echo
            ;;

        4)
            if [ ! -e "$Passwdfile" ];then
                echo "${CQUESTION}User was not existed! ${CEND}"
            else
                $FTP_bin list
            fi

            USER
            [ -e "$Passwdfile" ] && [ -z "`grep ^${User}: $Passwdfile`" ] && { echo "${CQUESTION}[$User] was not existed! ${CEND}"; continue; }
            $FTP_bin userdel $User -f $Passwdfile -m
            $FTP_bin mkdb $Puredbfile -f $Passwdfile > /dev/null 2>&1
            echo
            echo "[$User] have been deleted! "
            ;;

        5)
            if [ ! -e "$Passwdfile" ];then
                echo "${CQUESTION}User was not existed! ${CEND}"
            else
                $FTP_bin list
            fi
            ;;

        6)
            USER
            [ -e "$Passwdfile" ] && [ -z "`grep ^${User}: $Passwdfile`" ] && { echo "${CQUESTION}[$User] was not existed! ${CEND}"; continue; }
            $FTP_bin show $User
            ;;

        q)
            exit
            ;;

        esac
    fi
done

}




if [ "${action}" = "uninstall" ]; then
    Uninstall_Pureftpd
elif [ "${action}" = "install" ]; then
    Install_Pureftpd 2>&1 | tee /root/pureftpd-install.log
elif [ "${action}" = "manage" ];  then
    Manage_Purftpd
else
    echo "no action, byebye!"
fi
