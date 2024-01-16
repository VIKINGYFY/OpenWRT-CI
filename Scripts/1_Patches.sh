#!/bin/bash

#加回RAX3000M的支持
if [[ $WRT_URL == *"immortalwrt"* && $WRT_TARGET == "Mediatek" ]]; then
	cp -rf ./Patches/RAX3000M/*.dts ./wrt/target/linux/mediatek/dts

	patch -R ./wrt/package/boot/uboot-envtools/files/mediatek_filogic < ./Patches/RAX3000M/mediatek_filogic.patch
	patch -R ./wrt/target/linux/mediatek/filogic/base-files/etc/board.d/02_network < ./Patches/RAX3000M/02_network.patch
	patch -R ./wrt/target/linux/mediatek/filogic/base-files/etc/hotplug.d/firmware/11-mt76-caldata < ./Patches/RAX3000M/11-mt76-caldata.patch
	patch -R ./wrt/target/linux/mediatek/filogic/base-files/etc/hotplug.d/ieee80211/11_fix_wifi_mac < ./Patches/RAX3000M/11_fix_wifi_mac.patch
	patch -R ./wrt/target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh < ./Patches/RAX3000M/platform.sh.patch
	patch -R ./wrt/target/linux/mediatek/image/filogic.mk < ./Patches/RAX3000M/filogic.mk.patch
fi
