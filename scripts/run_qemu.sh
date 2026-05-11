#!/bin/bash
set -e

# Пути
ROOT_DIR=$(pwd)
BUILD_DIR=$ROOT_DIR/build
KERNEL_IMG=$ROOT_DIR/linux/arch/riscv/boot/Image
OPENSBI_FW=$ROOT_DIR/opensbi/build/platform/generic/firmware/fw_jump.bin
CROSS_COMPILE=riscv64-linux-gnu-

# 1. Проверка тулчейна (подсос библиотек)
if ! command -v ${CROSS_COMPILE}gcc &> /dev/null; then
    echo "Ошибка: Кросс-компилятор $CROSS_COMPILE не найден!"
    echo "Выполни: sudo apt install gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu"
    exit 1
fi

# 2. Сборка теста (get_mcycle.c)
echo "--- Сборка приложения ---"
mkdir -p app
${CROSS_COMPILE}gcc -static "$ROOT_DIR/get_mcycle.c" -o "$ROOT_DIR/app/get_mcycle"

# 3. Создание Initramfs
echo "--- Упаковка образа ---"
INIT_DIR=$BUILD_DIR/initramfs
rm -rf "$INIT_DIR"
mkdir -p "$INIT_DIR"/{bin,dev,proc,sys}
cp "$ROOT_DIR/app/get_mcycle" "$INIT_DIR/init"
chmod +x "$INIT_DIR/init"

cd "$INIT_DIR"
find . | cpio -o -H newc --owner root:root | gzip > "$BUILD_DIR/initramfs.cpio.gz"
cd "$ROOT_DIR"

# 4. Запуск QEMU
echo "--- Запуск эмуляции ---"
qemu-system-riscv64 \
    -nographic \
    -machine virt \
    -m 512M \
    -bios "$OPENSBI_FW" \
    -kernel "$KERNEL_IMG" \
    -initrd "$BUILD_DIR/initramfs.cpio.gz" \
    -append "console=ttyS0 root=/dev/ram0 rdinit=/init"