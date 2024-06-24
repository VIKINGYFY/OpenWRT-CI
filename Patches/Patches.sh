#!/bin/bash

if [[ $WRT_URL == *"immortalwrt"* && $WRT_TARGET == "Mediatek" ]]; then
	mv -f ./Patches/mediatek/*.dts ./wrt/target/linux/mediatek/dts/

	patch -R -p1 -d ./wrt < ./Patches/mediatek/mtk*.patch

	echo "$WRT_TARGET patch has been installed!"
fi
