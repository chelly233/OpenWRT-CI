#!/bin/bash

PKG_PATH="$GITHUB_WORKSPACE/wrt/package/"

#修改argon主题字体和颜色
ARGON_CONFIG="$PKG_PATH/luci-theme-argon/luci-app-argon-config/root/etc/config/argon"
if [ -f "$ARGON_CONFIG" ]; then
	echo " "

	sed -i "s/primary '.*'/primary '#31a1a1'/; s/'0.2'/'0.5'/; s/'none'/'bing'/; s/'600'/'normal'/" "$ARGON_CONFIG"

	echo "theme-argon has been fixed!"
fi

#修复Rust编译失败
RUST_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/rust/Makefile")
if [ -f "$RUST_FILE" ]; then
	echo " "

	sed -i 's/ci-llvm=true/ci-llvm=false/g' "$RUST_FILE"

	cd "$PKG_PATH" && echo "rust has been fixed!"
fi
