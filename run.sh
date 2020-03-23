#!/bin/bash
sudo apt update && sudo apt install ccache tar xz-utils
# Export
export TELEGRAM_TOKEN
export TELEGRAM_CHAT
export ARCH="arm"
export SUBARCH="arm"
export PATH="/usr/lib/ccache:$PATH"
export KBUILD_BUILD_USER="wulan17"
export KBUILD_BUILD_HOST="Github"
export branch="dev/pie"
export device="cereus"
export LOCALVERSION="-wulan17"
export kernel_repo="https://github.com/wulan17/android_kernel_xiaomi_mt6765.git"
#export tc_repo="https://wulan17@bitbucket.org/wulan17/arm-none-linux-gnueabihf-9.2.git"
export tc_url="https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf.tar.xz?revision=fed31ee5-2ed7-40c8-9e0e-474299a3c4ac&la=en&hash=76DAF56606E7CB66CC5B5B33D8FB90D9F24C9D20"
export tc_fname="gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf"
export tc_name="arm-none-linux-gnueabihf"
#export tc_v="9.2"
export zip_name="kernel-""$device""-"$(env TZ='Asia/Jakarta' date +%Y%m%d)""
export KERNEL_DIR=$(pwd)
export KERN_IMG="$KERNEL_DIR"/kernel/out/arch/"$ARCH"/boot/zImage-dtb
export ZIP_DIR="$KERNEL_DIR"/AnyKernel
export CONFIG_DIR="$KERNEL_DIR"/kernel/arch/"$ARCH"/configs
export CORES=$(grep -c ^processor /proc/cpuinfo)
export THREAD="-j$CORES"
CROSS_COMPILE+="ccache "
CROSS_COMPILE+="$KERNEL_DIR"/"$tc_fname"/bin/"$tc_name"-
export CROSS_COMPILE

bash build.sh > "$KERNEL_DIR"/kernel.log