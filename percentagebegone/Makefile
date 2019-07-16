include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PercentageBeGone
PercentageBeGone_FILES = Tweak.xm
PercentageBeGone_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
