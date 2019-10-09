export TELEGRAM_TOKEN
export TELEGRAM_CHAT
export zip_name="kernel-cactus-"$(env TZ='Asia/Jakarta' date +%Y%m%d)""
sudo apt update
sudo apt install -y liblz4-dev openjdk-8-jdk android-tools-adb bc bison build-essential curl flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev libesd0-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc yasm zip zlib1g-dev

# Main Environment
KERNEL_DIR=$(pdw)
KERN_IMG=$KERNEL_DIR/kernel/out/arch/arm/boot/zImage-dtb
ZIP_DIR=$KERNEL_DIR/AnyKernel
CONFIG_DIR=$KERNEL_DIR/kernel/arch/arm/configs
CONFIG=cactus_defconfig
CORES=$(grep -c ^processor /proc/cpuinfo)
THREAD="-j$CORES"
CROSS_COMPILE+="ccache "
CROSS_COMPILE+="$KERNEL_DIR/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
chmod a+x $KERNEL_DIR/telegram
SYNC_START=$(date +"%s")
$KERNEL_DIR/telegram -M "Sync Started"
cd $KERNEL_DIR && git clone -b pie https://github.com/wulan17/android_kernel_xiaomi_cactus.git --depth 1 kernel
echo -e "\n(i) Cloning toolcahins if folder not exist..."
cd $KERNEL_DIR && git clone https://github.com/wulan17/prebuilts_gcc_linux-x86_arm-linux-androideabi-4.9.git arm-linux-androideabi-4.9
chmod a+x $KERNEL_DIR/arm-linux-androideabi-4.9/bin/*
chmod a+x $KERNEL_DIR/arm-linux-androideabi-4.9/libexec/gcc/arm-linux-androideabi/4.9.x/*
chmod a+x $KERNEL_DIR/arm-linux-androideabi-4.9/libexec/gcc/arm-linux-androideabi/4.9.x/plugin/*
SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
$KERNEL_DIR/telegram -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"

#cd $HOME/kernel && wget https://github.com/wulan17/android_kernel_xiaomi_cactus/commit/63623ef9ea9260810d10c2422d4548470a29f304.patch
#cd $HOME/kernel && git am < 63623ef9ea9260810d10c2422d4548470a29f304.patch
BUILD_START=$(date +"%s")
cd $KERNEL_DIR/kernel
$KERNEL_DIR/telegram -M "Build Start
Dev : wulan17
Product : Kernel
Device : #cactus
Branch : Pie
Compiler : ""$(gcc --version)""
Compiler : ""$(${CROSS_COMPILE}gcc --version | head -n 1)""
Date : ""$(env TZ=Asia/Jakarta date)"""
# Export
export ARCH=arm
export SUBARCH=arm
export PATH=/usr/lib/ccache:$PATH
export CROSS_COMPILE
export KBUILD_BUILD_USER=wulan17
export KBUILD_BUILD_HOST=Github
make  O=out $CONFIG $THREAD
make -j4 O=out

cp $KERN_IMG $ZIP_DIR
cd $ZIP_DIR
mv zImage-dtb zImage
BUILD_END=$(date +"%s")
BUILD_DIFF=$((BUILD_END - BUILD_START))
zip -r $zip_name.zip ./*

curl -v -F "chat_id=$TELEGRAM_CHAT" -F document=@$ZIP_DIR/$zip_name.zip -F "parse_mode=html" -F caption="Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds
Dev : wulan17
Product : Kernel
Device : #cactus
Branch : Pie
Compiler : ""$(gcc --version)""
Compiler : ""$(${CROSS_COMPILE}gcc --version | head -n 1)""
Date : ""$(env TZ=Asia/Jakarta date)""" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument