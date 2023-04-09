#!/bin/bash

#Design Theme
git clone --depth=1 --single-branch https://github.com/gngpp/luci-theme-design.git
#Design Config
git clone --depth=1 --single-branch https://github.com/gngpp/luci-app-design-config.git
#Open Clash
git clone --depth=1 --single-branch --branch "dev" https://github.com/vernesong/OpenClash.git

#Open Clash Core
export CORE_VER=https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/core_version
export CORE_TUN=https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux
export CORE_DEV=https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux
export CORE_MATE=https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux

export CORE_TYPE=$(if [ "$OWRT_TYPE" == "X86" ] ; then echo "amd64" ; else echo "arm64" ; fi)
export TUN_VER=$(curl -sfL $CORE_VER | sed -n "2{s/\r$//;p;q}")

cd ./OpenClash/luci-app-openclash/root/etc/openclash
mkdir ./core && cd ./core

curl -sfL -o ./tun.gz "$CORE_TUN"-"$CORE_TYPE"-"$TUN_VER".gz
gzip -d ./tun.gz && mv ./tun ./clash_tun

curl -sfL -o ./meta.tar.gz "$CORE_MATE"-"$CORE_TYPE".tar.gz
tar -zxf ./meta.tar.gz && mv ./clash ./clash_meta

curl -sfL -o ./dev.tar.gz "$CORE_DEV"-"$CORE_TYPE".tar.gz
tar -zxf ./dev.tar.gz

chmod +x ./clash* ; rm -rf ./*.gz
