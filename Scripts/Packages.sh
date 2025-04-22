#!/bin/bash

#安装和更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local PKG_LIST=("$PKG_NAME" $5)  # 第5个参数为自定义名称列表
	local REPO_NAME=${PKG_REPO#*/}

	echo " "

	# 删除本地可能存在的不同名称的软件包
	for NAME in "${PKG_LIST[@]}"; do
		# 查找匹配的目录
		echo "Search directory: $NAME"
		local FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)

		# 删除找到的目录
		if [ -n "$FOUND_DIRS" ]; then
			while read -r DIR; do
				rm -rf "$DIR"
				echo "Delete directory: $DIR"
			done <<< "$FOUND_DIRS"
		else
			echo "Not fonud directory: $NAME"
		fi
	done

	# 克隆 GitHub 仓库
	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	# 处理克隆的仓库（35～41行已注释掉“#”；43～52行为替代）
	#if [[ $PKG_SPECIAL == "pkg" ]]; then
		#find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
		#rm -rf ./$REPO_NAME/
	#elif [[ $PKG_SPECIAL == "name" ]]; then
		#mv -f $REPO_NAME $PKG_NAME
	#fi
#}

	# 处理克隆的仓库--修改后的（2025.04.12）
	if [[ $PKG_SPECIAL == "pkg" ]]; then
  	  # 修改后的 find 命令：覆盖深层目录（如 relevance/filebrowser）
  		find ./$REPO_NAME/ -maxdepth 5 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
  	 	rm -rf ./$REPO_NAME/
	elif [[ $PKG_SPECIAL == "name" ]]; then
  	  # 原逻辑：直接重命名仓库目录（适用于插件与仓库同名的情况）
  		mv -f $REPO_NAME $PKG_NAME
	fi
}

# 调用示例
# UPDATE_PACKAGE "OpenAppFilter" "destan19/OpenAppFilter" "master" "" "custom_name1 custom_name2"
# UPDATE_PACKAGE "open-app-filter" "destan19/OpenAppFilter" "master" "" "luci-app-appfilter oaf" 这样会把原有的open-app-filter，luci-app-appfilter，oaf相关组件删除，不会出现coremark错误。

# UPDATE_PACKAGE "包名" "项目地址" "项目分支" "pkg/name，可选，pkg为从大杂烩中单独提取包名插件；name为重命名为包名"
UPDATE_PACKAGE "argon" "sbwml/luci-theme-argon" "openwrt-24.10"
UPDATE_PACKAGE "kucat" "sirpdboy/luci-theme-kucat" "js"

UPDATE_PACKAGE "homeproxy" "VIKINGYFY/homeproxy" "main"
UPDATE_PACKAGE "nikki" "nikkinikki-org/OpenWrt-nikki" "main"
UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev" "pkg"
UPDATE_PACKAGE "passwall" "xiaorouji/openwrt-passwall" "main" "pkg"
UPDATE_PACKAGE "passwall2" "xiaorouji/openwrt-passwall2" "main" "pkg"

UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"

UPDATE_PACKAGE "alist" "sbwml/luci-app-alist" "main"
UPDATE_PACKAGE "easytier" "EasyTier/luci-app-easytier" "main"
UPDATE_PACKAGE "gecoosac" "lwb1978/openwrt-gecoosac" "main"
UPDATE_PACKAGE "mosdns" "sbwml/luci-app-mosdns" "v5" "" "v2dat"
UPDATE_PACKAGE "qmodem" "FUjr/modem_feeds" "main"
UPDATE_PACKAGE "viking" "VIKINGYFY/packages" "main" "" "luci-app-timewol luci-app-wolplus"
UPDATE_PACKAGE "vnt" "lmq8267/luci-app-vnt" "main"

if [[ $WRT_REPO != *"immortalwrt"* ]]; then
	UPDATE_PACKAGE "qmi-wwan" "immortalwrt/wwan-packages" "master" "pkg"
fi

#更新软件包版本
UPDATE_VERSION() {
	local PKG_NAME=$1
	local PKG_MARK=${2:-false}
	local PKG_FILES=$(find ./ ../feeds/packages/ -maxdepth 3 -type f -wholename "*/$PKG_NAME/Makefile")

	if [ -z "$PKG_FILES" ]; then
		echo "$PKG_NAME not found!"
		return
	fi

	echo -e "\n$PKG_NAME version update has started!"

	for PKG_FILE in $PKG_FILES; do
		local PKG_REPO=$(grep -Po "PKG_SOURCE_URL:=https://.*github.com/\K[^/]+/[^/]+(?=.*)" $PKG_FILE)
		local PKG_TAG=$(curl -sL "https://api.github.com/repos/$PKG_REPO/releases" | jq -r "map(select(.prerelease == $PKG_MARK)) | first | .tag_name")

		local OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" "$PKG_FILE")
		local OLD_URL=$(grep -Po "PKG_SOURCE_URL:=\K.*" "$PKG_FILE")
		local OLD_FILE=$(grep -Po "PKG_SOURCE:=\K.*" "$PKG_FILE")
		local OLD_HASH=$(grep -Po "PKG_HASH:=\K.*" "$PKG_FILE")

		local PKG_URL=$([[ $OLD_URL == *"releases"* ]] && echo "${OLD_URL%/}/$OLD_FILE" || echo "${OLD_URL%/}")

		local NEW_VER=$(echo $PKG_TAG | sed -E 's/[^0-9]+/\./g; s/^\.|\.$//g')
		local NEW_URL=$(echo $PKG_URL | sed "s/\$(PKG_VERSION)/$NEW_VER/g; s/\$(PKG_NAME)/$PKG_NAME/g")
		local NEW_HASH=$(curl -sL "$NEW_URL" | sha256sum | cut -d ' ' -f 1)

		echo "old version: $OLD_VER $OLD_HASH"
		echo "new version: $NEW_VER $NEW_HASH"

		if [[ $NEW_VER =~ ^[0-9].* ]] && dpkg --compare-versions "$OLD_VER" lt "$NEW_VER"; then
			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" "$PKG_FILE"
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" "$PKG_FILE"
			echo "$PKG_FILE version has been updated!"
		else
			echo "$PKG_FILE version is already the latest!"
		fi
	done
}

#UPDATE_VERSION "软件包名" "测试版，true，可选，默认为否"
UPDATE_VERSION "sing-box"
UPDATE_VERSION "tailscale"

#------------------以下自定义源--------------------#

#全能推送PushBot
UPDATE_PACKAGE "luci-app-pushbot" "zzsj0928/luci-app-pushbot" "master"

#关机poweroff
UPDATE_PACKAGE "luci-app-poweroff" "DongyangHu/luci-app-poweroff" "main"

#主题界面edge
UPDATE_PACKAGE "luci-theme-edge" "ricemices/luci-theme-edge" "master"

#分区扩容
UPDATE_PACKAGE "luci-app-partexp" "sirpdboy/luci-app-partexp" "main"

#阿里云盘aliyundrive-webdav
UPDATE_PACKAGE "luci-app-aliyundrive-webdav" "messense/aliyundrive-webdav" "main"
#UPDATE_PACKAGE "aliyundrive-webdav" "master-yun-yun/aliyundrive-webdav" "main" "pkg"
#UPDATE_PACKAGE "luci-app-aliyundrive-webdav" "master-yun-yun/aliyundrive-webdav" "main"

#服务器
#UPDATE_PACKAGE "luci-app-openvpn-server" "hyperlook/luci-app-openvpn-server" "main"
#UPDATE_PACKAGE "luci-app-openvpn-server" "ixiaan/luci-app-openvpn-server" "main"

#luci-app-navidrome音乐服务器
UPDATE_PACKAGE "luci-app-navidrome" "tty228/luci-app-navidrome" "main"

#luci-theme-design主题界面
UPDATE_PACKAGE "luci-theme-design" "emxiong/luci-theme-design" "master"
#luci-app-design-config主题配置
UPDATE_PACKAGE "luci-app-design-config" "kenzok78/luci-app-design-config" "main"

#luci-app-quickstart
#UPDATE_PACKAGE "luci-app-quickstart" "animegasan/luci-app-quickstart" "main"

#端口转发luci-app-socat
UPDATE_PACKAGE "luci-app-socat" "WROIATE/luci-app-socat" "main"

#------------------以上自定义源--------------------#


#-------------------2025.04.12-测试-----------------#
#UPDATE_PACKAGE "luci-app-clouddrive2" "shidahuilang/openwrt-package" "Immortalwrt" "pkg"

#UPDATE_PACKAGE "istoreenhance" "shidahuilang/openwrt-package" "Immortalwrt" "pkg"
#UPDATE_PACKAGE "luci-app-istoreenhance" "shidahuilang/openwrt-package" "Immortalwrt" "pkg"

UPDATE_PACKAGE "linkmount" "master-yun-yun/package-istore" "Immortalwrt" "pkg"
UPDATE_PACKAGE "linkease" "master-yun-yun/package-istore" "Immortalwrt" "pkg"
UPDATE_PACKAGE "luci-app-linkease" "master-yun-yun/package-istore" "Immortalwrt" "pkg"

UPDATE_PACKAGE "quickstart" "shidahuilang/openwrt-package" "Immortalwrt" "pkg"
UPDATE_PACKAGE "luci-app-quickstart" "shidahuilang/openwrt-package" "Immortalwrt" "pkg"

UPDATE_PACKAGE "luci-app-store" "shidahuilang/openwrt-package" "Immortalwrt" "pkg"

UPDATE_PACKAGE "webdav2" "shidahuilang/openwrt-package" "Immortalwrt" "pkg"
UPDATE_PACKAGE "unishare" "shidahuilang/openwrt-package" "Immortalwrt" "pkg"
UPDATE_PACKAGE "luci-app-unishare" "shidahuilang/openwrt-package" "Immortalwrt" "pkg"
#-------------------2025.04.12-测试-----------------#
