export CROSS_COMPILE = /home/tpopescu/Documents/Workspace/ASS2024/toolchain/bin/aarch64-none-linux-gnu-
 
ATF_DIR = imx-atf
ATF_MAKE_FLAGS = SPD=none PLAT=imx8mq
atf:
	cd "$(ATF_DIR)" && \
	make $(ATF_MAKE_FLAGS)
 
UBOOT_DIR = u-boot-tn-imx
UBOOT_MAKE_FLAGS =
uboot:
	cd "$(UBOOT_DIR)" && \
	make $(UBOOT_MAKE_FLAGS)

IMX_MKIMAGE_DIR = imx-mkimage
IMX_MKIMAGE_FLAGS = SOC=iMX8M flash_evk dtbs=imx8mq-pico-pi.dtb
package:
	./script.sh && \
	cd "$(IMX_MKIMAGE_DIR)" && \
	make $(IMX_MKIMAGE_FLAGS)
 
.PHONY: uboot atf package
