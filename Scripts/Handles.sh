#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

FEEDS_PATH="./feeds"
PACKAGE_PATH="./package"

#修补命令统一入口：FIX <名称> <守卫目录> <命令...>
#守卫目录不存在时直接跳过，保证在 bash -e 下不中断
FIX() {
	local NAME=$1
	local GUARD=$2
	shift 2

	[ -d "$GUARD" ] || [ -f "$GUARD" ] || return 0

	echo " "
	if "$@"; then
		echo "$NAME has been fixed!"
	else
		echo "$NAME fix failed; continuing!"
	fi
}

#关闭GnuTLS的TPM2自动探测，避免引入未声明的TSS2依赖
GNUTLS_FILE="$FEEDS_PATH/packages/libs/gnutls/Makefile"
FIX "gnutls" "$GNUTLS_FILE" sed -i '/package.mk/a CONFIGURE_ARGS += --without-tpm2' "$GNUTLS_FILE"

#修改argon主题字体和颜色
ARGON_FILE="$PACKAGE_PATH/luci-theme-argon/luci-app-argon-config/root/etc/config/argon"
FIX "theme-argon" "$ARGON_FILE" sed -i "s/primary '.*'/primary '#31a1a1'/g; s/'0.2'/'0.5'/g; s/'none'/'bing'/g; s/'600'/'normal'/g" "$ARGON_FILE"

#修改aurora菜单式样
AURORA_PATH="$PACKAGE_PATH/luci-app-aurora-config/root/usr/share/aurora"
FIX "theme-aurora" "$AURORA_PATH" find "$AURORA_PATH" -type f -name '*.template' -exec sed -i \
	"s/nav_type '.*'/nav_type 'dropdown'/g; s/struct_radius_base '.*'/struct_radius_base '0.125rem'/g" {} +

#修改mini-diskmanager菜单位置
DISKMANAGER_FILE="$PACKAGE_PATH/luci-app-mini-diskmanager/luci-app-mini-diskmanager/root/usr/share/luci/menu.d/luci-app-mini-diskmanager.json"
FIX "mini-diskmanager" "$DISKMANAGER_FILE" sed -i "s/services/system/g" "$DISKMANAGER_FILE"

#修改natmapt菜单位置
NATMAPT_FILE="$PACKAGE_PATH/luci-app-natmapt/root/usr/share/luci/menu.d/luci-app-natmap.json"
FIX "natmapt" "$NATMAPT_FILE" sed -i "s/network/services/g" "$NATMAPT_FILE"
