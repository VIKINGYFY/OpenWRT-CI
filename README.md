# 高质量<免费>交流群

[IPQ技术讨论群](https://qm.qq.com/q/v7nMhzB4oU)

# 高质量<付费>中转站

[LiBwrt-Ai](https://api.zipimg.cn/register?aff=FFPS3UMJ8HJD)

# 本地编译器

https://github.com/VIKINGYFY/OWRT-Tools.git

# 自用修改版插件

https://github.com/VIKINGYFY/packages.git

# OpenWRT-CI

官方版：

https://github.com/immortalwrt/immortalwrt.git

自用版：

https://github.com/VIKINGYFY/immortalwrt.git

# U-BOOT

高通版-沉心：

https://github.com/chenxin527/uboot-qsdk12.5-build.git

高通版-小猪：

https://github.com/1980490718/u-boot-2016.git

联发科-全新版：

https://github.com/VIKINGYFY/UBOOT-CI/releases

联发科-官方版：

https://drive.wrt.moe/uboot/mediatek

# 固件简要说明

固件每天早上5点自动编译。

固件信息里的时间为编译开始的时间，方便核对上游源码提交时间。

MEDIATEK系列、QUALCOMMAX系列、ROCKCHIP系列、X86系列。

# 目录简要说明

workflows——自定义CI配置

Scripts——自定义脚本

Config——自定义配置

## 自定义 Wi-Fi 名称和密码

在仓库 **Settings → Secrets and variables → Actions → Variables** 中设置
`WRT_SSID` 和 `WRT_WORD`，所有平台工作流都会读取。手动运行工作流时也可填写
`SSID`、`WORD`，覆盖本次构建；未设置时使用 `OWRT`、`12345678`。

使用支持独立无线默认配置的 Router Tool 源码时，`WRT_SSID` 是名称前缀。
例如 `Home` 生成 `Home-Redmi-2.4G`、`Home-Redmi-5.2G`；厂商和频段由设备确定，
名称最多 32 字节。`WRT_WORD` 是各频段的统一密码，要求 8 至 63 个可打印 ASCII 字符。
只修改密码也会正常应用 Router Tool 的信道、带宽和安全设置。

脚本把默认值写入 `/etc/config/router-tool` 中类型为 `wireless` 的 `defaults` 节，
此路径不修改无线生成脚本。没有安装 Router Tool 的官方源码或显式禁用该插件时使用兼容路径，
此时 `WRT_SSID` 是完整名称，各频段一致。旧 Router Tool 源码如果缺少配置接口，
构建会提示更新源码，避免静默跳过无线初始化。

这些值只决定出厂 Wi-Fi。保留配置升级会保留已有名称和密码；设备启动后可继续
在 LuCI 的“网络 → 无线”修改，不会被自动同步改回。
当前工作流会在固件 Release 说明中公开 Wi-Fi 密码，适用于公开的出厂凭据；
私人密码应在设备上修改。

## Star History

<a href="https://www.star-history.com/?repos=vikingyfy%2Fopenwrt-ci&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=vikingyfy/openwrt-ci&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=vikingyfy/openwrt-ci&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=vikingyfy/openwrt-ci&type=date&legend=top-left" />
 </picture>
</a>
