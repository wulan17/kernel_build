#!/bin/bash
source config.sh
# Export
export ARCH="arm"
export SUBARCH="arm"
CROSS_COMPILE="$KERNEL_DIR"/"$tc32_name"-"$tc_v"/bin/"$tc32_name"-
export CROSS_COMPILE
export KERN_IMG="$KERNEL_DIR"/kernel/out/arch/"$ARCH"/boot/zImage-dtb
export zip_name32="0.6-kernel-""$device""-"$(env TZ='Asia/Jakarta' date +%Y%m%d)"-""$ARCH"

function build32(){
	echo "Building arm32 kernel..."
	cd "$KERNEL_DIR"/kernel
	script "$KERNEL_DIR"/kernel32.log -c 'make O=out '"$device"'_defconfig '"$THREAD"' && make '"$THREAD"' O=out'
}
function check_build32(){
	if [ -e "$KERN_IMG" ]; then
		cp "$KERN_IMG" "$ZIP_DIR"/zImage
		cd "$ZIP_DIR" && zip -r "$zip_name32".zip ./*
		rm "$ZIP_DIR"/zImage
		rm -rf out
		curl -X POST -F chat_id="$TELEGRAM_CHAT" -F document=@"$ZIP_DIR"/"$zip_name32".zip https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendDocument
		echo "Done."
	else
		#failed
		echo "Failed."
		curl -X POST -F chat_id="$TELEGRAM_CHAT" -F document=@"$KERNEL_DIR"/kernel32.log https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendDocument
		exit 1
	fi
}
build32
check_build32
