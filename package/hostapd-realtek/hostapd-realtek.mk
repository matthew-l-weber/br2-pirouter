################################################################################
#
# hostapd
#
################################################################################

HOSTAPD_REALTEK_VERSION = 2.6
HOSTAPD_REALTEK_SITE = http://w1.fi/releases
HOSTAPD_REALTEK_SOURCE = hostapd-$(HOSTAPD_REALTEK_VERSION).tar.gz
HOSTAPD_REALTEK_PATCH = https://github.com/pritambaral/hostapd-rtl871xdrv/raw/master/rtlxdrv.patch
HOSTAPD_REALTEK_SUBDIR = hostapd
HOSTAPD_REALTEK_CONFIG = $(HOSTAPD_REALTEK_DIR)/$(HOSTAPD_REALTEK_SUBDIR)/.config
HOSTAPD_REALTEK_DEPENDENCIES = host-pkgconf
HOSTAPD_REALTEK_CFLAGS = $(TARGET_CFLAGS)
HOSTAPD_REALTEK_LICENSE = BSD-3c
HOSTAPD_REALTEK_LICENSE_FILES = README
HOSTAPD_REALTEK_CONFIG_SET =

HOSTAPD_REALTEK_CONFIG_ENABLE = \
	CONFIG_NO_VLAN \
	CONFIG_HS20 \
	CONFIG_IEEE80211AC \
	CONFIG_IEEE80211N \
	CONFIG_IEEE80211R \
	CONFIG_INTERNAL_LIBTOMMATH \
	CONFIG_INTERWORKING \
	CONFIG_NO_ACCOUNTING \
	CONFIG_NO_RADIUS

HOSTAPD_REALTEK_CONFIG_DISABLE = \
	CONFIG_EAP \
	CONFIG_DRIVER_NL80211

# Use internal crypto
HOSTAPD_REALTEK_CONFIG_DISABLE += CONFIG_EAP_PWD
HOSTAPD_REALTEK_CONFIG_EDITS += 's/\#\(CONFIG_TLS=\).*/\1internal/'

define HOSTAPD_REALTEK_CONFIGURE_CMDS
	cp $(@D)/hostapd/defconfig $(HOSTAPD_REALTEK_CONFIG)
	sed -i $(patsubst %,-e 's/^#\(%\)/\1/',$(HOSTAPD_REALTEK_CONFIG_ENABLE)) \
		$(patsubst %,-e 's/^\(%\)/#\1/',$(HOSTAPD_REALTEK_CONFIG_DISABLE)) \
		$(patsubst %,-e '1i%=y',$(HOSTAPD_REALTEK_CONFIG_SET)) \
		$(patsubst %,-e %,$(HOSTAPD_REALTEK_CONFIG_EDITS)) \
		$(HOSTAPD_REALTEK_CONFIG)
endef

define HOSTAPD_REALTEK_BUILD_CMDS
	$(TARGET_MAKE_ENV) CFLAGS="$(HOSTAPD_REALTEK_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" LIBS="$(HOSTAPD_REALTEK_LIBS)" \
		$(MAKE) CC="$(TARGET_CC)" -C $(@D)/$(HOSTAPD_REALTEK_SUBDIR)
endef

define HOSTAPD_REALTEK_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/$(HOSTAPD_REALTEK_SUBDIR)/hostapd \
		$(TARGET_DIR)/usr/sbin/hostapd_rtl
        $(INSTALL) -m 0755 -D $(@D)/$(HOSTAPD_SUBDIR)/hostapd_cli \
                $(TARGET_DIR)/usr/bin/hostapd_cli
	$(INSTALL) -m 0644 -D $(@D)/$(HOSTAPD_SUBDIR)/hostapd.conf \
		$(TARGET_DIR)/etc/hostapd_rtl.conf

endef

$(eval $(generic-package))
