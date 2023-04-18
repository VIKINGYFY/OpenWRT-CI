#!/bin/bash

#增加主题
#echo "CONFIG_PACKAGE_luci-theme-"$OWRT_THEME"=y" >> .config
#echo "CONFIG_PACKAGE_luci-app-"$OWRT_THEME"-config=y" >> .config

echo "$OWRT_THEME"
echo "CONFIG_PACKAGE_luci-theme-"$OWRT_THEME"=y"
echo "CONFIG_PACKAGE_luci-app-$OWRT_THEME-config=y"

#根据源码来修改
if [[ $OWRT_URL == *"immortalwrt"* ]] ; then
  #增加luci界面
  echo "CONFIG_PACKAGE_luci=y" >> .config
  echo "CONFIG_LUCI_LANG_zh_Hans=y" >> .config
  #增加主题
  echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config
  echo "CONFIG_PACKAGE_luci-app-argon-config=y" >> .config
fi
