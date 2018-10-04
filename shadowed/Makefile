include $(THEOS)/makefiles/common.mk

export THEOS_DEVICE_IP = 192.168.0.148
export TARGET=iphone:9.2:9.2

TWEAK_NAME = Shadowed
Shadowed_FILES = Tweak.xm
Shadowed_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += shadowedprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
