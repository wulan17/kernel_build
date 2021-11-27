#!/bin/bash
sudo apt update && sudo apt install ccache wget bc build-essential make autoconf automake
# Export
export TELEGRAM_TOKEN
export TELEGRAM_CHAT="-1001679439421"
export sticker="CAACAgUAAxkBAAIL2l6XZzZMONmyzN78ZXKauBmF7B59AAIIAQACai2MM14xGHW1mrNAGAQ" 
export ARCH="arm64"
export SUBARCH="arm64"
export KBUILD_BUILD_USER="wulan17"
export KBUILD_BUILD_HOST="Github"
export branch="10-test2"
export device="angelica"
export LOCALVERSION="-TsukiNoHikari"
export kernel_repo="https://github.com/kbt69/android_kernel_xiaomi_mt6765g.git"
export tc_repo="https://github.com/wulan17/linaro_aarch64-linux-gnu-7.5.git"
export tc_name="aarch64-linux-gnu"
export tc32_repo="https://github.com/wulan17/linaro_arm-linux-gnueabihf-7.5.git"
export tc32_name="arm-linux-gnueabihf"
export tc_branch="master"
export tc_v="7.5"
export clang_url="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-10.0.0_r41/clang-r353983d.tar.gz"
export clang_triple="aarch64-linux-gnu-"
export random=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13)
export zip_name="kernel-""$device""-"$(env TZ='Asia/Jakarta' date +%Y%m%d)"-""$random"
export KERNEL_DIR=$(pwd)
export KERN_IMG="$KERNEL_DIR"/kernel/out/arch/"$ARCH"/boot/Image.gz-dtb
export ZIP_DIR="$KERNEL_DIR"/AnyKernel
export CONFIG_DIR="$KERNEL_DIR"/kernel/arch/"$ARCH"/configs
export CORES=$(grep -c ^processor /proc/cpuinfo)
export THREAD="-j$CORES"
#CROSS_COMPILE+="ccache "
#CROSS_COMPILE+="$KERNEL_DIR"/"$tc_name"-"$tc_v"/bin/"$tc_name"-
#export CROSS_COMPILE
#CROSS_COMPILE_ARM32+="ccache "
#CROSS_COMPILE_ARM32+="$KERNEL_DIR"/"$tc32_name"-"$tc_v"/bin/"$tc32_name"-
#export CROSS_COMPILE_ARM32
export CC_dir="$KERNEL_DIR"/"$tc_name"-"$tc_v"/bin
export CC32_dir="$KERNEL_DIR"/"$tc32_name"-"$tc_v"/bin
export PATH="$CC_dir:$CC32_dir:$KERNEL_DIR/clang/bin:/usr/lib/ccache:$PATH"

function sync(){
	SYNC_START=$(date +"%s")
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$branch" "$kernel_repo" --depth 1 kernel > /dev/null
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$tc_branch" "$tc_repo" --depth 1 "$tc_name"-"$tc_v" > /dev/null
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$tc_branch" "$tc32_repo" --depth 1 "$tc32_name"-"$tc_v" > /dev/null
	wget -q "$clang_url"
	mkdir -p clang
	cd clang && tar -xzf ../clang-r353983d.tar.gz
	cd "$KERNEL_DIR" && rm clang-r353983d.tar.gz
	chmod -R a+x "$KERNEL_DIR"/"$tc_name"-"$tc_v"
	SYNC_END=$(date +"%s")
	SYNC_DIFF=$((SYNC_END - SYNC_START))
}
function build(){
	BUILD_START=$(date +"%s")
	curl -v -F "chat_id=$TELEGRAM_CHAT" -F "parse_mode=html" -F text="Build Started
	<a href='https://github.com/wulan17/kernel_build/actions/runs/""$GITHUB_RUN_ID""'>See progress</a>" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage > /dev/null
	cd "$KERNEL_DIR"/kernel
	export last_tag=$(git log -1 --oneline)
	script "$KERNEL_DIR"/kernel.log -c 'make O=out '"$device"'_defconfig '"$THREAD"' && make '"$THREAD"' CC=clang CLANG_TRIPLE='"$clang_triple"' CROSS_COMPILE='"$tc_name"'- CROSS_COMPILE_ARM32='"$tc32_name"'- O=out'
	BUILD_END=$(date +"%s")
	BUILD_DIFF=$((BUILD_END - BUILD_START))
	export BUILD_DIFF
}
function success(){
	curl -s -v -F "chat_id=$TELEGRAM_CHAT" -F document=@"$ZIP_DIR"/"$zip_name".zip -F "parse_mode=html" -F caption="Build completed successfully in $((BUILD_DIFF / 60)):$((BUILD_DIFF % 60))
	Dev : ""$KBUILD_BUILD_USER""
	Product : Kernel
	Device : #""$device""
	Branch : ""$branch""
	Host : ""$KBUILD_BUILD_HOST""
	Commit : ""$last_tag""
	Compiler : ""$(${CROSS_COMPILE}gcc --version | head -n 1)""
	Date : ""$(env TZ=Asia/Jakarta date)""" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument

	curl -s -v -F "chat_id=$TELEGRAM_CHAT" -F document=@"$KERNEL_DIR"/kernel.log https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument > /dev/null
	exit 0
}
function failed(){
	curl -s -v -F "chat_id=$TELEGRAM_CHAT" -F document=@"$KERNEL_DIR"/kernel.log -F "parse_mode=html" -F "caption=Build failed in $((BUILD_DIFF / 60)):$((BUILD_DIFF % 60))" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument > /dev/null
	exit 1
}
function check_build(){
	if [ -e "$KERN_IMG" ]; then
		cp "$KERN_IMG" "$ZIP_DIR"/Image.gz
		cd "$ZIP_DIR"
		zip -r "$zip_name".zip ./*
		success
	else
		failed
	fi
}
function main(){
	sync
	build
	check_build
}

main
