#!/bin/bash

PREFIX=`pwd`/arm-none-eabi
TARGET=`pwd`/target
URL=ftp://ftp.gnu.org/gnu

# libraries
GMP_VERSION=4.2
GMP_URL=https://gmplib.org/download/gmp
MPFR_VERSION=2.4.2
MPFR_URL=http://mpfr.loria.fr
MPC_VERSION=0.8.2
MPC_URL=http://www.multiprecision.org/mpc/download

# toolchain
GCC_VERSION=4.8.1
BINUTILS_VERSION=2.24
NEWLIB_VERSION=2.0.0
GDB_VERSION=7.7
GDB_EXT_VERSION=${GDB_VERSION}


rm -rf ${TARGET}/build

mkdir -p ${TARGET}/orig
mkdir -p ${TARGET}/src
mkdir -p ${TARGET}/build

cd ${TARGET}/orig

if [ ! -e gmp-${GMP_VERSION}.tar.bz2 ]; then
        wget ${GMP_URL}/gmp-${GMP_VERSION}.tar.bz2 || exit 1;
fi

if [ ! -e mpfr-${MPFR_VERSION}.tar.bz2 ]; then
        wget ${MPFR_URL}/mpfr-${MPFR_VERSION}/mpfr-${MPFR_VERSION}.tar.bz2 || exit 1;
fi

if [ ! -e mpc-${MPC_VERSION}.tar.gz ]; then
        wget ${MPC_URL}/mpc-${MPC_VERSION}.tar.gz || exit 1;
fi

if [ ! -e gcc-${GCC_VERSION}.tar.gz ]; then
	wget ${URL}/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz || exit 1;
fi
#if [ ! -e gcc-core-${GCC_VERSION}.tar.gz ]; then
#	wget ${URL}/gcc/gcc-${GCC_VERSION}/gcc-core-${GCC_VERSION}.tar.gz || exit 1;
#fi

if [ ! -e gdb-${GDB_EXT_VERSION}.tar.gz ]; then
	wget ${URL}/gdb/gdb-${GDB_EXT_VERSION}.tar.gz || exit 1;
fi

if [ ! -e binutils-${BINUTILS_VERSION}.tar.bz2 ]; then
	wget ${URL}/binutils/binutils-${BINUTILS_VERSION}.tar.bz2 || exit 1;
fi

if [ ! -e newlib-${NEWLIB_VERSION}.tar.gz ]; then
	wget ftp://sources.redhat.com/pub/newlib/newlib-${NEWLIB_VERSION}.tar.gz || exit 1;
fi

cd ${TARGET}/src

if [ ! -d ${TARGET}/src/gmp-${GMP_VERSION} ]; then
   tar xvf ../orig/gmp-${GMP_VERSION}.tar.bz2 || exit 1;
fi

if [ ! -d ${TARGET}/src/mpfr-${MPFR_VERSION} ]; then
   tar xvf ../orig/mpfr-${MPFR_VERSION}.tar.bz2 || exit 1;
fi

if [ ! -d ${TARGET}/src/mpc-${MPC_VERSION} ]; then
   tar xvf ../orig/mpc-${MPC_VERSION}.tar.gz || exit 1;
fi

if [ ! -d ${TARGET}/src/gcc-${GCC_VERSION} ]; then 
   tar xvf ../orig/gcc-${GCC_VERSION}.tar.gz || exit 1;
fi

#if [ ! -d ${TARGET}/src/gcc-core-${GCC_VERSION} ]; then
#	tar xvf ../orig/gcc-core-${GCC_VERSION}.tar.gz || exit 1;
#fi

if [ ! -d ${TARGET}/src/gdb-${GDB_EXT_VERSION} ]; then
	tar xvf ../orig/gdb-${GDB_EXT_VERSION}.tar.gz || exit 1;
fi

if [ ! -d ${TARGET}/src/binutils-${BINUTILS_VERSION} ]; then
	tar xvf ../orig/binutils-${BINUTILS_VERSION}.tar.bz2 || exit 1;
fi

if [ ! -d ${TARGET}/src/newlib-${NEWLIB_VERSION} ]; then
	tar xvf ../orig/newlib-${NEWLIB_VERSION}.tar.gz || exit 1;
fi



if [ ! -d ${TARGET}/build/gmp-${GMP_VERSION} ]; then
   mkdir -p ${TARGET}/build/gmp-${GMP_VERSION}
   cd ${TARGET}/build/gmp-${GMP_VERSION}
   ../../src/gmp-${GMP_VERSION}/configure || exit 1;
   make || exit 1;
fi

if [ ! -d ${TARGET}/build/mpfr-${MPFR_VERSION} ]; then
   mkdir -p ${TARGET}/build/mpfr-${MPFR_VERSION}
   cd ${TARGET}/build/mpfr-${MPFR_VERSION}
   ../../src/mpfr-${MPFR_VERSION}/configure \
	--prefix=. \
	--with-gmp-build=../gmp-${GMP_VERSION} || exit 1;
   make || exit 1;
   make install || exit 1;
fi

if [ ! -d ${TARGET}/build/mpc-${MPC_VERSION} ]; then
   mkdir -p ${TARGET}/build/mpc-${MPC_VERSION}
   cd ${TARGET}/build/mpc-${MPC_VERSION}
   ../../src/mpc-${MPC_VERSION}/configure --with-gmp=${TARGET}/build/gmp-${GMP_VERSION} --with-mpfr=${TARGET}/build/mpfr-${MPFR_VERSION} || exit 1;
   make || exit 1;
fi

if [ ! -e ${PREFIX}/bin/arm-none-eabi-ld ]; then
	mkdir -p ${TARGET}/build/binutils-${BINUTILS_VERSION}
	sed -i -e 's/@colophon/@@colophon/g' \
          -e 's/doc@cygnus.com/doc@@cygnus.com/g' ${TARGET}/src/binutil        s-${BINUTILS_VERSION}/bfd/doc/bfd.texinfo
	cd ${TARGET}/build/binutils-${BINUTILS_VERSION}
	../../src/binutils-${BINUTILS_VERSION}/configure \
		--target=arm-none-eabi \
		--prefix=${PREFIX} \
		--enable-interwork \
		--enable-multilib \
		--with-gnu-as \
		--with-gnu-ld \
		--disable-nls \
		--disable-werror || exit 1;
	make all install || exit 1;
fi
export PATH="$PATH:${PREFIX}/bin"

mkdir -p ${TARGET}/build/gcc-${GCC_VERSION}
sed -i 's/BUILD_INFO=info/BUILD_INFO =/g' ${TARGET}/src/gcc-${GCC_VERSION}/gcc/configure
cd ${TARGET}/build/gcc-${GCC_VERSION}
../../src/gcc-${GCC_VERSION}/configure \
	--target=arm-none-eabi \
	--prefix=${PREFIX} \
	--enable-interwork \
	--enable-multilib \
	--disable-nls \
	--with-system-zlib \
	--enable-languages="c" \
	--without-docdir \
  	--with-gmp=../gmp-${GMP_VERSION} \
  	--with-mpfr=../mpfr-${MPFR_VERSION} \
  	--with-mpc=../mpc-${MPC_VERSION} \
	--with-newlib \
	--with-headers=../../src/newlib-${NEWLIB_VERSION}/newlib/libc/include || exit 1;
make all-gcc install-gcc || exit 1;

mkdir -p ${TARGET}/build/newlib-${NEWLIB_VERSION}
cd ${TARGET}/build/newlib-${NEWLIB_VERSION}
../../src/newlib-${NEWLIB_VERSION}/configure \
	--target=arm-none-eabi \
	--prefix=${PREFIX} \
	--enable-interwork \
        --with-gnu-as \
        --with-gnu-ld \
        --disable-nls \
        --enable-newlib-io-c99-formats \
        --enable-newlib-io-long-long \
        --disable-newlib-multithread \
        --disable-newlib-supplied-syscalls \
	--enable-multilib || exit 1;
make all install || exit 1;

cd ${TARGET}/build/gcc-${GCC_VERSION}
make all install || exit 1;

mkdir -p ${TARGET}/build/gdb-${GDB_VERSION}
cd ${TARGET}/build/gdb-${GDB_VERSION}
../../src/gdb-${GDB_VERSION}/configure --target=arm-none-eabi --prefix=${PREFIX} --disable-werror --enable-interwork --enable-multilib || exit 1;
make all install || exit 1;
