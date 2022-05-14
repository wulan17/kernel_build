#!/bin/bash
source config.sh
sudo apt update && sudo apt install ccache wget bc build-essential make autoconf automake python2
function sync(){
	echo 'Sync start...'
	SYNC_START=$(date +"%s")
	cd "$KERNEL_DIR" && git clone "$THREAD" -b "$branch" "$kernel_repo" --depth 1 kernel
	cd "$KERNEL_DIR" && git clone "$THREAD" -b "$tc_branch" "$tc_repo" --depth 1 "$tc_name"-"$tc_v"
	cd "$KERNEL_DIR" && git clone "$THREAD" -b "$tc_branch" "$tc32_repo" --depth 1 "$tc32_name"-"$tc_v"
	chmod -R a+x "$KERNEL_DIR"/"$tc_name"-"$tc_v"
	chmod -R a+x "$KERNEL_DIR"/"$tc32_name"-"$tc_v"
	wget -q "$clang_url"
	mkdir -p clang
	cd clang && tar -xzf ../clang-r353983d.tar.gz
	cd "$KERNEL_DIR" && rm clang-r353983d.tar.gz
	SYNC_END=$(date +"%s")
	SYNC_DIFF=$((SYNC_END - SYNC_START))
	echo 'Sync done in'"$SYNC_DIFF"
}
sync
