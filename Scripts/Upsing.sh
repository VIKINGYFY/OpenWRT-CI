#!/bin/bash

singver=$(curl "https://api.github.com/repos/SagerNet/sing-box/tags" | jq -r '.[0].name')

wget -P ./ https://codeload.github.com/SagerNet/sing-box/tar.gz/$singver

singsha=$(sha256sum ./$singver | cut -b -64)

rm ./$singver

sed -i "/^UPDATE_VERSION\s/c\UPDATE_VERSION \"sing-box\" \"$singver\" \"$singsha\"" ./Scripts/Packages.sh
