include $(THEOS)/makefiles/common.mk

export TARGET=iphone:9.2:9.2

BUNDLE_NAME = ShadowedPrefs
ShadowedPrefs_FILES = XXXRootListController.m
ShadowedPrefs_INSTALL_PATH = /Library/PreferenceBundles
ShadowedPrefs_FRAMEWORKS = UIKit
ShadowedPrefs_LIBRARIES = applist
ShadowedPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ShadowedPrefs.plist$(ECHO_END)
