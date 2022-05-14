# Export
export TELEGRAM_CHAT
export TELEGRAM_TOKEN
export KBUILD_BUILD_USER="wulan17"
export KBUILD_BUILD_HOST="Github"
export branch="experimental/ero-06"
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
export KERNEL_DIR="/home/runner/work/kernel_build/"
export ZIP_DIR="$KERNEL_DIR"/AnyKernel
export CONFIG_DIR="$KERNEL_DIR"/kernel/arch/"$ARCH"/configs
export CORES=$(grep -c ^processor /proc/cpuinfo)
export THREAD="-j$CORES"
export PATH="$CC_dir:$CC32_dir:$KERNEL_DIR/clang/bin:/usr/lib/ccache:$PATH"
