include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SnapKill
SnapKill_FILES = Tweak.xm
SnapKill_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
