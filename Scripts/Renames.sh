#!/bin/bash

#批量重名为 主机名_型号_日期
for var in $OWRT_TYPE; do
  for file in $(find ./ -type f -iname "*$var*.*"); do
    export ext=$(basename "$file" | cut -d '.' -f 2-3)
    export name=$(basename "$file" | cut -d '.' -f1 | grep -io "$var.*")
    export fullname="$OWRT_NAME"_"$name"_"$OWRT_DATE"."$ext"
    mv "$file" "$fullname"
  done
done
