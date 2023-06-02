# OpenWRT-CI
云编译OpenWRT固件

LEDE源码：
https://github.com/coolsnowwolf/lede

IMMORTALWRT源码：
https://github.com/immortalwrt/immortalwrt

# 固件简要说明：

固件每天早上4点自动编译

固件信息里的时间为编译开始的时间，方便核对上游源码提交时间

Rockchip——RK系列，包含R2C R2S R4S R5C R5S R6S R66S R68S H66K H68K H69K

Mediatek系列，包含360T7、红米AX6000

X64——X64系列，包含X64、X86

# 目录简要说明：

Depends.txt——环境依赖列表

Scripts——自定义脚本

Config——自定义配置

workflows——自定义CI配置
