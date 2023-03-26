#!/bin/bash

#Design Theme
git clone --depth=1 --single-branch https://github.com/gngpp/luci-theme-design.git

#Design Config
git clone --depth=1 --single-branch https://github.com/gngpp/luci-app-design-config.git

#OpenClash
git clone --depth=1 --single-branch --branch "dev" https://github.com/vernesong/OpenClash.git

#OpenClash Core
cd ./OpenClash/luci-app-openclash/root/etc/openclash
mkdir ./core && cd ./core

export TUN_VER=$(curl -fsL $CORE_VER | sed -n "2p")
curl -fsL -o ./tun.gz "$CORE_TUN"-"$TUN_VER".gz
gzip -d ./tun.gz
mv ./tun ./clash_tun

curl -fsL -o ./meta.tar.gz $CORE_MATE
tar -zxf ./meta.tar.gz
mv ./clash ./clash_meta

curl -fsL -o ./dev.tar.gz $CORE_DEV
tar -zxf ./dev.tar.gz

chmod +x ./clash*
rm -rf ./*.gz
