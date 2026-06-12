#!/data/data/com.termux/files/usr/bin/bash
# CreateToolsToCompile – Full MontiDroid build environment
# In the best interest of JOHN CHARLES MONTI
# Usage: bash CreateToolsToCompile.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "============================================================"
echo "     MONTIDROID – CREATE TOOLS TO COMPILE"
echo "============================================================"
echo -e "${NC}"

# --------------------------------------------------------------
# 1. Check environment
# --------------------------------------------------------------
if [ ! -d "$PREFIX" ]; then
    echo -e "${RED}Error: Not running inside Termux.${NC}"
    exit 1
fi

# --------------------------------------------------------------
# 2. Install required packages
# --------------------------------------------------------------
echo -e "${YELLOW}[*] Updating packages and installing prerequisites...${NC}"
pkg update -y
pkg install -y tur-repo
pkg update
pkg install -y gcc-arm-linux-gnueabi binutils-arm-linux-gnueabi make git wget curl file

# --------------------------------------------------------------
# 3. Fix symlink for arm-none-linux-gnueabi-gcc
# --------------------------------------------------------------
echo -e "${YELLOW}[*] Creating correct symlink for arm-none-linux-gnueabi-gcc...${NC}"
rm -f "$PREFIX/bin/arm-none-linux-gnueabi-gcc"
ln -sf "$PREFIX/bin/arm-linux-gnueabi-gcc" "$PREFIX/bin/arm-none-linux-gnueabi-gcc"

# --------------------------------------------------------------
# 4. Verify toolchain
# --------------------------------------------------------------
if ! command -v arm-none-linux-gnueabi-gcc &> /dev/null; then
    echo -e "${RED}Failed to install cross-compiler.${NC}"
    exit 1
fi
echo -e "${GREEN}[✓] Toolchain ready: $(arm-none-linux-gnueabi-gcc --version | head -1)${NC}"

# --------------------------------------------------------------
# 5. Create workspace directories
# --------------------------------------------------------------
WORKSPACE="$HOME/montidroid"
BOOTLOADER_DIR="$WORKSPACE/bootloader"
KERNEL_DIR="$WORKSPACE/kernel"
TOOLS_DIR="$WORKSPACE/tools"

mkdir -p "$BOOTLOADER_DIR" "$KERNEL_DIR" "$TOOLS_DIR"

# --------------------------------------------------------------
# 6. Create a simple bootloader source (assembly)
# --------------------------------------------------------------
echo -e "${YELLOW}[*] Creating bootloader source (boot.S) ...${NC}"
cat > "$BOOTLOADER_DIR/boot.S" << 'EOF'
.section .text
.global _start
_start:
    @ Minimal bootloader for Samsung Monte
    mov r0, #0          @ status code 0
    mov r7, #1          @ syscall exit
    swi 0               @ software interrupt
EOF

# --------------------------------------------------------------
# 7. Create a Makefile for the bootloader
# --------------------------------------------------------------
cat > "$BOOTLOADER_DIR/Makefile" << 'EOF'
CROSS_COMPILE ?= arm-none-linux-gnueabi-
CC = $(CROSS_COMPILE)gcc
OBJCOPY = $(CROSS_COMPILE)objcopy
CFLAGS = -nostdlib -static
TARGET = bootloader.elf
BIN = bootloader.bin

all: $(BIN)

$(TARGET): boot.S
	$(CC) $(CFLAGS) -o $@ $^

$(BIN): $(TARGET)
	$(OBJCOPY) -O binary $< $@

clean:
	rm -f $(TARGET) $(BIN)

.PHONY: all clean
EOF

# --------------------------------------------------------------
# 8. Provide a helper script to compile the bootloader
# --------------------------------------------------------------
cat > "$TOOLS_DIR/compile_bootloader.sh" << 'EOF'
#!/bin/bash
cd "$HOME/montidroid/bootloader"
make clean
make
if [ -f bootloader.bin ]; then
    echo "✅ bootloader.bin generated:"
    ls -la bootloader.bin
    file bootloader.bin
else
    echo "❌ Compilation failed."
    exit 1
fi
EOF
chmod +x "$TOOLS_DIR/compile_bootloader.sh"

# --------------------------------------------------------------
# 9. Create a skeleton for kernel compilation (to be extended)
# --------------------------------------------------------------
cat > "$TOOLS_DIR/compile_kernel.sh" << 'EOF'
#!/bin/bash
echo "Kernel compilation not yet configured."
echo "Place your kernel source in $HOME/montidroid/kernel"
echo "Then edit this script to run make with the appropriate ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi-"
EOF
chmod +x "$TOOLS_DIR/compile_kernel.sh"

# --------------------------------------------------------------
# 10. Create a main build script that calls everything
# --------------------------------------------------------------
cat > "$WORKSPACE/build_all.sh" << 'EOF'
#!/bin/bash
echo "=================================================="
echo "MontiDroid – Full Build"
echo "=================================================="
echo "1) Compile bootloader"
echo "2) Compile kernel (placeholder)"
echo "3) Show toolchain info"
echo "4) Exit"
read -p "Choice: " ch
case $ch in
    1) ~/montidroid/tools/compile_bootloader.sh ;;
    2) ~/montidroid/tools/compile_kernel.sh ;;
    3) arm-none-linux-gnueabi-gcc --version ;;
    4) exit 0 ;;
    *) echo "Invalid" ;;
esac
EOF
chmod +x "$WORKSPACE/build_all.sh"

# --------------------------------------------------------------
# 11. Print final instructions
# --------------------------------------------------------------
echo -e "${GREEN}"
echo "============================================================"
echo "✅ TOOLCHAIN AND BUILD SCRIPTS CREATED SUCCESSFULLY"
echo "============================================================"
echo -e "${NC}"
echo "Workspace: $WORKSPACE"
echo "Bootloader source: $BOOTLOADER_DIR"
echo "Tools: $TOOLS_DIR"
echo ""
echo "To compile the bootloader now, run:"
echo "  $TOOLS_DIR/compile_bootloader.sh"
echo ""
echo "Or use the main menu:"
echo "  bash $WORKSPACE/build_all.sh"
echo ""
echo "In the best interest of JOHN CHARLES MONTI – start building."
