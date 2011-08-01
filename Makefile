ifeq ($(shell [ -f ./framework/makefiles/common.mk ] && echo 1 || echo 0),0)
all clean package install::
	git submodule update --init
	./framework/git-submodule-recur.sh init
	$(MAKE) $(MAKEFLAGS) MAKELEVEL=0 $@
else

TWEAK_NAME = PhotosImageUpload
PhotosImageUpload_OBJC_FILES = Tweak.m

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk

endif
