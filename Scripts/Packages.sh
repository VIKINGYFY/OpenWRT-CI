#!/bin/bash

#安装和更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local REPO_NAME=$(echo $PKG_REPO | cut -d '/' -f 2)

	rm -rf $(find ../feeds/luci/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune)

	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	if [[ $PKG_SPECIAL == "pkg" ]]; then
		cp -rf $(find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune) ./
		rm -rf ./$REPO_NAME/
	elif [[ $PKG_SPECIAL == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}

UPDATE_PACKAGE "design" "gngpp/luci-theme-design" "$([[ $WRT_URL == *"lede"* ]] && echo "main" || echo "js")"
UPDATE_PACKAGE "design-config" "gngpp/luci-app-design-config" "master"
UPDATE_PACKAGE "argon" "jerrykuku/luci-theme-argon" "$([[ $WRT_URL == *"lede"* ]] && echo "18.06" || echo "master")"
UPDATE_PACKAGE "argon-config" "jerrykuku/luci-app-argon-config" "$([[ $WRT_URL == *"lede"* ]] && echo "18.06" || echo "master")"

UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev" "pkg"
UPDATE_PACKAGE "passwall" "xiaorouji/openwrt-passwall" "main"
UPDATE_PACKAGE "ssr-plus" "fw876/helloworld" "master"

UPDATE_PACKAGE "gecoosac" "lwb1978/openwrt-gecoosac" "main"

if [[ $WRT_URL != *"lede"* ]]; then
	UPDATE_PACKAGE "homeproxy" "VIKINGYFY/homeproxy" "dev"
	UPDATE_PACKAGE "mihomo" "morytyann/OpenWrt-mihomo" "main" "pkg"
fi

#更新软件包版本
UPDATE_VERSION() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_MARK=${3:-not}
	local PKG_FILES=$(find ./ ../feeds/packages/ -maxdepth 3 -type f -wholename "*/$PKG_NAME/Makefile")

    echo " "

    if [ -z "$PKG_FILES" ]; then
        echo "$PKG_NAME not found!"
        return
    fi

    echo "$PKG_NAME version update has started!"

    local PKG_VER=$(curl -sL "https://api.github.com/repos/$PKG_REPO/releases" | jq -r "map(select(.prerelease|$PKG_MARK)) | first | .tag_name")
    local NEW_VER=$(echo $PKG_VER | sed "s/.*v//g; s/_/./g")
    local NEW_HASH=$(curl -sL "https://codeload.github.com/$PKG_REPO/tar.gz/$PKG_VER" | sha256sum | cut -b -64)

    for PKG_FILE in $PKG_FILES; do
        local OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" "$PKG_FILE")

        echo "$OLD_VER $PKG_VER $NEW_VER $NEW_HASH"

        if [[ $NEW_VER =~ ^[0-9].* ]] && dpkg --compare-versions "$OLD_VER" lt "$NEW_VER"; then
            sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" "$PKG_FILE"
            sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" "$PKG_FILE"
            echo "$PKG_FILE version has been updated!"
        else
            echo "$PKG_FILE version is already the latest!"
        fi
    done
}

#UPDATE_VERSION "软件包名" "项目地址" "测试版true（可选，默认为否）"
UPDATE_VERSION "brook" "txthinking/brook"
UPDATE_VERSION "dns2tcp" "zfl9/dns2tcp"
UPDATE_VERSION "hysteria" "apernet/hysteria"
UPDATE_VERSION "ipt2socks" "zfl9/ipt2socks"
UPDATE_VERSION "microsocks" "rofl0r/microsocks"
UPDATE_VERSION "mihomo" "metacubex/mihomo"
UPDATE_VERSION "mosdns" "IrineSistiana/mosdns"
UPDATE_VERSION "naiveproxy" "klzgrad/naiveproxy"
UPDATE_VERSION "neturl" "golgote/neturl"
UPDATE_VERSION "shadowsocks-rust" "shadowsocks/shadowsocks-rust"
UPDATE_VERSION "sing-box" "SagerNet/sing-box" "true"
UPDATE_VERSION "tcping" "Mattraks/tcping"
UPDATE_VERSION "trojan-go" "p4gefau1t/trojan-go"
UPDATE_VERSION "trojan" "trojan-gfw/trojan"
UPDATE_VERSION "v2ray-core" "v2fly/v2ray-core"
UPDATE_VERSION "v2ray-plugin" "teddysun/v2ray-plugin"
UPDATE_VERSION "v2rayA" "v2rayA/v2rayA"
UPDATE_VERSION "xray-core" "XTLS/Xray-core"
UPDATE_VERSION "xray-plugin" "teddysun/xray-plugin"
