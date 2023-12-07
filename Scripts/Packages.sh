#!/bin/bash

#更新软件包
UPDATE_PACKAGE() {
	local pkg_name=$1
	local pkg_repo=$2
	local pkg_branch=$3
	local pkg_special=$4
	local repo_name=$(echo $pkg_repo | cut -d '/' -f 2)

	rm -rf $(find ../feeds/luci/ -type d -iname "*$pkg_name*" -prune)

	git clone --depth=1 --single-branch --branch $pkg_branch "https://github.com/$pkg_repo.git"

	if [[ $pkg_special == "true" ]]; then
		cp -rf $(find ./$repo_name/ -type d -iname "*$pkg_name*" -prune) ./
		rm -rf ./$repo_name
	fi
}

UPDATE_PACKAGE "design" "gngpp/luci-theme-design" "$([[ $WRT_URL == *"lede"* ]] && echo "main" || echo "js")"
UPDATE_PACKAGE "design-config" "gngpp/luci-app-design-config" "master"
UPDATE_PACKAGE "argon" "jerrykuku/luci-theme-argon" "$([[ $WRT_URL == *"lede"* ]] && echo "18.06" || echo "master")"
UPDATE_PACKAGE "argon-config" "jerrykuku/luci-app-argon-config" "$([[ $WRT_URL == *"lede"* ]] && echo "18.06" || echo "master")"

UPDATE_PACKAGE "passwall" "xiaorouji/openwrt-passwall" "main"
UPDATE_PACKAGE "passwall2" "xiaorouji/openwrt-passwall2" "main"
UPDATE_PACKAGE "passwall-packages" "xiaorouji/openwrt-passwall-packages" "main"
UPDATE_PACKAGE "helloworld" "fw876/helloworld" "master"
UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev"

if [[ $WRT_URL == *"immortalwrt"* ]]; then
	#UPDATE_PACKAGE "homeproxy" "muink/homeproxy" "mdev"
	UPDATE_PACKAGE "homeproxy" "immortalwrt/homeproxy" "dev"
fi

#更新软件包版本
UPDATE_VERSION() {
	local pkg_name=$1
	local new_ver=$2
	local new_hash=$3
	local pkg_file=$(find ../feeds/packages/*/$pkg_name/ -type f -name "Makefile" 2>/dev/null)

	if [ -f $pkg_file ]; then
		local old_ver=$(grep -Po "PKG_VERSION:=\K.*" $pkg_file)
		if dpkg --compare-versions $old_ver lt $new_ver; then
			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$new_ver/g" $pkg_file
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$new_hash/g" $pkg_file
			echo "$pkg_name ver has updated!"
		else
			echo "$pkg_name ver is latest!"
		fi
	else
		echo "$pkg_name not found!"
	fi
}

UPDATE_VERSION "sing-box" "1.7.2" "74bbe97b0f8df19c1196deda4ad53edc75c57259f51f88391d66071a315829d7"
UPDATE_VERSION "naiveproxy" "119.0.6045.66-1" "b979e575353ec67a00a36a25fbf506fbbe41ea95e10ff5f60123e4be9f20eb83"
