#!/bin/bash

#删除冲突插件
rm -rf $(find ./feeds/luci/ -maxdepth 2 -type d -iregex ".*\(argon\|design\|helloworld\|homeproxy\|openclash\|passwall\).*")
#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$OWRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$OWRT_IP/g" ./package/base-files/files/bin/config_generate
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$OWRT_NAME'/g" ./package/base-files/files/bin/config_generate
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate
#修改默认时间格式
[[ $OWRT_URL == *"lede"* ]] && sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S %A")/g' $(find ./package/*/autocore/files/ -type f -name "index.htm")

#自定义更新软件包版本
UPDATE_VERSION() {
	local pkg_name=$1
	local new_ver=$2
	local new_hash=$3
	local pkg_file=$(find ./feeds/packages/*/$pkg_name/ -type f -name "Makefile" 2>/dev/null)

	if [ -f "$pkg_file" ]; then
		local old_ver=$(grep -Po "PKG_VERSION:=\K.*" "$pkg_file")
		if dpkg --compare-versions "$old_ver" lt "$new_ver"; then
			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$new_ver/g" "$pkg_file"
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$new_hash/g" "$pkg_file"
		else
			echo "$pkg_name ver is latest!"
		fi
	else
		echo "$pkg_name not found!"
	fi
}

UPDATE_VERSION "sing-box" "1.7.0" "e9cc481aac006f4082e6a690f766a65ee40532a19781cdbcff9f2b05a61e3118"
UPDATE_VERSION "naiveproxy" "119.0.6045.66-1" "b979e575353ec67a00a36a25fbf506fbbe41ea95e10ff5f60123e4be9f20eb83"
