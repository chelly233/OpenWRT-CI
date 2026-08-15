#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")

# Remove unused themes while keeping Material as an additional selectable theme.
for THEME in aurora bootstrap openwrt openwrt-2020 kucat; do
	sed -i -E "/^CONFIG_PACKAGE_luci-theme-${THEME}=.*/d; /^CONFIG_PACKAGE_luci-app-${THEME}-config=.*/d; /^CONFIG_PACKAGE_luci-i18n-${THEME}-config-zh-cn=.*/d" ./.config
	echo "CONFIG_PACKAGE_luci-theme-${THEME}=n" >> ./.config
done

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi
