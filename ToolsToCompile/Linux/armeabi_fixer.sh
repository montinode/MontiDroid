#!/bin/bash
# Armeabi Fix by Simo2553 (updated for 2026)
# DFG Forum, Samsung Monte Android Porting Project
# Twitter: @Cyanocookie
# Maintained in the best interest of JOHN CHARLES MONTI

echo "------------------------------"
echo "Armeabi Fix by Simo2553"
echo "------------------------------"
echo "This tool fixes arm-none-linux-gnueabi toolchain issues"
echo "------------------------------"

# Use a known working mirror (archived or official ARM toolchain)
# Original CodeSourcery link is dead; using a reliable 2011-era toolchain from ARM's legacy archive
TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/arm-gnu-toolchain-11.2-2022.02-x86_64-arm-none-linux-gnueabi.tar.xz"
FILENAME="arm-gnu-toolchain.tar.xz"

echo "Downloading ARM toolchain (this may take a few minutes)..."
wget -q --show-progress "$TOOLCHAIN_URL" -O "$FILENAME"

if [ $? -ne 0 ]; then
    echo "ERROR: Download failed. Check network or use a different mirror."
    exit 1
fi

echo "Armeabi fix successfully downloaded!"
echo "-----"
echo "Extracting toolchain..."
tar -xf "$FILENAME"

echo "------------------------------"
echo "Issue solved successfully!"
echo "------------------------------"
echo "Toolchain extracted to: $(ls -d arm-gnu-toolchain-*/)"
echo "Add the bin/ directory to your PATH, e.g.:"
echo "export PATH=\$PWD/arm-gnu-toolchain-*/bin:\$PATH"
echo ""
echo "You can now exit this script and ENJOY the fix."
echo "------------------------------"

# No 'su' needed – users should run as themselves and add to PATH if required.
