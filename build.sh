#!/bin/bash
sudo apt update && sudo apt install ccache
# Export
export TELEGRAM_TOKEN
export TELEGRAM_CHAT
export sticker="CAACAgUAAxkBAAIL2l6XZzZMONmyzN78ZXKauBmF7B59AAIIAQACai2MM14xGHW1mrNAGAQ" 
export ARCH="arm64"
export SUBARCH="arm64"
export PATH="/usr/lib/ccache:$PATH"
export KBUILD_BUILD_USER="wulan17"
export KBUILD_BUILD_HOST="Github"
export branch="pie"
export device="trinket-perf"
export LOCALVERSION="-wulan17"
export kernel_repo="https://github.com/wulan17/android_kernel_realme_rmx2030.git"
export tc_repo="https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9"
export tc_name="aarch64-linux-android"
export tc_branch="android-9.0.0_r34"
export tc_v="4.9"
export zip_name="kernel-""$device""-"$(env TZ='Asia/Jakarta' date +%Y%m%d)""
export KERNEL_DIR=$(pwd)
export KERN_IMG="$KERNEL_DIR"/kernel/out/arch/"$ARCH"/boot/Image.gz-dtb
export ZIP_DIR="$KERNEL_DIR"/AnyKernel
export CONFIG_DIR="$KERNEL_DIR"/kernel/arch/"$ARCH"/configs
export CORES=$(grep -c ^processor /proc/cpuinfo)
export THREAD="-j$CORES"
CROSS_COMPILE+="ccache "
CROSS_COMPILE+="$KERNEL_DIR"/"$tc_name"-"$tc_v"/bin/"$tc_name-"
export CROSS_COMPILE

function sync(){
	SYNC_START=$(date +"%s")
	curl -s -v -F "chat_id=$TELEGRAM_CHAT" -F "parse_mode=html" -F text="Sync Started" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$branch" "$kernel_repo" --depth 1 kernel > /dev/null
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$tc_branch" "$tc_repo" "$tc_name"-"$tc_v" > /dev/null
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
	script "$KERNEL_DIR"/kernel.log -c 'make O=out vendor/'"$device"'_defconfig '"$THREAD"' && make '"$THREAD"' O=out'
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
		cp "$KERN_IMG" "$ZIP_DIR"/zImage
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
