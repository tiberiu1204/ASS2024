export CROSS_COMPILE = /home/tpopescu/Documents/Workspace/ASS2024/toolchain/bin/aarch64-none-linux-gnu-
 
ATF_DIR = imx-atf
ATF_MAKE_FLAGS = SPD=none PLAT=TODO
atf:
	cd "$(ATF_DIR)" && \
	make $(ATF_MAKE_FLAGS)
 
UBOOT_DIR = u-boot-tn-imx
UBOOT_MAKE_FLAGS =
uboot:
	cd "$(UBOOT_DIR)" && \
	make $(UBOOT_MAKE_FLAGS)
 
.PHONY: uboot atf
