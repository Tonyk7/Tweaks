include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BackgroundKill
BackgroundKill_FILES = Tweak.xm
BackgroundKill_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += backgroundkillprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
