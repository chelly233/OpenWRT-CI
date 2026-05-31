#!/bin/bash

PKG_PATH="$GITHUB_WORKSPACE/wrt/package/"

#修复Rust编译失败
RUST_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/rust/Makefile")
if [ -f "$RUST_FILE" ]; then
	echo " "

	sed -i 's/ci-llvm=true/ci-llvm=false/g' "$RUST_FILE"

	cd "$PKG_PATH" && echo "rust has been fixed!"
fi
