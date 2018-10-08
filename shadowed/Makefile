include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Shadowed
Shadowed_FILES = Tweak.xm
Shadowed_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += shadowedprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
