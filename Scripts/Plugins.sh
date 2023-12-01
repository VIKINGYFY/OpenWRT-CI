#!/bin/bash

#精简git命令
CLONE="git clone --depth=1 --single-branch"

#Tiny Filemanager
$CLONE https://github.com/muink/luci-app-tinyfilemanager.git

#Design Theme
$CLONE --branch $(echo $OWRT_URL | grep -iq "lede" && echo "main" || echo "js") https://github.com/gngpp/luci-theme-design.git
$CLONE https://github.com/gngpp/luci-app-design-config.git
#Argon Theme
$CLONE --branch $(echo $OWRT_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-theme-argon.git
$CLONE --branch $(echo $OWRT_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-app-argon-config.git

#Pass Wall
$CLONE https://github.com/xiaorouji/openwrt-passwall.git
$CLONE https://github.com/xiaorouji/openwrt-passwall2.git
$CLONE https://github.com/xiaorouji/openwrt-passwall-packages.git
#Open Clash
$CLONE --branch "dev" https://github.com/vernesong/OpenClash.git
#Hello World
if [[ $OWRT_URL == *"lede"* ]] ; then
	$CLONE --branch "main" https://github.com/fw876/helloworld.git
fi
#Home Proxy
if [[ $OWRT_URL == *"immortalwrt"* ]] ; then
	$CLONE --branch "master" https://github.com/immortalwrt/homeproxy.git
fi
