#!/bin/bash

if [[ $WRT_URL == *"immortalwrt"* && $WRT_TARGET == "Mediatek" ]]; then
	# cp -rf ./Patches/mediatek/*.dts ./wrt/target/linux/mediatek/dts/
	# patch -R -p1 -d ./wrt < ./Patches/mediatek/*.patch
fi
