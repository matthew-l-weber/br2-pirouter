include $(sort $(wildcard $(BR2_EXTERNAL_PIROUTER_PATH)/package/*/*.mk))

HOSTAPD_PATCH += https://github.com/pritambaral/hostapd-rtl871xdrv/raw/master/rtlxdrv.patch
BR_NO_CHECK_HASH_FOR += rtlxdrv.patch
HOSTAPD_CONFIG_SET += CONFIG_DRIVER_RTW
