#!/bin/bash

#加回部分设备支持
if [[ $WRT_URL == *"immortalwrt"* && $WRT_TARGET == "Mediatek" ]]; then
	cp -rf ./Patches/mediatek/*.dts ./wrt/target/linux/mediatek/dts/
	patch -R -p1 -d ./wrt < ./Patches/mediatek/*.patch

	echo "$WRT_TARGET patch has been installed!"
fi

if [[ $WRT_URL == *"lede"* && $WRT_TARGET == "Qualcom" ]]; then
	cd ./wrt/ && git apply ../Patches/qualcom/*.patch

	echo "$WRT_TARGET patch has been installed!"
fi
