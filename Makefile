ARCHS = armv7 armv7s arm64
SDKVERSION = 9.0

include theos/makefiles/common.mk

TWEAK_NAME = WGradRemover
WGradRemover_FILES = Tweak.x
WGradRemover_FRAMEWORKS = UIKit


include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"