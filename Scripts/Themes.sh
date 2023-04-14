#!/bin/bash

#根据源码来修改
if [[ $OWRT_URL == *"lede"* ]] ; then
  #勾选默认主题Design
  echo "CONFIG_PACKAGE_luci-theme-design=y" >> .config
  echo "CONFIG_PACKAGE_luci-app-design-config=y" >> .config
else
  #勾选默认主题Argon
  echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config
  echo "CONFIG_PACKAGE_luci-app-argon-config=y" >> .config
fi