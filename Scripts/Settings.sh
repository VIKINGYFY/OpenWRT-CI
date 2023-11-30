#!/bin/bash

#删除冲突插件
rm -rf $(find ./feeds/luci/ -maxdepth 2 -type d -iregex ".*\(argon\|design\|helloworld\|homeproxy\|openclash\|passwall\|mosdns\).*")
#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$OWRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$OWRT_IP/g" ./package/base-files/files/bin/config_generate
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$OWRT_NAME'/g" ./package/base-files/files/bin/config_generate
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate

#根据源码来修改
if [[ $OWRT_URL == *"lede"* ]] ; then
	#修改默认时间格式
	sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S %A")/g' $(find ./package/*/autocore/files/ -type f -name "index.htm")
fi

#自定义更新软件包版本
UPDATE_VERSION() {
	local makefile=$(find ./feeds/packages/*/$1 -name "Makefile" 2>/dev/null)

	if [ -f "$makefile" ]; then
		sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$2/g" "$makefile"
		sed -i "s/PKG_HASH:=.*/PKG_HASH:=$3/g" "$makefile"
	else
		echo "Makefile for $1 not found!"
	fi
}

#sing-box
UPDATE_VERSION "sing-box" "1.7.0" "e9cc481aac006f4082e6a690f766a65ee40532a19781cdbcff9f2b05a61e3118"
