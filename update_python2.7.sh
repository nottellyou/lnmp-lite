#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install LNMP-Lite"
    exit 1
fi

clear


#echo "don't update python, it will efect yum"
#exit 0

#mv /usr/bin/python /usr/bin/python2.4

PYTHON_VER=2.7.11

wget --no-check-certificate https://python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz

tar xzf Python-$PYTHON_VER.tar.bz2

cd Python-$PYTHON_VER/

./configure --prefix=/usr/local/python27

make

make install

#mv -y /usr/bin/python /usr/bin/python2.4

ln -s /usr/local/python27/bin/python /usr/bin/python27

#请手工替换sed -i "s@\#\!/usr/bin/python@\#\!/usr/bin/python2\.4@" /usr/bin/yum

echo "===================update python $PYTHON_VER  complete!!!!  ============================"
exit 0