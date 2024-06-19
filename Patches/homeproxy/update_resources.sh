#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2022-2023 ImmortalWrt.org

NAME="homeproxy"

RESOURCES_DIR="/etc/$NAME/resources"
mkdir -p "$RESOURCES_DIR"

RUN_DIR="/var/run/$NAME"
LOG_PATH="$RUN_DIR/$NAME.log"
mkdir -p "$RUN_DIR"

log() {
	echo -e "$(date "+%Y-%m-%d %H:%M:%S") $*" >> "$LOG_PATH"
}

set_lock() {
	local ACT="$1"
	local TYPE="$2"

	local LOCK="$RUN_DIR/update_resources-$TYPE.lock"
	if [ "$ACT" = "set" ]; then
		if [ -e "$LOCK" ]; then
			log "[$(to_upper "$TYPE")] A task is already running."
			exit 2
		else
			touch "$LOCK"
		fi
	elif [ "$ACT" = "remove" ]; then
		rm -f "$LOCK"
	fi
}

to_upper() {
	echo -e "$1" | tr "[a-z]" "[A-Z]"
}

check_list_update() {
	local LIST_FILE="$1"
	local REPO_NAME="$2"
	local REPO_BRANCH="$3"
	local REPO_FILE="$4"

	set_lock "set" "$LIST_FILE"

	local NEW_VER=$(curl -sL "https://api.github.com/repos/$REPO_NAME/releases" | jsonfilter -e '@[0].tag_name')
	if [ -z "$NEW_VER" ]; then
		log "[$(to_upper "$LIST_FILE")] Failed to get the latest version, please retry later."

		set_lock "remove" "$LIST_FILE"
		return 1
	fi

	local OLD_VER=$(cat "$RESOURCES_DIR/$LIST_FILE.ver" 2>/dev/null || echo "NOT FOUND")
	if [ "$OLD_VER" = "$NEW_VER" ]; then
		log "[$(to_upper "$LIST_FILE")] Current version: $NEW_VER."
		log "[$(to_upper "$LIST_FILE")] You're already at the latest version."

		set_lock "remove" "$LIST_FILE"
		return 3
	else
		log "[$(to_upper "$LIST_FILE")] Local version: $OLD_VER, latest version: $NEW_VER."
	fi

	curl -sL -o "$RUN_DIR/$REPO_FILE" "https://cdn.jsdelivr.net/gh/$REPO_NAME@$REPO_BRANCH/$REPO_FILE"
	if [ ! -s "$RUN_DIR/$REPO_FILE" ]; then
		rm -f "$RUN_DIR/$REPO_FILE"
		log "[$(to_upper "$LIST_FILE")] Update failed."

		set_lock "remove" "$LIST_FILE"
		return 1
	fi

	mv -f "$RUN_DIR/$REPO_FILE" "$RESOURCES_DIR/$LIST_FILE.${REPO_FILE##*.}"
	echo -e "$NEW_VER" > "$RESOURCES_DIR/$LIST_FILE.ver"
	log "[$(to_upper "$LIST_FILE")] Successfully updated."

	set_lock "remove" "$LIST_FILE"
	return 0
}

case "$1" in
"china_ip4")
	check_list_update "$1" "Loyalsoldier/surge-rules" "release" "cncidr.txt" && \
		sed -i "/IP-CIDR6,/d; s/IP-CIDR,//g" "$RESOURCES_DIR/china_ip4.txt"
	;;
"china_ip6")
	check_list_update "$1" "Loyalsoldier/surge-rules" "release" "cncidr.txt" && \
		sed -i "/IP-CIDR,/d; s/IP-CIDR6,//g" "$RESOURCES_DIR/china_ip6.txt"
	;;
"gfw_list")
	check_list_update "$1" "Loyalsoldier/surge-rules" "release" "gfw.txt" && \
		sed -i "s/^\.//g" "$RESOURCES_DIR/gfw_list.txt"
	;;
"china_list")
	check_list_update "$1" "Loyalsoldier/surge-rules" "release" "direct.txt" && \
		sed -i "s/^\.//g" "$RESOURCES_DIR/china_list.txt"
	;;
*)
	echo -e "Usage: $0 <china_ip4 / china_ip6 / gfw_list / china_list>"
	exit 1
	;;
esac
