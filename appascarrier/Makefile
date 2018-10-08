include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AppAsCarrier
AppAsCarrier_FILES = Tweak.xm
AppAsCarrier_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
