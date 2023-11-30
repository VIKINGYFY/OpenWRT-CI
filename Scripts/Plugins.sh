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
  $CLONE --branch "dev" https://github.com/immortalwrt/homeproxy.git
fi

#修改Tiny Filemanager汉化
sed -i '/msgid "Tiny File Manager"/{n; s/msgstr.*/msgstr "文件管理器"/}' ./luci-app-tinyfilemanager/po/zh_Hans/tinyfilemanager.po
sed -i 's/启用用户验证/用户验证/g;s/家目录/初始目录/g;s/Favicon 路径/收藏夹图标路径/g' ./luci-app-tinyfilemanager/po/zh_Hans/tinyfilemanager.po

#预置OpenClash内核和GEO数据
CORE_VER=https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/core_version
CORE_TUN=https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux
CORE_DEV=https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux
CORE_MATE=https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux

CORE_TYPE=$(echo $OWRT_TARGET | grep -Eiq "64|86" && echo "amd64" || echo "arm64")
TUN_VER=$(curl -sfL $CORE_VER | sed -n "2{s/\r$//;p;q}")

GEO_MMDB=https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb
GEO_SITE=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat
GEO_IP=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat
META_DB=https://github.com/MetaCubeX/meta-rules-dat/raw/release/geoip.metadb

cd ./OpenClash/luci-app-openclash/root/etc/openclash

curl -sfL -o ./Country.mmdb $GEO_MMDB
curl -sfL -o ./GeoSite.dat $GEO_SITE
curl -sfL -o ./GeoIP.dat $GEO_IP
curl -sfL -o ./GeoIP.metadb $META_DB

mkdir ./core && cd ./core

curl -sfL -o ./tun.gz "$CORE_TUN"-"$CORE_TYPE"-"$TUN_VER".gz
gzip -d ./tun.gz && mv ./tun ./clash_tun

curl -sfL -o ./meta.tar.gz "$CORE_MATE"-"$CORE_TYPE".tar.gz
tar -zxf ./meta.tar.gz && mv ./clash ./clash_meta

curl -sfL -o ./dev.tar.gz "$CORE_DEV"-"$CORE_TYPE".tar.gz
tar -zxf ./dev.tar.gz

chmod +x ./clash* ; rm -rf ./*.gz
