#!/bin/bash

# 1. Dizin Tanımlaması
ANDROID_BUILD_TOP=$(pwd)
CHIPSET_NAME=kalama
TARGET_PRODUCT=gki
OUT_DIR="${ANDROID_BUILD_TOP}/out"

echo "========================================="
echo " Kernel Derleme Temizliği Başlatılıyor..."
echo "========================================="

# 2. Out (Çıktı) Klasörünü Temizle
if [ -d "$OUT_DIR" ]; then
    echo "--- [1/2] 'out' dizini siliniyor..."
    rm -rf "$OUT_DIR"
    rm -rf device
fi


# 3. Kernel Kaynak Kodundaki Geçici Dosyaları Temizle
echo "--- [2/2] Kernel platformu (mrproper) temizleniyor..."
if [ -d "kernel_platform/common" ]; then
    cd kernel_platform/common
    make mrproper
    cd ../..
fi

# 4. Log Dosyalarını Temizle
rm -f build_log.log

echo "========================================="
echo "✅ Temizlik Tamamlandı! Artık sıfırdan derleme yapabilirsin."
echo "========================================="
