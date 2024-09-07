include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = BoldersRebornPrefs

$(BUNDLE_NAME)_FILES = BoldersRebornRootListController.mm BoldersRebornBaseController.mm BoldersRebornInfoController.mm BoldersRebornPortraitController.mm $(wildcard Cells/*.m)
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc -DPACKAGE_VERSION='@"$(THEOS_PACKAGE_BASE_VERSION)"' -DFINAL='$(FINAL)'

ifeq ($(THEOS_PACKAGE_SCHEME), rootless)
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc -DTHEOS_PACKAGE_SCHEME=rootless -DPACKAGE_VERSION='@"$(THEOS_PACKAGE_BASE_VERSION)"' -DFINAL='$(FINAL)'
endif

include $(THEOS_MAKE_PATH)/bundle.mk
