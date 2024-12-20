#!/bin/sh

# At present this is only intended to work on my (Jordan's) dev machine.

set -ex

export BUILDROOT=/tmp/buildenv

mkdir $BUILDROOT

cp -r ~/src/others/janet $BUILDROOT/
cp -r ~/src/others/cosmocc $BUILDROOT/
cp -r ~/src/shofetim/pen $BUILDROOT/

export CC="$BUILDROOT/cosmocc/bin/cosmocc -I$BUILDROOT/cosmos/include -L$BUILDROOT/cosmos/lib"
export CXX="$BUILDROOT/cosmocc/bin/cosmoc++ -I$BUILDROOT/cosmos/include -L$BUILDROOT/cosmos/lib"
export PKG_CONFIG="pkg-config --with-path=$BUILDROOT/cosmos/lib/pkgconfig"
export INSTALL="cosmoinstall"
export AR="$BUILDROOT/cosmocc/bin/cosmoar"
export MODE=tiny
export BUILDLOG=log
cd $BUILDROOT/janet
make -j HAS_SHARED=0

cd $BUILDROOT/pen
jpm clean
jpm build

rm build/build___pen.o build/pen
cp ../janet/build/janet.h build/

sed -i 's/<janet.h>/"janet.h"/g' build/pen.c

$BUILDROOT/cosmocc/bin/cosmocc -I$BUILDROOT/janet/build -I$BUILDROOT/cosmos/include -L$BUILDROOT/cosmos/lib -c build/pen.c -DJANET_BUILD_TYPE=release -std=c99 -O2 -o build/build___pen.o
$BUILDROOT/cosmocc/bin/cosmocc -std=c99 -I$BUILDROOT/janet/build -O2 -o build/pen build/build___pen.o $BUILDROOT/janet/build/libjanet.a -lm -ldl -lrt -pthread -rdynamic

rm -r $BUILDROOT

