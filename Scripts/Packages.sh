#!/bin/bash

#批量移动并重命名为 主机名_型号_日期
for var in $OWRT_TYPE; do
  for file in $(find ./bin/targets/ -type f -iregex ".*\($var\).*\.\(bin\|iso\|vmdk\|img.gz\)"); do
    export ext=$(basename "$file" | cut -d '.' -f 2-3)
    export name=$(basename "$file" | cut -d '.' -f1 | grep -io "\($var\).*")
    export new_file="$OWRT_NAME"_"$name"_"$OWRT_DATE"."$ext"
    cp -rf "$file" ./upload/"$new_file"
  done
done
