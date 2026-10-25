#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

set -euo pipefail

REPORT_DIR="${GITHUB_WORKSPACE:-$PWD}/build-reports"
mkdir -p "$REPORT_DIR"

git rev-parse HEAD > "$REPORT_DIR/source-commit.txt"
if [ -f .config ]; then
	cp .config "$REPORT_DIR/config.txt"
fi
./scripts/feeds list -fs > "$REPORT_DIR/feeds.buildinfo"

for TIME_LOG in "$REPORT_DIR"/*.tsv; do
	[ -f "$TIME_LOG" ] || continue
	if [ -f ./scripts/build-time-report.pl ]; then
		./scripts/build-time-report.pl -n 30 "$TIME_LOG" > "${TIME_LOG%.tsv}-report.txt" ||
			echo "Build time report unavailable for $TIME_LOG; raw events retained"
	fi
done

if [ -x ./staging_dir/host/bin/ccache ]; then
	./staging_dir/host/bin/ccache -s > "$REPORT_DIR/ccache.txt"
fi
