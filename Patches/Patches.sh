#!/bin/bash

if [[ $WRT_URL == *"immortalwrt"* && $WRT_TARGET == "Mediatek" ]]; then
	mv -f ./Patches/mediatek/*.dts ./wrt/target/linux/mediatek/dts/

	patch -R -p1 -d ./wrt < ./Patches/mediatek/mtk*.patch

	echo "$WRT_TARGET patch has been installed!"
fi

if [[ $WRT_URL == *"openwrt-6.x"* && $WRT_TARGET == "Qualcom" ]]; then
	sed -i 's/nss-packages.git/nss-packages.git;NSS-12.4-K6.x/g' ./wrt/feeds.conf.default

	echo "$WRT_TARGET patch has been installed!"
fi
