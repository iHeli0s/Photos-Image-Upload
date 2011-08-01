ifeq ($(shell [ -f ./framework/makefiles/common.mk ] && echo 1 || echo 0),0)
all clean package install::
	git submodule update --init
	./framework/git-submodule-recur.sh init
	$(MAKE) $(MAKEFLAGS) MAKELEVEL=0 $@
else
GO_EASY_ON_ME = 1
TWEAK_NAME = PhotosImageUpload
PhotosImageUpload_FILES = Tweak.xm MBProgressHUD.m
PhotosImageUpload_FRAMEWORKS = UIKit CoreFoundation Foundation CoreGraphics QuartzCore 
include framework/makefiles/common.mk
include framework/makefiles/tweak.mk

endif
