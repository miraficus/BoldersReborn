export TARGET := iphone:clang:latest:14.0
export ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BoldersReborn

BoldersReborn_FILES = Tweak.xm
BoldersReborn_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += boldersrebornprefs
include $(THEOS_MAKE_PATH)/aggregate.mk