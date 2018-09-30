include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DoubleDown
DoubleDown_FILES = Tweak.xm
DoubleDown_CFLAGS=-fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += doubledownprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
