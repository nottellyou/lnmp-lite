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
GCC_VER=4.9.3


echo "========================================================================="
echo "LNMP-Lite V${LNMP_LITE_VER} for CentOS Server, Written by hdwo.net"
echo "========================================================================="
echo "update GCC to $GCC_VER on CentOS "
echo ""
echo "For more information please visit http://hdwo.net/"
echo "========================================================================="


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


if [ $GCC_VER = '4.9.3' ]; then
  echo "===================update GCC $GCC_VER  begin ============================"
else
  echo "Error: GCC version must be $GCC_VER......"
  exit 0
fi


wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-$GCC_VER/gcc-$GCC_VER.tar.gz
tar -xf gcc-$GCC_VER.tar.gz
cd gcc-$GCC_VER

mkdir gcc_temp

./contrib/download_prerequisites

cd contrib/gmp-4.3.2/
./configure
make && make install

cd ../mpfr-2.4.2/
./configure  --with-gmp-include=/usr/local/include --with-gmp-lib=/usr/local/lib
make && make install

cd ../mpc-0.8.1/
./configure --with-gmp-include=/usr/local/include --with-gmp-lib=/usr/local/lib --with-mpfr-include=/usr/local/include    --with-mpfr-lib=/usr/local/lib
make && make install

export C_INCLUDE_PATH=/usr/local/include:$C_INCLUDE_PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

cd ../../gcc_temp/
../configure --prefix=/usr  --with-gmp=/usr/local  --with-mpfr=/usr/local  --with-mpc=/usr/local  --enable-checking=release  --enable-languages=c,c++  --disable-multilib
make && make install


echo "===================update GCC $GCC_VER  complete!!!!  ============================"

cd /root/