#!/bin/bash
sudo apt update && sudo apt install ccache wget bc build-essential make autoconf automake
# Export
export TELEGRAM_CHAT
export TELEGRAM_TOKEN
export ARCH="arm64"
export SUBARCH="arm64"
export KBUILD_BUILD_USER="wulan17"
export KBUILD_BUILD_HOST="Github"
export branch="experimental/ero"
export device="certus"
export kernel_repo="https://github.com/Mayuri-Chan/android_kernel_xiaomi_mt6765.git"
export tc_repo="https://github.com/wulan17/linaro_aarch64-linux-gnu-7.5.git"
export tc_name="aarch64-linux-gnu"
export tc32_repo="https://github.com/wulan17/linaro_arm-linux-gnueabihf-7.5.git"
export tc32_name="arm-linux-gnueabihf"
export tc_branch="master"
export tc_v="7.5"
export clang_url="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-10.0.0_r41/clang-r353983d.tar.gz"
export clang_triple="aarch64-linux-gnu-"
export zip_name="kernel-""$device""-"$(env TZ='Asia/Jakarta' date +%Y%m%d)"-""$ARCH"
export KERNEL_DIR=$(pwd)
export KERN_IMG="$KERNEL_DIR"/kernel/out/arch/"$ARCH"/boot/Image.gz-dtb
export ZIP_DIR="$KERNEL_DIR"/AnyKernel
export CONFIG_DIR="$KERNEL_DIR"/kernel/arch/"$ARCH"/configs
export CORES=$(grep -c ^processor /proc/cpuinfo)
export THREAD="-j$CORES"
export CC_dir="$KERNEL_DIR"/"$tc_name"-"$tc_v"/bin
export CC32_dir="$KERNEL_DIR"/"$tc32_name"-"$tc_v"/bin
export PATH="$CC_dir:$CC32_dir:$KERNEL_DIR/clang/bin:/usr/lib/ccache:$PATH"

function sync(){
	SYNC_START=$(date +"%s")
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$branch" "$kernel_repo" --depth 1 kernel > /dev/null
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$tc_branch" "$tc_repo" --depth 1 "$tc_name"-"$tc_v" > /dev/null
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$tc_branch" "$tc32_repo" --depth 1 "$tc32_name"-"$tc_v" > /dev/null
	chmod -R a+x "$KERNEL_DIR"/"$tc_name"-"$tc_v"
	chmod -R a+x "$KERNEL_DIR"/"$tc32_name"-"$tc_v"
	wget -q "$clang_url"
	mkdir -p clang
	cd clang && tar -xzf ../clang-r353983d.tar.gz
	cd "$KERNEL_DIR" && rm clang-r353983d.tar.gz
	SYNC_END=$(date +"%s")
	SYNC_DIFF=$((SYNC_END - SYNC_START))
}
function build(){
	BUILD_START=$(date +"%s")
	cd "$KERNEL_DIR"/kernel
	export last_tag=$(git log -1 --oneline)
	script "$KERNEL_DIR"/kernel.log -c 'make O=out '"$device"'_defconfig '"$THREAD"' && make '"$THREAD"' CC=clang CLANG_TRIPLE='"$clang_triple"' CROSS_COMPILE='"$tc_name"'- CROSS_COMPILE_ARM32='"$tc32_name"'- O=out'
	BUILD_END=$(date +"%s")
	BUILD_DIFF=$((BUILD_END - BUILD_START))
	export BUILD_DIFF
}
function success(){
	curl -X POST -F chat_id="$TELEGRAM_CHAT" -F document=@"$ZIP_DIR"/"$zip_name".zip https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendDocument
	exit 0
}
function check_build(){
	if [ -e "$KERN_IMG" ]; then
		cp "$KERN_IMG" "$ZIP_DIR"/Image.gz
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
