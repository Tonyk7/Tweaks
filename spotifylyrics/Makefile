export TARGET = iphone:11.2:11.2
export ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = Spotify

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpotifyLyrics

SpotifyLyrics_FILES = Tweak.x
SpotifyLyrics_PRIVATE_FRAMEWORKS = MediaRemote
SpotifyLyrics_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
