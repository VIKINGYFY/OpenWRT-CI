#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

set -euo pipefail

CONFIG_FILE="$GITHUB_WORKSPACE/Config/$WRT_CONFIG.txt"
if ! grep -Eq '^CONFIG_PACKAGE_(honk|luci-app-honk)=[ym]$' "$CONFIG_FILE"; then
	exit 0
fi

# The official feed expects honk/src beside its Makefile, rather than
# downloading the engine through OpenWrt's normal PKG_SOURCE mechanism.
FEED_DIR="${RUNNER_TEMP:-/tmp}/wrt-honk-feed"
git clone --depth=1 --single-branch --branch main \
	https://github.com/daeuniverse/openwrt-packages.git "$FEED_DIR"
for package in honk luci-app-honk luci-lib-daeuniverse vmlinux-btf-builtin; do
	cp -R "$FEED_DIR/$package" "./package/$package"
done

# Follow the release named by the package recipe so its package version,
# embedded version, Rust toolchains and dashboard pins agree.
HONK_MAKEFILE=./package/honk/Makefile
# shellcheck disable=SC2016 # Parse literal Make expressions.
HONK_GIT_TAG=$(sed -n 's/^HONK_GIT_TAG:=$(if $(HONK_GIT_TAG),$(HONK_GIT_TAG),\([^)]*\))$/\1/p' "$HONK_MAKEFILE")
if [[ ! "$HONK_GIT_TAG" =~ ^v[0-9][0-9A-Za-z.+-]*$ ]]; then
	echo "honk: cannot resolve the upstream release from $HONK_MAKEFILE" >&2
	exit 1
fi
git clone --depth=1 --single-branch --branch "$HONK_GIT_TAG" \
	https://github.com/daeuniverse/honk.git ./package/honk/src

# Use this kernel's BTF and keep rustup's proxies ahead of the feed's host
# cargo/rustc, so honk's nested cargo +nightly invocation selects its pin.
python3 - "$HONK_MAKEFILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
recipe = path.read_text()
dependency = '+vmlinux-btf '
compile_env = '\tHONK_SRC="$(PKG_BUILD_DIR)" \\\n'
if dependency not in recipe or compile_env not in recipe:
    sys.exit('honk: upstream package recipe changed; review the CI integration')
recipe = recipe.replace(dependency, '+vmlinux-btf-builtin ')
recipe = recipe.replace(compile_env, '\tPATH="$(HONK_TOOLCHAIN_PATH):$(PATH)" \\\n' + compile_env)
path.write_text(recipe)
PY

REPORT_DIR="$GITHUB_WORKSPACE/build-reports"
mkdir -p "$REPORT_DIR"
{
	printf 'honk release: %s\n' "$HONK_GIT_TAG"
	printf 'honk commit: %s\n' "$(git -C ./package/honk/src rev-parse HEAD)"
	printf 'package feed commit: %s\n' "$(git -C "$FEED_DIR" rev-parse HEAD)"
} | tee "$REPORT_DIR/honk-source.txt"
