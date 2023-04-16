#!/bin/bash

#根据源码来修改
if [[ $OWRT_URL == *"lede"* ]] ; then
  echo "CONFIG_PACKAGE_luci-theme-design=y" >> .config
  echo "CONFIG_PACKAGE_luci-app-design-config=y" >> .config
elif [[ $OWRT_URL == *"immortalwrt"* ]] ; then
  echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config
  echo "CONFIG_PACKAGE_luci-app-argon-config=y" >> .config
  echo "CONFIG_PACKAGE_luci=y" >> .config
  echo "CONFIG_LUCI_LANG_zh_Hans=y" >> .config
fi
