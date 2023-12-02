#!/bin/bash

#预置HomeProxy数据
if [[ -d "homeproxy" ]]; then
	HP_PATCH="../homeproxy/root/etc/homeproxy/resources"

	UPDATE_RESOURCES() {
		local res_type=$1
		local res_repo=$2
		local res_branch=$3
		local res_file=$4
		local res_depth=${5:-1}

		git clone --depth=$res_depth --single-branch --branch $res_branch "https://github.com/$res_repo.git" ./$res_type/

		cd ./$res_type/

		if [[ "${res_file##*.}" == "txt" ]]; then
			echo $(git log -1 --pretty=format:'%s' -- $res_file | grep -o "[0-9]*") > "$res_type.ver"
			mv -f $res_file "$res_type.${res_file##*.}"
		elif [[ "${res_file##*.}" == "zip" ]]; then
			echo $(git log -1 --pretty=format:'%s' | cut -d ' ' -f 1) > "$res_type.ver"
			curl -sfL -O "https://github.com/$res_repo/archive/$res_file"
			mv -f $res_file $HP_PATCH/"${res_repo//\//_}.${res_file##*.}"
		elif [[ "${res_file##*.}" == "db" ]]; then
			local res_ver=$(git tag | tail -n 1)
			echo $res_ver > "$res_type.ver"
			curl -sfL -O "https://github.com/$res_repo/releases/download/$res_ver/$res_file"
		fi

		cp -f $res_type.* $HP_PATCH/

		cd .. && rm -rf ./$res_type/
	}

	UPDATE_RESOURCES "china_ip4" "1715173329/IPCIDR-CHINA" "master" "ipv4.txt" "5"
	UPDATE_RESOURCES "china_ip6" "1715173329/IPCIDR-CHINA" "master" "ipv6.txt" "5"
	UPDATE_RESOURCES "gfw_list" "Loyalsoldier/v2ray-rules-dat" "release" "gfw.txt"
	UPDATE_RESOURCES "china_list" "Loyalsoldier/v2ray-rules-dat" "release" "direct-list.txt"
	UPDATE_RESOURCES "geoip" "1715173329/sing-geoip" "master" "geoip.db"
	UPDATE_RESOURCES "geosite" "1715173329/sing-geosite" "master" "geosite.db"
	UPDATE_RESOURCES "clash_dashboard" "MetaCubeX/metacubexd" "gh-pages" "gh-pages.zip"
fi

#预置OpenClash内核和数据
if [[ -d "OpenClash" ]]; then
	CORE_VER=https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/core_version
	CORE_TUN=https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux
	CORE_DEV=https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux
	CORE_MATE=https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux

	CORE_TYPE=$(echo $OWRT_TARGET | egrep -iq "64|86" && echo "amd64" || echo "arm64")
	TUN_VER=$(curl -sfL $CORE_VER | sed -n "2{s/\r$//;p;q}")

	GEO_MMDB=https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb
	GEO_SITE=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat
	GEO_IP=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat
	META_DB=https://github.com/MetaCubeX/meta-rules-dat/raw/release/geoip.metadb

	cd ./OpenClash/luci-app-openclash/root/etc/openclash/

	curl -sfL -o Country.mmdb $GEO_MMDB
	curl -sfL -o GeoSite.dat $GEO_SITE
	curl -sfL -o GeoIP.dat $GEO_IP
	curl -sfL -o GeoIP.metadb $META_DB

	mkdir ./core/ && cd ./core/

	curl -sfL -o tun.gz "$CORE_TUN"-"$CORE_TYPE"-"$TUN_VER".gz
	gzip -d tun.gz && mv -f tun clash_tun

	curl -sfL -o meta.tar.gz "$CORE_MATE"-"$CORE_TYPE".tar.gz
	tar -zxf meta.tar.gz && mv -f clash clash_meta

	curl -sfL -o dev.tar.gz "$CORE_DEV"-"$CORE_TYPE".tar.gz
	tar -zxf dev.tar.gz

	chmod +x clash*
	rm -rf *.gz
fi
