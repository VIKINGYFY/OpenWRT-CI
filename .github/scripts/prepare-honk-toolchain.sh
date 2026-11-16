#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

set -euo pipefail

[ -d ./package/honk/src ] || exit 0
if ! grep -Eq '^CONFIG_PACKAGE_honk=[ym]$' .config; then
	echo "honk is disabled in the final configuration; skipping its toolchains"
	exit 0
fi

# Check after defconfig: Kconfig can silently remove unavailable options.
for option in KERNEL_DEBUG_INFO KERNEL_DEBUG_INFO_BTF KERNEL_CGROUPS \
	KERNEL_CGROUP_BPF KERNEL_NAMESPACES KERNEL_NET_NS PACKAGE_vmlinux-btf-builtin; do
	if ! grep -Fqx "CONFIG_$option=y" .config; then
		echo "honk: CONFIG_$option=y is required" >&2
		exit 1
	fi
done

# Configuration-only runs validate the options without downloading tools.
[ "${WRT_TEST:-false}" != true ] || exit 0

HONK_SRC="$PWD/package/honk/src"
RUST_STABLE=$(sed -n 's/^channel[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$HONK_SRC/rust-toolchain.toml")
RUST_NIGHTLY=$(sed -n 's/^channel[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$HONK_SRC/crates/honk-ebpf/rust-toolchain.toml")
test -n "$RUST_STABLE"
test -n "$RUST_NIGHTLY"

RUSTUP_BIN=$(command -v rustup || true)
if [ -z "$RUSTUP_BIN" ]; then
	RUSTUP_BIN="$HOME/.cargo/bin/rustup"
	test -x "$RUSTUP_BIN"
fi
RUST_BIN=$(dirname "$RUSTUP_BIN")
export PATH="$RUST_BIN:$PATH"
rustup toolchain install "$RUST_STABLE" --profile minimal \
	--target aarch64-unknown-linux-musl
rustup toolchain install "$RUST_NIGHTLY" --profile minimal \
	--component rust-src --component llvm-tools

# Use the linker archive and checksum pinned by this honk release.
# shellcheck source=/dev/null
source "$HONK_SRC/.github/ci/pins.env"
test -n "$BPF_LINKER_VERSION"
test -n "$BPF_LINKER_SHA256"
LINKER_DIR="${RUNNER_TEMP:-/tmp}/wrt-honk-linker"
mkdir -p "$LINKER_DIR"
curl -fsSL --retry 3 -o "$LINKER_DIR/bpf-linker.tar.zst" \
	"https://github.com/aya-rs/bpf-linker/releases/download/v$BPF_LINKER_VERSION/bpf-linker-x86_64-unknown-linux-musl.tar.zst"
printf '%s  %s\n' "$BPF_LINKER_SHA256" "$LINKER_DIR/bpf-linker.tar.zst" | sha256sum -c -
zstd -dc "$LINKER_DIR/bpf-linker.tar.zst" | tar -xf - -C "$LINKER_DIR"
export PATH="$LINKER_DIR:$PATH"
printf '%s\n%s\n' "$RUST_BIN" "$LINKER_DIR" >> "$GITHUB_PATH"
printf 'HONK_TOOLCHAIN_PATH=%s:%s\n' "$RUST_BIN" "$LINKER_DIR" >> "$GITHUB_ENV"

REPORT_DIR="$GITHUB_WORKSPACE/build-reports"
mkdir -p "$REPORT_DIR"
{
	rustup run "$RUST_STABLE" rustc --version
	rustup run "$RUST_NIGHTLY" rustc --version
	bpf-linker --version
} | tee "$REPORT_DIR/honk-toolchains.txt"
