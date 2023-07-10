# OpenWRT-CI
云编译OpenWRT固件

LEDE源码：
https://github.com/coolsnowwolf/lede

IMMORTALWRT源码：
https://github.com/immortalwrt/immortalwrt

# 固件简要说明：

固件每天早上4点自动编译。

固件信息里的时间为编译开始的时间，方便核对上游源码提交时间。

Rockchip系列，包含R2C R2S R4S R5C R5S R6S R66S R68S H66K H68K H69K

Mediatek系列，包含GL-MT3000 NX30-PRO Q30_PRO 360T7 WR30U

X64系列，包含X64、X86

# 目录简要说明：

Depends.txt——环境依赖列表

Scripts——自定义脚本

Config——自定义配置

workflows——自定义CI配置

打开下面链接生成.config配置文件:
https://hackyes.github.io/openwrt-menuconfig/index.html
编辑 .config 文件，把内容清空替换成上面链接生成的配置内容
