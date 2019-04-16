#!/bin/sh
set -e

echo
echo "Setup build environment"
case "$1" in
    *"ubuntu"*)
        apt -y update && apt -y install git build-essential qt5-default libssl-dev
        ;;
    *"debian"*)
        apt -y update && apt -y install git build-essential qt5-default libssl-dev
        ;;
    *"fedora"*)
        yum -y update && yum -y install git make qt5-devel openssl-devel
        ;;
    *"opensuse"*)
        zypper -n update && zypper -n install git libQt5Core-devel libQt5Widgets-devel libopenssl-devel
        ;;
    *"archlinux"*)
        pacman -Syu --noconfirm && pacman -S --noconfirm git gcc make qt openssl
        ;;
    *)
        echo "Unknown OS"
esac

if [ -z "$QMAKE" ]; then
    QMAKE=$(command -v qmake 2>&1)
    if [ -z "$QMAKE" ]; then
        QMAKE=$(command -v qmake-qt5 2>&1)
        if [ -z "$QMAKE" ]; then
            echo "Error: qmake was not found."
            exit 1
        fi
    fi
fi

$QMAKE --version
if [ -n "$CPP" ]; then
    $CPP --version
fi

cd /effort-log || exit

echo
echo "Building debug version"
"${QMAKE}" -config debug
make -j
make clean

echo
echo "Building release version"
"${QMAKE}" -config release
make -j
make clean

echo
echo "Building debug version with encryption support"
"${QMAKE}" -config debug -config crypt
make -j
make clean

echo
echo "Building release version with encryption support"
"${QMAKE}" -config release -config crypt
make -j
make clean
