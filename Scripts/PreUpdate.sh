#!/bin/bash

# #更新frpc
# if [[ $WRT_REPO != *"lede"* ]]; then
# 	#更新frpc
# 	if grep -q "CONFIG_PACKAGE_luci-app-frpc=y" ./.config; then
# 		echo "配置文件中包含 CONFIG_PACKAGE_luci-app-frpc=y"
# 		FRP_PATCH="package/frp"
# 		#rm -rf $(find ./feeds/luci/ ./feeds/packages/ -maxdepth 3 -type d -iname "*frp*" -prune)
# 		rm -rf ./feeds/luci/applications/luci-app-frpc
# 		rm -rf ./feeds/packages/net/frp
# 		git clone https://github.com/Yicons/openwrt-frp $FRP_PATCH
# 		mv -f ./$FRP_PATCH/luci-app-frpc ./feeds/luci/applications/
# 		mv -f ./$FRP_PATCH/frp ./feeds/packages/net/
# 		rm -rf ./$FRP_PATCH
# 		cd $PKG_PATCH && echo "frpc has been updated!"
# 	fi
# fi
