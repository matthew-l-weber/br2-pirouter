################################################################################
#
# hostapd
#
################################################################################

HOSTAPD_MY_VERSION = 2.6
HOSTAPD_MY_SITE = http://hostap.epitest.fi/releases
HOSTAPD_MY_SOURCE = hostapd-$(HOSTAPD_MY_VERSION).tar.gz
HOSTAPD_MY_PATCH = https://github.com/pritambaral/hostapd-rtl871xdrv/raw/master/rtlxdrv.patch
HOSTAPD_MY_SUBDIR = hostapd
HOSTAPD_MY_CONFIG = $(HOSTAPD_MY_DIR)/$(HOSTAPD_MY_SUBDIR)/.config
HOSTAPD_MY_DEPENDENCIES = host-pkgconf
HOSTAPD_MY_CFLAGS = $(TARGET_CFLAGS)
HOSTAPD_MY_LICENSE = BSD-3c
HOSTAPD_MY_LICENSE_FILES = README
HOSTAPD_MY_CONFIG_SET =

HOSTAPD_MY_CONFIG_ENABLE = \
	CONFIG_NO_VLAN \
	CONFIG_HS20 \
	CONFIG_IEEE80211AC \
	CONFIG_IEEE80211N \
	CONFIG_IEEE80211R \
	CONFIG_INTERNAL_LIBTOMMATH \
	CONFIG_INTERWORKING \
	CONFIG_NO_ACCOUNTING \
	CONFIG_NO_RADIUS

HOSTAPD_MY_CONFIG_DISABLE = \
	CONFIG_EAP \
	CONFIG_DRIVER_NL80211

# Use internal crypto
HOSTAPD_MY_CONFIG_DISABLE += CONFIG_EAP_PWD
HOSTAPD_MY_CONFIG_EDITS += 's/\#\(CONFIG_TLS=\).*/\1internal/'

define HOSTAPD_MY_CONFIGURE_CMDS
	cp $(@D)/hostapd/defconfig $(HOSTAPD_MY_CONFIG)
	sed -i $(patsubst %,-e 's/^#\(%\)/\1/',$(HOSTAPD_MY_CONFIG_ENABLE)) \
		$(patsubst %,-e 's/^\(%\)/#\1/',$(HOSTAPD_MY_CONFIG_DISABLE)) \
		$(patsubst %,-e '1i%=y',$(HOSTAPD_MY_CONFIG_SET)) \
		$(patsubst %,-e %,$(HOSTAPD_MY_CONFIG_EDITS)) \
		$(HOSTAPD_MY_CONFIG)
endef

define HOSTAPD_MY_BUILD_CMDS
	$(TARGET_MAKE_ENV) CFLAGS="$(HOSTAPD_MY_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" LIBS="$(HOSTAPD_MY_LIBS)" \
		$(MAKE) CC="$(TARGET_CC)" -C $(@D)/$(HOSTAPD_MY_SUBDIR)
endef

define HOSTAPD_MY_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/$(HOSTAPD_MY_SUBDIR)/hostapd \
		$(TARGET_DIR)/usr/sbin/hostapd_rtl
endef

$(eval $(generic-package))
