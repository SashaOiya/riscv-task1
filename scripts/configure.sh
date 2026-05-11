#!/bin/bash
set -e

# Версии
KERNEL_VER="v6.8"
OPENSBI_VER="v1.2"
ROOT_DIR=$(pwd)

echo "--- Проверка зависимостей ---"
PACKAGES=""
if ! command -v qemu-system-riscv64 &> /dev/null; then
    echo "qemu-system-riscv64 не найден."
    PACKAGES="$PACKAGES qemu-system-misc"
fi

if ! command -v riscv64-linux-gnu-gcc &> /dev/null; then
    echo "riscv64-linux-gnu-gcc не найден."
    PACKAGES="$PACKAGES gcc-riscv64-linux-gnu"
fi

if [ ! -z "$PACKAGES" ]; then
    echo "Для работы необходимо установить пакеты:"
    echo "sudo apt update && sudo apt install $PACKAGES"
    exit 1
fi
echo "Все инструменты установлены."

echo "--- Настройка окружения ---"
mkdir -p patches

# Клонируем и патчим OpenSBI
if [ ! -d "opensbi" ]; then
    echo "Клонирование OpenSBI ($OPENSBI_VER)..."
    git clone --depth 1 --branch $OPENSBI_VER https://github.com/riscv-software-src/opensbi.git opensbi
    
    if [ -f "$ROOT_DIR/patches/01-opensbi-fortune.patch" ]; then
        echo "Применение патча OpenSBI..."
        cd opensbi && patch -p1 < "$ROOT_DIR/patches/01-opensbi-fortune.patch" && cd "$ROOT_DIR"
    else
        echo "Ошибка: патч 01-opensbi-fortune.patch не найден"
    fi
fi

# Клонируем и патчим Linux
if [ ! -d "linux" ]; then
    echo "Клонирование Linux Kernel ($KERNEL_VER)..."
    git clone --depth 1 --branch $KERNEL_VER https://github.com/torvalds/linux.git linux
    
    if [ -f "$ROOT_DIR/patches/02-linux-fortune.patch" ]; then
        echo "Применение патча Linux Kernel..."
        cd linux && patch -p1 < "$ROOT_DIR/patches/02-linux-fortune.patch" && cd "$ROOT_DIR"
    else
        echo "Ошибка: патч 02-linux-fortune.patch не найден"
    fi
fi

echo "--- Конфигурация завершена ---"
