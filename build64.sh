#!/bin/bash
source config.sh
# Export
export ARCH="arm64"
export SUBARCH="arm64"
export CC_dir="$KERNEL_DIR"/"$tc_name"-"$tc_v"/bin
export CC32_dir="$KERNEL_DIR"/"$tc32_name"-"$tc_v"/bin
export KERN_IMG="$KERNEL_DIR"/kernel/out/arch/"$ARCH"/boot/Image.gz-dtb
export zip_name64="0.6-kernel-""$device""-"$(env TZ='Asia/Jakarta' date +%Y%m%d)"-""$ARCH"

function build64(){
	echo "Building arm64 kernel..."
	cd "$KERNEL_DIR"/kernel
	script "$KERNEL_DIR"/kernel64.log -c 'make O=out '"$device"'_defconfig '"$THREAD"' && make '"$THREAD"' CC=clang CLANG_TRIPLE='"$clang_triple"' CROSS_COMPILE='"$tc_name"'- CROSS_COMPILE_ARM32='"$tc32_name"'- O=out'
}
function check_build64(){
	if [ -e "$KERN_IMG" ]; then
		cp "$KERN_IMG" "$ZIP_DIR"/Image.gz
		cd "$ZIP_DIR" && zip -r "$zip_name64".zip ./*
		rm "$ZIP_DIR"/Image.gz
		rm -rf out
		curl -X POST -F chat_id="$TELEGRAM_CHAT" -F document=@"$ZIP_DIR"/"$zip_name64".zip https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendDocument
		echo "Done."
	else
		#failed
		echo "Failed."
		curl -X POST -F chat_id="$TELEGRAM_CHAT" -F document=@"$KERNEL_DIR"/kernel64.log https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendDocument
		exit 1
	fi
}
build64
check_build64
