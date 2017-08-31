define SIT_CTL_EXTRACT_CMDS
	cp $(SIT_CTL_PKGDIR)/sit-ctl.c $(@D)
endef

define SIT_CTL_BUILD_CMDS
	$(TARGET_CC) $(@D)/sit-ctl.c -o $(@D)/sit-ctl
endef

define SIT_CTL_INSTALL_TARGET_CMDS
        $(INSTALL) -m 0755 -D $(@D)/sit-ctl $(TARGET_DIR)/usr/sbin
endef

$(eval $(generic-package))
