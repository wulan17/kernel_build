#!/bin/bash
sudo apt update && sudo apt install ccache wget bc build-essential make autoconf automake
# Export
export CI_SECRET
export ARCH="arm"
export SUBARCH="arm"
export KBUILD_BUILD_USER="wulan17"
export KBUILD_BUILD_HOST="Github"
export branch="dev/10-exfat"
export device="certus"
#export LOCALVERSION="-wulan17"
export kernel_repo="https://github.com/kbt69/android_kernel_xiaomi_mt6765.git"
export tc_repo="https://github.com/wulan17/linaro_arm-linux-gnueabihf-7.5.git"
export tc_name="arm-linux-gnueabihf"
export tc_branch="master"
export tc_v="7.5"
export zip_name="kernel-""$device""-"$(env TZ='Asia/Jakarta' date +%Y%m%d)""
export KERNEL_DIR=$(pwd)
export KERN_IMG="$KERNEL_DIR"/kernel/out/arch/"$ARCH"/boot/zImage-dtb
export ZIP_DIR="$KERNEL_DIR"/AnyKernel
export CONFIG_DIR="$KERNEL_DIR"/kernel/arch/"$ARCH"/configs
export CORES=$(grep -c ^processor /proc/cpuinfo)
export THREAD="-j$CORES"
#CROSS_COMPILE+="ccache "
CROSS_COMPILE="$KERNEL_DIR"/"$tc_name"-"$tc_v"/bin/"$tc_name"-
export CROSS_COMPILE
export CC_dir="$KERNEL_DIR"/"$tc_name"-"$tc_v"/bin
export PATH="$CC_dir:/usr/lib/ccache:$PATH"

function sync(){
	SYNC_START=$(date +"%s")
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$branch" "$kernel_repo" --depth 1 kernel > /dev/null
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$tc_branch" "$tc_repo" --depth 1 "$tc_name"-"$tc_v" > /dev/null
	chmod -R a+x "$KERNEL_DIR"/"$tc_name"-"$tc_v"
	SYNC_END=$(date +"%s")
	SYNC_DIFF=$((SYNC_END - SYNC_START))
}
function build(){
	BUILD_START=$(date +"%s")
	cd "$KERNEL_DIR"/kernel
	export last_tag=$(git log -1 --oneline)
	script "$KERNEL_DIR"/kernel.log -c 'make O=out '"$device"'_defconfig '"$THREAD"' && make '"$THREAD"' O=out'
	BUILD_END=$(date +"%s")
	BUILD_DIFF=$((BUILD_END - BUILD_START))
	export BUILD_DIFF
}
function success(){
	curl -X POST -F secret="$CI_SECRET" -F document=@"$ZIP_DIR"/"$zip_name".zip http://ci.wulan17.my.id/gd
	exit 0
}
function check_build(){
	if [ -e "$KERN_IMG" ]; then
		cp "$KERN_IMG" "$ZIP_DIR"/zImage
		cd "$ZIP_DIR"
		zip -r "$zip_name".zip ./*
		success
	else
		#failed
		exit 1
	fi
}
function main(){
	sync
	build
	check_build
}

main
