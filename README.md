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

点击[链接](https://jack2583.github.io/openwrt-menuconfig/index.html)生成.config配置文件；编辑 config 文件夹内的对应配置，把内容清空替换成上面链接生成的配置内容。

# 定时编译说明：

- 开启定时编译方法
      #在.github\workflows文件夹内
      #定时触发开始编译(把下面两个#去掉开启,时间设置请看定时编译说明)
      #  schedule:
      #    - cron: 0 8 */5 * *
      
      把前面#去掉就开启了，看下面，就把前面的#去掉，要看好格式，格式不对是不会开启的
      
      #定时触发开始编译(把下面两个#去掉开启,时间设置请看定时编译说明)
        schedule:
          - cron: 0 8 */5 * *
      
# 
- 把《.config》配置好后，如果在不需要修改配置的情况下，就可以设置定时编译，或者在手机上启动编译（定时编译最好关闭SSH功能，要不然到了SSH连接那里需要等待30分钟后才会继续进行下一步编译）
# 
- （[utc时间对照表](https://time.is/UTC)）脚本是按utc时间开始的，要跟中国时间换算一下
# 
- (脚本使用的是utc时间)（5组数为 分-时-日-月-周，简单说明符号《*每》《/隔》《,分别》《-至》）[点击了解](http://linux.vbird.org/linux_basic/0430cron.php)
# 
- cron: 30 20 * * *              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;表示每天编译一次，编译时间为utc时间20点30分开始（中国时间4:30）
# 
- cron: 30 0 * * 1              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;表示每个星期一编译，编译时间为utc时间0点30分开始（中国时间8:30）
#
- cron: 30 8 */9 * *            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1号开始算，每隔9天编译一次，一个月可以编译4次了，编译时间为utc时间8点30分开始（中国时间16：30）
# 
- cron: 30 8 5,15,25 * *        &nbsp;&nbsp;&nbsp;&nbsp;表示每个月按你指定日期编译，现设的是5号-15号-25号编译，可设N天，编译时间为utc时间8点30分开始（中国时间16：30）
# 
- cron: 30 8 1-10 * *            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;这样表示每个月1至10号的每天编译一次，编译时间为utc时间8点30分开始（中国时间16：30）

#
