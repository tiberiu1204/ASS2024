export CROSS_COMPILE = /home/tpopescu/Documents/Workspace/ASS2024/toolchain/bin/aarch64-none-linux-gnu-
TEE_TZDRAM_START=0xbdc00000
TEE_TZDRAM_SIZE=0x2000000
TEE_SHMEM_START=0xbfc00000
TEE_SHMEM_SIZE=0x400000
TEE_RAM_TOTAL_SIZE=0x2400000

OPTEE_OS_DIR=optee_os 
OPTEE_FLAGS=CFG_ARM64_core=y CFG_TEE_BENCHMARK=n CFG_UART_BASE=0x30860000 CFG_TEE_CORE_LOG_LEVEL=3 CROSS_COMPILE64=$(CROSS_COMPILE) CROSS_COMPILE=$(CROSS_COMPILE) CROSS_COMPILE_core=$(CROSS_COMPILE) CROSS+COMPILE_ta_arm64=$(CROSS_COMPILE)  DEBUG=1 O=out/arm PLATFORM=imx-mx8mqevk CFG_DDR_SIZE=0x80000000 CFG_TZDRAM_START=$(TEE_TZDRAM_START) CFG_TZDRAM_SIZE=$(TEE_TZDRAM_SIZE) CFG_TEE_SHMEM_START=$(TEE_SHMEM_START) CFG_TEE_SHMEM_SIZE=$(TEE_SHMEM_SIZE) -j $(nproc)
optee:
	cd $(OPTEE_OS_DIR) && \
	make $(OPTEE_FLAGS) && \
	cd .. && \
	cp ./optee_os/out/arm/core/tee-raw.bin ./imx-mkimage/iMX8M/ && \
	mv ./imx-mkimage/iMX8M/tee-raw.bin ./imx-mkimage/iMX8M/tee.bin
 
ATF_DIR = imx-atf
ATF_MAKE_FLAGS = SPD=opteed PLAT=imx8mq BL32_BASE=$(TEE_TZDRAM_START) BL32_SIZE=$(TEE_RAM_TOTAL_SIZE) LOG_LEVEL=40 IMX_BOOT_UART_BASE=0x30860000
atf:
	cd "$(ATF_DIR)" && \
	make $(ATF_MAKE_FLAGS)
 
UBOOT_DIR = u-boot-tn-imx
UBOOT_MAKE_FLAGS =
uboot:
	cd "$(UBOOT_DIR)" && \
	make $(UBOOT_MAKE_FLAGS)

IMX_MKIMAGE_DIR = imx-mkimage
IMX_MKIMAGE_FLAGS = SOC=iMX8M flash_evk dtbs=imx8mq-pico-pi.dtb TEE_LOAD_ADDR=$(TEE_TZDRAM_START)
UUU_PATH = mfgtools/build/uuu/
package: atf uboot optee
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

copyfit:
	sudo mount /dev/sda1 /mnt && \
	sudo cp ./staging/linux.fit /mnt && \
	sudo umount /mnt

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

.PHONY: uboot atf package buildroot linux flash fit connect optee
