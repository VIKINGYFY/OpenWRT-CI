#!/bin/bash

if [[ $WRT_REPO == *"lede"* ]]; then
	sed -i "/#src/d" ./wrt/feeds.conf.default
	sed -i "s|\(src-git luci\).*|\1 https://github.com/coolsnowwolf/luci.git;openwrt-23.05|g" ./wrt/feeds.conf.default

	echo "$WRT_REPO patch has been installed!"
fi

if [[ $WRT_REPO == *"immortalwrt"* ]]; then
cat <<EOF >> ./wrt/package/network/config/firewall/files/firewall.config

config include 'socat'
	option type 'script'
	option path '/var/etc/socat.include'

config include 'miniupnpd'
	option type 'script'
	option path '/usr/share/miniupnpd/firewall.include'
EOF

	echo "$WRT_REPO patch has been installed!"
fi