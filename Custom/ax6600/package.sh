#!/bin/bash

UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local PKG_LIST=("$PKG_NAME" $5)
	local REPO_NAME=${PKG_REPO#*/}

	echo " "

	for NAME in "${PKG_LIST[@]}"; do
		echo "Search directory: $NAME"
		local FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)

		if [ -n "$FOUND_DIRS" ]; then
			while read -r DIR; do
				rm -rf "$DIR"
				echo "Delete directory: $DIR"
			done <<< "$FOUND_DIRS"
		else
			echo "Not fonud directory: $NAME"
		fi
	done

	git clone --depth=1 --single-branch --branch "$PKG_BRANCH" "https://github.com/$PKG_REPO.git"

	if [[ "$PKG_SPECIAL" == "pkg" ]]; then
		find ./"$REPO_NAME"/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
		rm -rf ./"$REPO_NAME"/
	elif [[ "$PKG_SPECIAL" == "name" ]]; then
		mv -f "$REPO_NAME" "$PKG_NAME"
	fi
}

UPDATE_PACKAGE "argon" "sbwml/luci-theme-argon" "openwrt-25.12"
UPDATE_PACKAGE "aurora" "eamonxg/luci-theme-aurora" "master"
UPDATE_PACKAGE "shadcn" "eamonxg/luci-theme-shadcn" "main"

UPDATE_PACKAGE "momo" "nikkinikki-org/OpenWrt-momo" "main"
UPDATE_PACKAGE "nikki" "nikkinikki-org/OpenWrt-nikki" "main"
UPDATE_PACKAGE "passwall" "Openwrt-Passwall/openwrt-passwall" "main" "pkg"
UPDATE_PACKAGE "passwall2" "Openwrt-Passwall/openwrt-passwall2" "main" "pkg"

UPDATE_PACKAGE "mosdns" "sbwml/luci-app-mosdns" "v5" "" "v2dat"
UPDATE_PACKAGE "v2ray-geodata" "sbwml/v2ray-geodata" "master"

# Embed the complete Loyalsoldier databases in the v2ray data packages.
GEO_DATA_MAKEFILE="./v2ray-geodata/Makefile"
if [ -f "$GEO_DATA_MAKEFILE" ]; then
	sed -i \
		-e 's#https://github.com/Loyalsoldier/geoip/releases/latest/download/geoip-only-cn-private.dat#https://github.com/Loyalsoldier/geoip/releases/latest/download/geoip.dat#' \
		-e 's#https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat#https://github.com/Loyalsoldier/geosite/releases/latest/download/geosite.dat#' \
		"$GEO_DATA_MAKEFILE"
fi
UPDATE_PACKAGE "qbittorrent" "sbwml/luci-app-qbittorrent" "master" "" "qt6base qt6tools rblibtorrent"

# Pull honk and its LuCI app from the upstream package feed at build time.
# The package Makefile downloads the honk-core release from Glassyiris/honk.
INSTALL_HONK_PACKAGES() {
	local REPO_DIR=".honk-small"
	local REPO_URL="https://github.com/kenzok8/small.git"

	rm -rf "$REPO_DIR" ./honk ./luci-app-honk
	git clone --depth=1 --single-branch --branch master "$REPO_URL" "$REPO_DIR"
	for PKG_NAME in honk luci-app-honk; do
		if [ ! -d "$REPO_DIR/$PKG_NAME" ]; then
			echo "Missing $PKG_NAME in $REPO_URL" >&2
			rm -rf "$REPO_DIR"
			return 1
		fi
		cp -a "$REPO_DIR/$PKG_NAME" "./$PKG_NAME"
	done
	rm -rf "$REPO_DIR"
	echo "Installed honk and luci-app-honk from $REPO_URL"
}

INSTALL_HONK_PACKAGES
