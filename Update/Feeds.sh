#!/bin/bash

#删除冲突主题
rm -rf $(find ./feeds/luci/ -type d -name "*-argon*" -or -type d -name "*-design*")