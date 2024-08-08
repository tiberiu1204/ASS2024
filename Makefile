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
UUU_PATH = mfgtools/build/uuu/
package: atf uboot
	./script.sh && \
	cd "$(IMX_MKIMAGE_DIR)" && \
	make $(IMX_MKIMAGE_FLAGS) && \
	cd .. && \
	cp "$(IMX_MKIMAGE_DIR)/iMX8M/flash.bin" ./ && \
	cp "$(UUU_PATH)/uuu" ./

flash: package
	sudo ./uuu -b spl flash.bin

fit: linux buildroot
	cd ./staging && \
	mkimage -f linux.its linux.fit

LINUX_DIR=linux
linux:
	cd "$(LINUX_DIR)" && \
	make defconfig ARCH=arm64 && \
	make ARCH=arm64 -j 24 && \
	cd .. && \
	cp ./linux/arch/arm64/boot/dts/freescale/imx8mq-pico-pi.dtb ./staging/ && \
	cp ./linux/arch/arm64/boot/Image ./staging/

BUILDROOT_DIR=buildroot
buildroot:
	cd "$(BUILDROOT_DIR)" && \
	make -j 24 && \
	cd .. && \
	cp ./buildroot/output/images/rootfs.cpio ./staging/

connect:
	sudo picocom -b 115200 /dev/ttyUSB0

.PHONY: uboot atf package buildroot linux flash fit connect
