#!/bin/bash

if [[ $WRT_URL == *"immortalwrt"* && $WRT_TARGET == "Mediatek" ]]; then
	mv -f ./Patches/mediatek/*.dts ./wrt/target/linux/mediatek/dts/
	patch -R -p1 -d ./wrt < ./Patches/mediatek/mtk*.patch

	echo "$WRT_TARGET patch has been installed!"
fi

if [[ $WRT_URL == *"lede"* ]]; then
	sed -i "/#src/d" ./wrt/feeds.conf.default
	sed -i "s|\(src-git luci\).*|\1 https://github.com/coolsnowwolf/luci.git;openwrt-23.05|g" ./wrt/feeds.conf.default

	echo "$WRT_URL patch has been installed!"
fi
