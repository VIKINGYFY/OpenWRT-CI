#!/bin/bash

#修改Tiny Filemanager汉化
if [ -d *"tinyfilemanager"* ]; then
	PO_FILE="./luci-app-tinyfilemanager/po/zh_Hans/tinyfilemanager.po"
	sed -i '/msgid "Tiny File Manager"/{n; s/msgstr.*/msgstr "文件管理器"/}' $PO_FILE
	sed -i 's/启用用户验证/用户验证/g;s/家目录/初始目录/g;s/Favicon 路径/收藏夹图标路径/g' $PO_FILE

	echo "tinyfilemanager date has been updated!"
fi

#预置HomeProxy数据
if [ -d *"homeproxy"* ]; then
	HP_PATCH="../homeproxy/root/etc/homeproxy/resources"

	UPDATE_RESOURCES() {
		local RES_TYPE=$1
		local RES_REPO=$(echo "$2" | tr '[:upper:]' '[:lower:]')
		local RES_BRANCH=$3
		local RES_FILE=$4
		local RES_EXT=${4##*.}
		local RES_DEPTH=${5:-1}

		git clone -q --depth=$RES_DEPTH --single-branch --branch $RES_BRANCH "https://github.com/$RES_REPO.git" ./$RES_TYPE/

		cd ./$RES_TYPE/

		if [[ $RES_EXT == "txt" ]]; then
			echo $(git log -1 --pretty=format:'%s' -- $RES_FILE | grep -o "[0-9]*") > "$RES_TYPE".ver
			mv -f $RES_FILE "$RES_TYPE"."$RES_EXT"
		elif [[ $RES_EXT == "zip" ]]; then
			local REPO_ID=$(echo -n "$RES_REPO" | md5sum | cut -d ' ' -f 1)
			local REPO_VER=$(git log -1 --pretty=format:'%s' | cut -d ' ' -f 1)
			echo "{ \"$REPO_ID\": { \"repo\": \"$(echo $RES_REPO | sed 's/\//\\\//g')\", \"version\": \"$REPO_VER\" } }" > "$RES_TYPE".ver
			curl -sfL -O "https://github.com/$RES_REPO/archive/$RES_FILE"
			mv -f $RES_FILE $HP_PATCH/"${RES_REPO//\//_}"."$RES_EXT"
		elif [[ $RES_EXT == "db" ]]; then
			local RES_VER=$(git tag | tail -n 1)
			echo $RES_VER > "$RES_TYPE".ver
			curl -sfL -O "https://github.com/$RES_REPO/releases/download/$RES_VER/$RES_FILE"
		fi

		cp -f "$RES_TYPE".* $HP_PATCH/
		chmod +x $HP_PATCH/*

		cd .. && rm -rf ./$RES_TYPE/
	}

	UPDATE_RESOURCES "china_ip4" "1715173329/IPCIDR-CHINA" "master" "ipv4.txt" "5"
	UPDATE_RESOURCES "china_ip6" "1715173329/IPCIDR-CHINA" "master" "ipv6.txt" "5"
	UPDATE_RESOURCES "gfw_list" "Loyalsoldier/v2ray-rules-dat" "release" "gfw.txt"
	UPDATE_RESOURCES "china_list" "Loyalsoldier/v2ray-rules-dat" "release" "direct-list.txt"
	#UPDATE_RESOURCES "geoip" "1715173329/sing-geoip" "master" "geoip.db"
	#UPDATE_RESOURCES "geosite" "1715173329/sing-geosite" "master" "geosite.db"
	#UPDATE_RESOURCES "clash_dashboard" "MetaCubeX/metacubexd" "gh-pages" "gh-pages.zip"

	echo "homeproxy date has been updated!"
fi

#预置OpenClash内核和数据
if [ -d *"OpenClash"* ]; then
	CORE_VER="https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/core_version"
	CORE_TYPE=$(echo $WRT_TARGET | egrep -iq "64|86" && echo "amd64" || echo "arm64")
	CORE_TUN_VER=$(curl -sfL $CORE_VER | sed -n "2{s/\r$//;p;q}")

	CORE_DEV="https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux-$CORE_TYPE.tar.gz"
	CORE_MATE="https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-$CORE_TYPE.tar.gz"
	CORE_TUN="https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux-$CORE_TYPE-$CORE_TUN_VER.gz"

	GEO_MMDB="https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb"
	GEO_SITE="https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat"
	GEO_IP="https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat"
	GEO_META="https://github.com/MetaCubeX/meta-rules-dat/raw/release/geoip.metadb"

	cd ./OpenClash/luci-app-openclash/root/etc/openclash/

	curl -sfL -o Country.mmdb $GEO_MMDB
	curl -sfL -o GeoSite.dat $GEO_SITE
	curl -sfL -o GeoIP.dat $GEO_IP
	curl -sfL -o GeoIP.metadb $GEO_META

	mkdir ./core/ && cd ./core/

	curl -sfL -o meta.tar.gz $CORE_MATE && tar -zxf meta.tar.gz && mv -f clash clash_meta
	curl -sfL -o tun.gz $CORE_TUN && gzip -d tun.gz && mv -f tun clash_tun
	curl -sfL -o dev.tar.gz $CORE_DEV && tar -zxf dev.tar.gz

	chmod +x ./clash* && rm -rf ./*.gz

	echo "openclash date has been updated!"
fi
