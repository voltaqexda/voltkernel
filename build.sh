#!/bin/bash

#1. target config
BUILD_TARGET=dm3q_eur_openx
export MODEL=$(echo $BUILD_TARGET | cut -d'_' -f1)
export PROJECT_NAME=${MODEL}
export REGION=$(echo $BUILD_TARGET | cut -d'_' -f2)
export CARRIER=$(echo $BUILD_TARGET | cut -d'_' -f3)
export TARGET_BUILD_VARIANT=user
		
		
#2. sm8550 common config
CHIPSET_NAME=kalama
export ANDROID_BUILD_TOP=$(pwd)
export TARGET_PRODUCT=gki
export TARGET_BOARD_PLATFORM=gki
export ANDROID_PRODUCT_OUT=${ANDROID_BUILD_TOP}/out/target/product/${MODEL}
export OUT_DIR=${ANDROID_BUILD_TOP}/out/msm-kernel-${CHIPSET_NAME}-${TARGET_PRODUCT}
export DIST_DIR=${ANDROID_BUILD_TOP}/out/msm-kernel-${CHIPSET_NAME}-${TARGET_PRODUCT}/dist
export MERGE_CONFIG="${ANDROID_BUILD_TOP}/kernel_platform/common/scripts/kconfig/merge_config.sh"

mkdir -p "${DIST_DIR}"

#3. Cleaning previous kernel compilation
rm -rf ${OUT_DIR}/gki_kernel/dist

# for Lcd(techpack) driver build
export KBUILD_EXTRA_SYMBOLS="${ANDROID_BUILD_TOP}/out/vendor/qcom/opensource/mmrm-driver/Module.symvers \
		${ANDROID_BUILD_TOP}/out/vendor/qcom/opensource/mm-drivers/hw_fence/Module.symvers \
		${ANDROID_BUILD_TOP}/out/vendor/qcom/opensource/mm-drivers/sync_fence/Module.symvers \
		${ANDROID_BUILD_TOP}/out/vendor/qcom/opensource/mm-drivers/msm_ext_display/Module.symvers \
		${ANDROID_BUILD_TOP}/out/vendor/qcom/opensource/securemsm-kernel/Module.symvers \
"

# for Audio(techpack) driver build
export MODNAME=audio_dlkm

export KBUILD_EXT_MODULES="../vendor/qcom/opensource/mm-drivers/msm_ext_display \
  ../vendor/qcom/opensource/mm-drivers/sync_fence \
  ../vendor/qcom/opensource/mm-drivers/hw_fence \
  ../vendor/qcom/opensource/mmrm-driver \
  ../vendor/qcom/opensource/securemsm-kernel \
  ../vendor/qcom/opensource/display-drivers/msm \
  ../vendor/qcom/opensource/audio-kernel \
  ../vendor/qcom/opensource/camera-kernel \
  "

# Build Setting
export GKI_KERNEL_BUILD_OPTIONS="SKIP_MRPROPER=1 LTO=thin HERMETIC_TOOLCHAIN=0 KMI_SYMBOL_LIST_STRICT_MODE=0 RECOMPILE_KERNEL=1 BUILD_BOOT_IMG=1 SKIP_VENDOR_BOOT=1 KERNEL_BINARY=Image BOOT_IMAGE_HEADER_VERSION=4 AVB_SIGN_BOOT_IMG=1 AVB_BOOT_PARTITION_SIZE=100663296 AVB_BOOT_ALGORITHM=SHA256_RSA4096 AVB_BOOT_PARTITION_NAME=boot"

# MKBOOTIMG Setting
export MKBOOTIMG_EXTRA_ARGS=" \
    --os_version 13.0.0 \
    --os_patch_level 2023-10 \
    --pagesize 4096"

# ─────────────────────────────────────────
# 3. TOOLCHAIN DANS LE PATH
# ─────────────────────────────────────────
export CLANG_DIR=/home/v/Desktop/toolchain/prebuilts/clang/host/linux-x86/clang-r450784e/bin
export PATH=$CLANG_DIR:$PATH

# ─────────────────────────────────────────
# 6. NETTOYAGE resolve_btfids (cache cassé)
# ─────────────────────────────────────────
rm -rf ${OUT_DIR}/gki_kernel/common/tools/bpf/resolve_btfids
rm -rf ${OUT_DIR}/msm-kernel/tools/bpf/resolve_btfids
mkdir -p /home/v/Desktop/voltkernel/out/target/product/dm3q
mkdir -p /home/v/Desktop/voltkernel/out/msm-kernel-kalama-gki/dist
# ─────────────────────────────────────────
# 7. LANCEMENT DU BUILD
# ─────────────────────────────────────────
echo ""
echo "========================================="
echo " Starting to build GKI kernel"
echo "========================================="
export CONFIG_HEADERS_INSTALL=n
export CONFIG_HEADERS_CHECK=n

( env ${GKI_KERNEL_BUILD_OPTIONS} ${ANDROID_BUILD_TOP}/kernel_platform/build/android/prepare_vendor.sh sec ${TARGET_PRODUCT} || exit 1) 2>&1 | tee build_log.log


printf "\n\n\n"
echo "##############################################################################"
echo "# Compiled kernel informations :"
echo ""
strings /home/v/Desktop/voltkernel/out/msm-kernel-kalama-gki/gki_kernel/dist/Image | grep -i "linux version" | head -1
echo ""

mv /home/v/Desktop/voltkernel/out/msm-kernel-kalama-gki/gki_kernel/dist/Image.gz /home/v/Downloads/Image.gz



echo "#######################FINISHED############################"
