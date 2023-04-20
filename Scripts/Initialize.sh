#!/bin/bash

#初始化环境
docker rmi $(docker images -q)
sudo -E rm -rf $($GITHUB_WORKSPACE/Depends.txt | sed -n "1{s/\r$//;p;q}")
sudo -E apt -yqq update
sudo -E apt -yqq purge $($GITHUB_WORKSPACE/Depends.txt | sed -n "2{s/\r$//;p;q}")
sudo -E apt -yqq full-upgrade
sudo -E apt -yqq install $($GITHUB_WORKSPACE/Depends.txt | sed -n "3{s/\r$//;p;q}")
sudo -E apt -yqq autoremove --purge
sudo -E apt -yqq autoclean
sudo -E apt -yqq clean
sudo -E systemctl daemon-reload
sudo -E timedatectl set-timezone "Asia/Shanghai"