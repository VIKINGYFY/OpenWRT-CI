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

UPDATE_PACKAGE "design" "gngpp/luci-theme-design" "$([[ $OWRT_URL == *"lede"* ]] && echo "main" || echo "js")"
UPDATE_PACKAGE "design-config" "gngpp/luci-app-design-config" "master"
UPDATE_PACKAGE "argon" "jerrykuku/luci-theme-argon" "$([[ $OWRT_URL == *"lede"* ]] && echo "18.06" || echo "master")"
UPDATE_PACKAGE "argon-config" "jerrykuku/luci-app-argon-config" "$([[ $OWRT_URL == *"lede"* ]] && echo "18.06" || echo "master")"

UPDATE_PACKAGE "fileassistant" "Lienol/openwrt-package" "main" "true"
UPDATE_PACKAGE "mosdns" "sbwml/luci-app-mosdns" "v5"

UPDATE_PACKAGE "passwall" "xiaorouji/openwrt-passwall" "main"
UPDATE_PACKAGE "passwall2" "xiaorouji/openwrt-passwall2" "main"
UPDATE_PACKAGE "passwall-packages" "xiaorouji/openwrt-passwall-packages" "main"
UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev"

if [[ $OWRT_URL == *"lede"* ]]; then
	UPDATE_PACKAGE "helloworld" "fw876/helloworld" "master"
fi
if [[ $OWRT_URL == *"immortalwrt"* ]]; then
	UPDATE_PACKAGE "homeproxy" "immortalwrt/homeproxy" "dev"
fi

#更新软件包版本
UPDATE_VERSION() {
	local pkg_name=$1
	local new_ver=$2
	local new_hash=$3
	local pkg_file=$(find ../feeds/packages/*/$pkg_name/ -type f -name "Makefile" 2>/dev/null)

	if [[ -f "$pkg_file" ]]; then
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

UPDATE_VERSION "sing-box" "1.7.1" "e1a5d7c9a7f3a23da73f4d420aed19c8cc5f9b85af1e190fe9502658ec6fac3a"
UPDATE_VERSION "naiveproxy" "119.0.6045.66-1" "b979e575353ec67a00a36a25fbf506fbbe41ea95e10ff5f60123e4be9f20eb83"
