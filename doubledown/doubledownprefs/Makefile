include $(THEOS)/makefiles/common.mk

export TARGET = iphone:9.2:9.2

BUNDLE_NAME = DoubleDownPrefs
DoubleDownPrefs_FILES = XXXRootListController.m
DoubleDownPrefs_INSTALL_PATH = /Library/PreferenceBundles
DoubleDownPrefs_FRAMEWORKS = UIKit
DoubleDownPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DoubleDownPrefs.plist$(ECHO_END)
