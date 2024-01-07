#!/bin/bash

#加回RAX3000M的支持
if [[ $WRT_URL == *"immortalwrt"* && $WRT_TARGET == "Mediatek" ]]; then
	cp -rf ./Patches/RAX3000M/* ./wrt/
fi
