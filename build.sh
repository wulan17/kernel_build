#!/bin/bash
sudo apt update && sudo apt install ccache wget bc build-essential make autoconf automake
# Export
export TELEGRAM_TOKEN
export TELEGRAM_CHAT
export sticker="CAACAgUAAxkBAAIL2l6XZzZMONmyzN78ZXKauBmF7B59AAIIAQACai2MM14xGHW1mrNAGAQ" 
export ARCH="arm64"
export SUBARCH="arm64"
export KBUILD_BUILD_USER="wulan17"
export KBUILD_BUILD_HOST="Github"
export branch="pie"
export device="trinket"
export codename="RMX1911"
export LOCALVERSION="-wulan17"
export kernel_repo="https://github.com/Realme-RMX1911-RMX2030/kernel_realme_RMX1911.git"
export tc_repo="https://github.com/wulan17/linaro_aarch64-linux-gnu-7.5.git"
export tc_name="aarch64-linux-gnu"
export tc32_repo="https://github.com/wulan17/linaro_arm-linux-gnueabihf-7.5.git"
export tc32_name="arm-linux-gnueabihf"
export tc_branch="master"
export tc_v="7.5"
export clang_url="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-9.0.0_r55/clang-4691093.tar.gz"
export clang_triple="aarch64-linux-gnu-"
export zip_name="kernel-""$codename""-"$(env TZ='Asia/Jakarta' date +%Y%m%d)""
export KERNEL_DIR=$(pwd)
export KERN_IMG="$KERNEL_DIR"/kernel/out/arch/"$ARCH"/boot/Image.gz-dtb
export ZIP_DIR="$KERNEL_DIR"/AnyKernel
export CONFIG_DIR="$KERNEL_DIR"/kernel/arch/"$ARCH"/configs
export CORES=$(grep -c ^processor /proc/cpuinfo)
export THREAD="-j$CORES"
#CROSS_COMPILE+="ccache "
#CROSS_COMPILE+="$KERNEL_DIR"/"$tc_name"-"$tc_v"/bin/"$tc_name"-
#export CROSS_COMPILE
CROSS_COMPILE_ARM32+="ccache "
CROSS_COMPILE_ARM32+="$KERNEL_DIR"/"$tc32_name"-"$tc_v"/bin/"$tc32_name"-
export CROSS_COMPILE_ARM32
export CC_dir="$KERNEL_DIR"/"$tc_name"-"$tc_v"/bin
export PATH="$CC_dir:$KERNEL_DIR/clang/bin:/usr/lib/ccache:$PATH"

function sync(){
	SYNC_START=$(date +"%s")
	curl -s -v -F "chat_id=$TELEGRAM_CHAT" -F "parse_mode=html" -F text="Sync Started" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$branch" "$kernel_repo" --depth 1 kernel > /dev/null
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$tc_branch" "$tc_repo" --depth 1 "$tc_name"-"$tc_v" > /dev/null
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$tc_branch" "$tc32_repo" --depth 1 "$tc32_name"-"$tc_v" > /dev/null
	wget -q "$clang_url"
	mkdir -p clang
	cd clang && tar -xzf ../clang-4691093.tar.gz
	cd "$KERNEL_DIR" && rm clang-4691093.tar.gz
	chmod -R a+x "$KERNEL_DIR"/"$tc_name"-"$tc_v"
	SYNC_END=$(date +"%s")
	SYNC_DIFF=$((SYNC_END - SYNC_START))
	curl -s -v -F "chat_id=$TELEGRAM_CHAT" -F "parse_mode=html" -F text="Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage > /dev/null
}
function build(){
	BUILD_START=$(date +"%s")
	cd "$KERNEL_DIR"/kernel
	export last_tag=$(git log -1 --oneline)
	curl -s -v -F "chat_id=$TELEGRAM_CHAT" -F "parse_mode=html" -F text="Build Started" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage > /dev/null
	script "$KERNEL_DIR"/kernel.log -c 'make O=out vendor/'"$device"'_defconfig '"$THREAD"' && make '"$THREAD"' CC=clang CLANG_TRIPLE='"$clang_triple"' CROSS_COMPILE='"$tc_name"'- O=out'
	BUILD_END=$(date +"%s")
	BUILD_DIFF=$((BUILD_END - BUILD_START))
	export BUILD_DIFF
}
function success(){
	curl -s -v -F "chat_id=$TELEGRAM_CHAT" -F document=@"$ZIP_DIR"/"$zip_name".zip -F "parse_mode=html" -F caption="Build completed successfully in $((BUILD_DIFF / 60)):$((BUILD_DIFF % 60))
	Dev : ""$KBUILD_BUILD_USER""
	Product : Kernel
	Device : #""$device"" (""$codename"")
	Branch : ""$branch""
	Host : ""$KBUILD_BUILD_HOST""
	Commit : ""$last_tag""
	Compiler : ""$(${tc_name}-gcc --version | head -n 1)""
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
	curl -s -F "chat_id=$TELEGRAM_CHAT" -F "sticker=$sticker" https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendSticker > /dev/null
	sync
	build
	check_build
}

main
