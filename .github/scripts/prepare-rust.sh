#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

set -euo pipefail

RUST_FEED="$PWD/feeds/packages/lang/rust"
RUST_MAKEFILE="$RUST_FEED/Makefile"
REPORT_DIR="${GITHUB_WORKSPACE:-$PWD}/build-reports"
OPENWRT_TOPDIR=$PWD
mkdir -p "$REPORT_DIR"

# Ask the feed for its target triple so CI and OpenWrt use the same mapping.
RUST_TARGET=$(make --no-print-directory -s -f - TOPDIR="$PWD" ci-rust-target <<'MAKE'
include $(TOPDIR)/rules.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-values.mk
.PHONY: ci-rust-target
ci-rust-target:
	@printf '%s\n' '$(RUSTC_TARGET_ARCH)'
MAKE
)
RUSTUP_BIN=$(command -v rustup || true)
if [ -z "$RUSTUP_BIN" ]; then
	for candidate in "$HOME/.cargo/bin/rustup" /usr/bin/rustup; do
		if [ -x "$candidate" ]; then RUSTUP_BIN=$candidate; break; fi
	done
fi
if [ -z "$RUSTUP_BIN" ]; then
	echo "rustup is missing from the GitHub runner" >&2
	exit 1
fi
PATH="$(dirname "$RUSTUP_BIN"):$PATH"
export PATH
RUST_TOOLCHAIN=$(rustup show active-toolchain | awk '{print $1}')
printf 'Rust toolchain: %s\nRust target: %s\n' "$RUST_TOOLCHAIN" "$RUST_TARGET" | tee "$REPORT_DIR/rust-toolchain.txt"

# Read rust/host paths with the same build context as package/feeds/packages/rust.
readarray -t RUST_PATHS < <(cd "$RUST_FEED" && make --no-print-directory -s -f - \
	TOPDIR="$OPENWRT_TOPDIR" BUILD_SUBDIR=package/feeds/packages/rust print-rust-paths 2>/dev/null <<'MAKE'
include Makefile
.PHONY: print-rust-paths
print-rust-paths:
	@printf '%s\n' "STAGING_DIR=$(STAGING_DIR)" "HOST_BUILD_DIR=$(HOST_BUILD_DIR)" "HOST_STAMP_PREPARED=$(HOST_STAMP_PREPARED)" "HOST_STAMP_CONFIGURED=$(HOST_STAMP_CONFIGURED)" "HOST_STAMP_BUILT=$(HOST_STAMP_BUILT)" "HOST_STAMP_INSTALLED=$(HOST_STAMP_INSTALLED)"
MAKE
)
for path_line in "${RUST_PATHS[@]}"; do
	case "$path_line" in
		STAGING_DIR=*) STAGING_DIR=${path_line#*=} ;;
		HOST_BUILD_DIR=*) HOST_BUILD_DIR=${path_line#*=} ;;
		HOST_STAMP_PREPARED=*) HOST_STAMP_PREPARED=${path_line#*=} ;;
		HOST_STAMP_CONFIGURED=*) HOST_STAMP_CONFIGURED=${path_line#*=} ;;
		HOST_STAMP_BUILT=*) HOST_STAMP_BUILT=${path_line#*=} ;;
		HOST_STAMP_INSTALLED=*) HOST_STAMP_INSTALLED=${path_line#*=} ;;
	esac
done
for path_name in STAGING_DIR HOST_BUILD_DIR HOST_STAMP_PREPARED HOST_STAMP_CONFIGURED HOST_STAMP_BUILT HOST_STAMP_INSTALLED; do
	if [ -z "${!path_name:-}" ]; then
		echo "OpenWrt did not expose $path_name for rust/host" >&2
		exit 1
	fi
done

rustup target add --toolchain "$RUST_TOOLCHAIN" "$RUST_TARGET"
RUST_ROOT=$(rustup run "$RUST_TOOLCHAIN" rustc --print sysroot)
test -d "$RUST_ROOT/lib/rustlib/$RUST_TARGET/lib"

# Reuse the runner compiler for OpenWrt's rust/host dependency.
RUST_STAGING="$STAGING_DIR/host"
mkdir -p "$RUST_STAGING/bin" "$(dirname "$HOST_STAMP_INSTALLED")" "$HOST_BUILD_DIR"
for tool in cargo rustc rustdoc; do
	[ -x "$RUST_ROOT/bin/$tool" ] || { echo "Missing preinstalled Rust tool: $tool" >&2; exit 1; }
	ln -sfn "$RUST_ROOT/bin/$tool" "$RUST_STAGING/bin/$tool"
done
touch "$HOST_STAMP_PREPARED" "$HOST_STAMP_CONFIGURED" "$HOST_STAMP_BUILT" "$HOST_STAMP_INSTALLED"
"$RUST_STAGING/bin/rustc" --version | tee -a "$REPORT_DIR/rust-toolchain.txt"
echo "Using runner Rust $RUST_TOOLCHAIN for $RUST_TARGET" | tee -a "$REPORT_DIR/rust-toolchain.txt"
sha256sum "$RUST_MAKEFILE" >> "$REPORT_DIR/rust-toolchain.txt"
