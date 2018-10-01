include $(THEOS)/makefiles/common.mk

export TARGET=iphone:9.2:9.2
export THEOS_DEVICE_IP = 192.168.0.148

TWEAK_NAME = BackgroundKill
BackgroundKill_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += backgroundkillprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
