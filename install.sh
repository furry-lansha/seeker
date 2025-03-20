#!/usr/bin/env bash

# 定义日志和数据库目录
LOG_DIR=$PWD/logs
DB_DIR=$PWD/db
ILOG=$LOG_DIR/install.log

# 创建必要目录
mkdir -p $LOG_DIR $DB_DIR

# 状态检查函数
status_check() {
    if [ $? -eq 0 ]
    then
        echo -e "$1 - 安装成功"
    else
        echo -e "$1 - 安装失败！"
    fi
}

# Debian系安装函数
debian_install() {
    echo -e '=====================\n正在为 Debian 系安装依赖\n=====================\n' > "$ILOG"

    pkgs="python3 python3-pip python3-requests python3-packaging python3-psutil php"

    install_cmd() {
        echo -ne "正在安装 $1...\r"
        sudo apt -y install $1 &>> "$ILOG"
        status_check $1
        echo -e '\n--------------------\n' >> "$ILOG"
    }

    for pkg_name in $pkgs; do
        install_cmd $pkg_name
    done
}

# Fedora系安装函数
fedora_install() {
    echo -e '=====================\n正在为 Fedora 系安装依赖\n=====================\n' > "$ILOG"

    pkgs="python3 python3-pip python3-requests python3-packaging python3-psutil php"

    install_cmd() {
        echo -ne "正在安装 $1...\r"
        sudo dnf install $1 -y &>> "$ILOG"
        status_check $1
        echo -e '\n--------------------\n' >> "$ILOG"
    }

    for pkg_name in $pkgs; do
        install_cmd $pkg_name
    done
}

# Termux安装函数
termux_install() {
    echo -e '=====================\n正在为 Termux 安装依赖\n=====================\n' > "$ILOG"

    pkgs="python php"
    pip_pkgs="requests packaging psutil"

    install_cmd() {
        echo -ne "正在安装 $1...\r"
        apt -y install $1 &>> "$ILOG"
        status_check $1
        echo -e '\n--------------------\n' >> "$ILOG"
    }

    install_pip() {
        echo -ne "正在安装 pip 包 $1...\r"
        pip install -U $1 &>> "$ILOG"
        status_check $1
        echo -e '\n--------------------\n' >> "$ILOG"
    }

    for pkg_name in $pkgs; do
        install_cmd $pkg_name
    done

    for pkg_name in $pip_pkgs; do
        install_pip $pkg_name
    done
}

# Arch系安装函数
arch_install() {
    echo -e '=========================\n正在为 Arch 系安装依赖\n=========================\n' > "$ILOG"

    install_cmd() {
        echo -ne "正在安装 $1...\r"
        yes | sudo pacman -S $1 --needed &>> "$ILOG"
        status_check $1
        echo -e '\n--------------------\n' >> "$ILOG"
    }

    pkgs="python3 python-pip python-requests python-packaging python-psutil php"

    for pkg_name in $pkgs; do
        install_cmd $pkg_name
    done
}

echo -e '\n[!] 正在安装系统依赖...\n'

# 系统类型检测
if [ -f '/etc/arch-release' ]; then
    arch_install
elif [ -f '/etc/fedora-release' ]; then
    fedora_install
else
    if [ -z "${TERMUX_VERSION}" ]; then
        debian_install
    else
        termux_install
    fi
fi

echo -e '=========\n安装完成\n=========\n' >> "$ILOG"

echo -e '\n[+] 安装日志已保存至：' "$ILOG"