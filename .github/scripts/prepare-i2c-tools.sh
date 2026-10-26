#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

set -euo pipefail

I2C_MAKEFILE=feeds/packages/utils/i2c-tools/Makefile
test -f "$I2C_MAKEFILE"

# Build the Python SMBus binding only when its package is selected. The C
# tools remain available for device profiles that only install i2c-tools.
if ! grep -Fqx 'PKG_CONFIG_DEPENDS:=CONFIG_PACKAGE_python3-smbus' "$I2C_MAKEFILE"; then
	# Keep the Make expressions literal; they are intentionally not shell-expanded.
	# shellcheck disable=SC2016
	sed -i \
		-e 's/^PKG_BUILD_DEPENDS:=python-setuptools\/host$/PKG_CONFIG_DEPENDS:=CONFIG_PACKAGE_python3-smbus\nPKG_BUILD_DEPENDS:=PACKAGE_python3-smbus:python-setuptools\/host/' \
		-e 's/^\t$(call Py3Build\/Compile)$/\t$(if $(CONFIG_PACKAGE_python3-smbus),$(call Py3Build\/Compile))/' \
		-e 's/^\t$(call Py3Build\/Install)$/\t$(if $(CONFIG_PACKAGE_python3-smbus),$(call Py3Build\/Install))/' \
		-e 's/^  DEPENDS:=+libi2c +python3-light$/  DEPENDS:=+libi2c +PACKAGE_python3-smbus:python3-light/' \
		"$I2C_MAKEFILE"
fi

grep -Fqx 'PKG_CONFIG_DEPENDS:=CONFIG_PACKAGE_python3-smbus' "$I2C_MAKEFILE"
grep -Fqx 'PKG_BUILD_DEPENDS:=PACKAGE_python3-smbus:python-setuptools/host' "$I2C_MAKEFILE"
grep -Fqx '  DEPENDS:=+libi2c +PACKAGE_python3-smbus:python3-light' "$I2C_MAKEFILE"
grep -Fqx $'\t$(if $(CONFIG_PACKAGE_python3-smbus),$(call Py3Build/Compile))' "$I2C_MAKEFILE"
grep -Fqx $'\t$(if $(CONFIG_PACKAGE_python3-smbus),$(call Py3Build/Install))' "$I2C_MAKEFILE"
