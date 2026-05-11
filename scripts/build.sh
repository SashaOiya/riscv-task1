#!/bin/bash
set -e

ARCH=riscv
CROSS_COMPILE=riscv64-linux-gnu-

echo "--- Сборка OpenSBI ---"
cd opensbi
make CROSS_COMPILE=$CROSS_COMPILE PLATFORM=generic -j$(nproc)
cd ..

echo "--- Сборка ядра Linux ---"
cd linux
if [ ! -f .config ]; then
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE defconfig
fi
make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE -j$(nproc) Image
cd ..

echo "Сборка всех компонентов завершена."