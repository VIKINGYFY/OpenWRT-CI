#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

set -euo pipefail

GO_ROOT=$(go env GOROOT)
test -x "$GO_ROOT/bin/go"

# Use the runner's Go to bootstrap the feed's pinned host compiler.
sed -i '/^CONFIG_GOLANG_BUILD_BOOTSTRAP=/d; /^# CONFIG_GOLANG_BUILD_BOOTSTRAP is not set$/d; /^CONFIG_GOLANG_EXTERNAL_BOOTSTRAP_ROOT=/d' .config
printf '# CONFIG_GOLANG_BUILD_BOOTSTRAP is not set\nCONFIG_GOLANG_EXTERNAL_BOOTSTRAP_ROOT="%s"\n' "$GO_ROOT" >> .config

# PGO is unnecessary for the build host; keep target Python flags intact.
sed -i '/^HOST_CONFIGURE_ARGS[[:space:]]*+=/,/^$/s/--enable-optimizations/--disable-optimizations/' feeds/packages/lang/python/python3/Makefile

REPORT_DIR="${GITHUB_WORKSPACE:-$PWD}/build-reports"
mkdir -p "$REPORT_DIR"
{
	"$GO_ROOT/bin/go" version
	printf 'Go bootstrap root: %s\nHost Python PGO: disabled\n' "$GO_ROOT"
} | tee "$REPORT_DIR/host-toolchains.txt"
