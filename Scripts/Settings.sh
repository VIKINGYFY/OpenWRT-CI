#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#添加编译日期标识
#sed -i "s/DISTRIB_TARGET='\(.*\)'/DISTRIB_TARGET='\1 $WRT_REPO-$WRT_DATE'/g" ./package/base-files/files/etc/openwrt_release
sed -i "s/luciversion = \"\(.*\)\"/luciversion = \"\1 $WRT_REPO-$WRT_DATE\"/g" ./feeds/luci/modules/luci-lua-runtime/src/mkversion.sh

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" $CFG_FILE
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" $CFG_FILE

if [[ $WRT_URL == *"lede"* ]]; then
	#修改默认时间格式
	sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S %A")/g' $(find ./package/lean/autocore/files/ -type f -name "index.htm")
fi

#配置文件修改
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

if [[ $WRT_URL == *"lede"* ]]; then
	echo "CONFIG_PACKAGE_luci-app-ssr-plus=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-openclash=y" >> ./.config
elif [[ $WRT_URL == *"immortalwrt"* ]] ; then
	echo "CONFIG_PACKAGE_luci=y" >> ./.config
	echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-homeproxy=y" >> ./.config
fi
