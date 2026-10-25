# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

# Keep OpenWrt's normal host stamps, without source download or bootstrap.
PKG_SOURCE:=
PKG_SOURCE_URL:=

define Host/Prepare
endef

define Host/Configure
endef

define Host/Compile
	"$(CI_RUST_ROOT)/bin/rustc" --version
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR)/host/bin
	ln -sfn "$(CI_RUST_ROOT)/bin/cargo" "$(STAGING_DIR)/host/bin/cargo"
	ln -sfn "$(CI_RUST_ROOT)/bin/rustc" "$(STAGING_DIR)/host/bin/rustc"
	ln -sfn "$(CI_RUST_ROOT)/bin/rustdoc" "$(STAGING_DIR)/host/bin/rustdoc"
endef

define Host/Uninstall
	rm -f $(addprefix $(STAGING_DIR)/host/bin/,cargo rustc rustdoc)
endef
