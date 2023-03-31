#!/bin/bash

#PassWall LUCI
git clone --depth=1 --single-branch --branch "luci" https://github.com/xiaorouji/openwrt-passwall.git ./pw_luci
#PassWall Package
git clone --depth=1 --single-branch https://github.com/xiaorouji/openwrt-passwall.git ./pw_package
#Argon Theme
git clone --depth=1 --single-branch --branch "18.06" https://github.com/jerrykuku/luci-theme-argon.git
#Argon Config
git clone --depth=1 --single-branch https://github.com/jerrykuku/luci-app-argon-config.git
#Design Theme
git clone --depth=1 --single-branch https://github.com/gngpp/luci-theme-design.git
#Design Config
git clone --depth=1 --single-branch https://github.com/gngpp/luci-app-design-config.git
#OpenClash
git clone --depth=1 --single-branch --branch "dev" https://github.com/vernesong/OpenClash.git

#OpenClash Core
export CORE_VER=https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/core_version
export CORE_TUN=https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux
export CORE_DEV=https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux
export CORE_MATE=https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux

cd ./OpenClash/luci-app-openclash/root/etc/openclash
mkdir ./core && cd ./core

export TUN_VER=$(curl -sfL $CORE_VER | sed -n "2p")
curl -sfL -o ./tun.gz "$CORE_TUN"-"$CORE_TYPE"-"$TUN_VER".gz
gzip -d ./tun.gz
mv ./tun ./clash_tun

curl -sfL -o ./meta.tar.gz "$CORE_MATE"-"$CORE_TYPE".tar.gz
tar -zxf ./meta.tar.gz
mv ./clash ./clash_meta

curl -sfL -o ./dev.tar.gz "$CORE_DEV"-"$CORE_TYPE".tar.gz
tar -zxf ./dev.tar.gz

chmod +x ./clash*
rm -rf ./*.gz
