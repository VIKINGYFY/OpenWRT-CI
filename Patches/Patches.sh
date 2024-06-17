#!/bin/bash

#加回部分设备支持
if [[ $WRT_URL == *"immortalwrt"* && $WRT_TARGET == "Mediatek" ]]; then
	mv -f ./Patches/mediatek/*.dts ./wrt/target/linux/mediatek/dts/

	patch -R -p1 -d ./wrt < ./Patches/mediatek/mtk*.patch

	echo "$WRT_TARGET patch has been installed!"
fi

if [[ $WRT_URL == *"lede"* && $WRT_TARGET == "Qualcom" ]]; then
	mv -f ./Patches/qualcom/*.dts ./wrt/target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/
	mv -f ./Patches/qualcom/*.ipq6018 ./wrt/package/firmware/ipq-wifi/src/
	mv -f ./Patches/qualcom/0920*.patch ./wrt/target/linux/qualcommax/patches-6.1/

	patch -R -p1 -d ./wrt < ./Patches/qualcom/qcam*.patch

	echo "$WRT_TARGET patch has been installed!"
fi

if [[ $WRT_URL == *"openwrt-ipq60xx"* && $WRT_TARGET == "Qualcom" ]]; then
	sed -i "s|\(src-git packages\).*|\1 https://github.com/immortalwrt/packages.git|g" ./wrt/feeds.conf.default
	sed -i "s|\(src-git luci\).*|\1 https://github.com/immortalwrt/luci.git|g" ./wrt/feeds.conf.default

	echo "$WRT_TARGET patch has been installed!"
fi
