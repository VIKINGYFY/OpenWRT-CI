#!/bin/bash
sed -i '$a src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default


 sed -i '$a src-git ikoolproxy   https://github.com/ilxp/luci-app-ikoolproxy' feeds.conf.default
./scripts/feeds update -a 
rm -rf feeds/smpackage/{base-files,dnsmasq,firewall*,fullconenat,libnftnl,nftables,ppp,opkg,ucl,upx,vsftpd*,miniupnpd-iptables,wireless-regdb}

rm -rf feeds/luci/applications/luci-app-openclash
cp -rf feeds/smpackage/luci-app-openclash   feeds/luci/applications/luci-app-openclash
git clone https://github.com/sirpdboy/luci-app-eqosplus package/luci-app-eqosplus

./scripts/feeds install -a  
