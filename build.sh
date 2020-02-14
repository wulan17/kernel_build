sudo apt update > /dev/null
sudo apt install -y liblz4-dev openjdk-8-jdk android-tools-adb bc bison build-essential curl flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev libesd0-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc yasm zip zlib1g-dev ccache > /dev/null

sudo timedatectl set-timezone Asia/Jakarta

# Export
export TELEGRAM_TOKEN
export TELEGRAM_CHAT
export ARCH=arm
export SUBARCH=arm
export PATH=/usr/lib/ccache:$PATH
export KBUILD_BUILD_USER=wulan17
export KBUILD_BUILD_HOST=Github
export branch=staging/pie
export device=cactus
export LOCALVERSION="-wulan17"
export kernel_repo=https://github.com/wulan17/android_kernel_xiaomi_mt6765
export tc_repo=https://github.com/wulan17/linaro_arm-linux-gnueabihf-7.5.git
export tc_name=arm-linux-gnueabihf
export tc_v=7.5
export zip_name="kernel-"$device"-EXPERIMENTAL-"$(env TZ='Asia/Jakarta' date +%Y%m%d)""
export KERNEL_DIR=$(pwd)
export KERN_IMG=$KERNEL_DIR/kernel/out/arch/$ARCH/boot/zImage-dtb
export ZIP_DIR=$KERNEL_DIR/AnyKernel
export CONFIG_DIR=$KERNEL_DIR/kernel/arch/$ARCH/configs
export CORES=$(grep -c ^processor /proc/cpuinfo)
export THREAD="-j$CORES"
export CROSS_COMPILE+="ccache "
export CROSS_COMPILE+="$KERNEL_DIR/$tc_name-$tc_v/bin/$tc_name-"
export CROSS_COMPILE

# Main Environment
SYNC_START=$(date +"%s")
curl -v -F "chat_id=$TELEGRAM_CHAT" -F "parse_mode=html" -F text="Sync Started" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage
cd $KERNEL_DIR && git clone -b $branch $kernel_repo --depth 1 kernel
cd $KERNEL_DIR && git clone $tc_repo $tc_name-$tc_v
chmod -R a+x $KERNEL_DIR/$tc_name-$tc_v
SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
curl -v -F "chat_id=$TELEGRAM_CHAT" -F "parse_mode=html" -F text="Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage

BUILD_START=$(date +"%s")
cd $KERNEL_DIR/kernel
export last_tag="<a href='"$kernel_repo"/commit/"$(git log -1 --format=%H)"'>"$(git log -1 --format=%h)"</a>: "$(git log -1 --format=%s)
curl -v -F "chat_id=$TELEGRAM_CHAT" -F "parse_mode=html" -F text="#EXPERIMENTAL
Build Started
Dev : ""$KBUILD_BUILD_USER""
Product : Kernel
Device : #""$device""
Branch : ""$branch""
Host : ""$KBUILD_BUILD_HOST""
Commit : ""$last_tag""
Compiler : 
""$(${CROSS_COMPILE}gcc --version | head -n 1)""
Date : ""$(env TZ=Asia/Jakarta date)""" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage
make  O=out $(echo $device)_defconfig $THREAD
make -j4 O=out
BUILD_END=$(date +"%s")
BUILD_DIFF=$((BUILD_END - BUILD_START))
if [ -e "$KERN_IMG" ]; then
	cp $KERN_IMG $ZIP_DIR
	cd $ZIP_DIR
	mv zImage-dtb zImage
	zip -r $zip_name.zip ./*

	curl -v -F "chat_id=$TELEGRAM_CHAT" -F document=@$ZIP_DIR/$zip_name.zip -F "parse_mode=html" -F caption="#EXPERIMENTAL
	Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds
	Dev : ""$KBUILD_BUILD_USER""
	Product : Kernel
	Device : #""$device""
	Branch : ""$branch""
	Host : ""$KBUILD_BUILD_HOST""
	Commit : ""$last_tag""
	Compiler : ""$(${CROSS_COMPILE}gcc --version | head -n 1)""
	Date : ""$(env TZ=Asia/Jakarta date)""" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument
else
	curl -v -F "chat_id=$TELEGRAM_CHAT" -F "parse_mode=html" -F text="Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage
fi
