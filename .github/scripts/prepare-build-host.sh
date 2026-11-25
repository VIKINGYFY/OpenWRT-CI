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
PYTHON_MAKEFILE=feeds/packages/lang/python/python3/Makefile
if [ -f "$PYTHON_MAKEFILE" ]; then
	sed -i '/^HOST_CONFIGURE_ARGS[[:space:]]*+=/,/^$/s/--enable-optimizations/--disable-optimizations/' "$PYTHON_MAKEFILE"
	HOST_PYTHON_ARGS=$(make --no-print-directory -s \
		-C feeds/packages/lang/python/python3 -f Makefile -f - TOPDIR="$PWD" ci-host-python-args <<'MAKE'
.PHONY: ci-host-python-args
ci-host-python-args:
	@printf '%s\n' '$(HOST_CONFIGURE_ARGS)'
MAKE
)
	case " $HOST_PYTHON_ARGS " in
		*" --enable-optimizations "*)
			echo "failed to disable host Python PGO" >&2
			exit 1
			;;
		*" --disable-optimizations "*) ;;
		*)
			echo "host Python configure arguments do not expose an optimization setting" >&2
			exit 1
			;;
	esac
fi

LLVM_ROOT=$(llvm-config --prefix)
for tool in clang llc opt llvm-dis llvm-strip; do
	test -x "$LLVM_ROOT/bin/$tool"
done
LLVM_SMOKE="${RUNNER_TEMP:-/tmp}/wrt-bpf-smoke"
mkdir -p "$LLVM_SMOKE"
printf 'int wrt_bpf_smoke(void) { return 0; }\n' > "$LLVM_SMOKE/smoke.c"
"$LLVM_ROOT/bin/clang" --target=bpfel -O2 -emit-llvm -c \
	"$LLVM_SMOKE/smoke.c" -o "$LLVM_SMOKE/smoke.bc"
"$LLVM_ROOT/bin/opt" -O2 -mtriple=bpfel \
	< "$LLVM_SMOKE/smoke.bc" > "$LLVM_SMOKE/smoke.opt"
"$LLVM_ROOT/bin/llvm-dis" \
	< "$LLVM_SMOKE/smoke.opt" > "$LLVM_SMOKE/smoke.S"
"$LLVM_ROOT/bin/llc" -march=bpfel -mcpu=v3 -filetype=obj \
	-o "$LLVM_SMOKE/smoke.o" < "$LLVM_SMOKE/smoke.S"
"$LLVM_ROOT/bin/llvm-strip" --strip-debug "$LLVM_SMOKE/smoke.o"

# Use one host LLVM installation for every BPF build tool on all targets.
sed -i '/^CONFIG_BPF_TOOLCHAIN_/d; /^# CONFIG_BPF_TOOLCHAIN_.* is not set$/d' .config
printf 'CONFIG_BPF_TOOLCHAIN_HOST=y\nCONFIG_BPF_TOOLCHAIN_HOST_PATH="%s"\n' "$LLVM_ROOT" >> .config

REPORT_DIR="${GITHUB_WORKSPACE:-$PWD}/build-reports"
mkdir -p "$REPORT_DIR"
{
	"$GO_ROOT/bin/go" version
	printf 'Go bootstrap root: %s\n' "$GO_ROOT"
	if [ -n "${HOST_PYTHON_ARGS:-}" ]; then
		printf 'Host Python PGO: disabled\n'
	else
		printf 'Host Python PGO: not applicable\n'
	fi
	printf 'BPF LLVM prefix: %s\n' "$LLVM_ROOT"
	"$LLVM_ROOT/bin/clang" --version
} | tee "$REPORT_DIR/host-toolchains.txt"
