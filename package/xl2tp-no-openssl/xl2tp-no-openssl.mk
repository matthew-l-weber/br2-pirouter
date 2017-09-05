################################################################################
#
# xl2tp
#
################################################################################

XL2TP_NO_OPENSSL_VERSION = v1.3.8
XL2TP_NO_OPENSSL_SITE = $(call github,xelerance,xl2tpd,$(XL2TP_NO_OPENSSL_VERSION))
XL2TP_NO_OPENSSL_SOURCE = xl2tp-$(XL2TP_NO_OPENSSL_VERSION).tar.gz
### XL2TP_NO_OPENSSL_DEPENDENCIES = libpcap openssl
XL2TP_NO_OPENSSL_DEPENDENCIES = libpcap
XL2TP_NO_OPENSSL_LICENSE = GPLv2
XL2TP_NO_OPENSSL_LICENSE_FILES = LICENSE

ifeq ($(BR2_STATIC_LIBS),y)
XL2TP_NO_OPENSSL_LDLIBS = LDLIBS="`$(STAGING_DIR)/usr/bin/pcap-config --static --additional-libs`"
endif

define XL2TP_NO_OPENSSL_BUILD_CMDS
	$(SED) 's/ -O2 //' $(@D)/Makefile
	$(TARGET_CONFIGURE_OPTS) $(MAKE) $(XL2TP_NO_OPENSSL_LDLIBS) -C $(@D)
endef

define XL2TP_NO_OPENSSL_INSTALL_TARGET_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) DESTDIR=$(TARGET_DIR) PREFIX=/usr -C $(@D) install
endef

$(eval $(generic-package))
