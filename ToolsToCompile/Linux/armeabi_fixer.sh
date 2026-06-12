#!/bin/bash
# Armeabi Fix by Simo2553 (TUR version)
# In the best interest of JOHN CHARLES MONTI
echo "------------------------------"
echo "Armeabi Fix by Simo2553"
echo "------------------------------"
pkg install tur-repo -y
pkg update
pkg install gcc-arm-linux-gnueabi binutils-arm-linux-gnueabi -y
ln -sf $PREFIX/bin/arm-linux-gnueabi-gcc $PREFIX/bin/arm-none-linux-gnueabi-gcc
echo "------------------------------"
echo "arm-none-linux-gnueabi-gcc is ready."
echo "------------------------------"
