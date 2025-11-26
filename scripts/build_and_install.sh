#!/bin/bash

# Bing壁纸设置器 - 编译和安装脚本
# 使用Qt C++编写

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 打印标题
print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  Bing壁纸设置器 - 编译安装程序${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo
}

# 检查依赖
check_dependencies() {
    print_info "检查系统依赖..."
    
    local missing_deps=()
    
    # 检查cmake
    if ! command -v cmake &> /dev/null; then
        missing_deps+=("cmake")
    fi
    
    # 检查g++
    if ! command -v g++ &> /dev/null; then
        missing_deps+=("g++")
    fi
    
    # 检查Qt
    if ! command -v qmake &> /dev/null && ! [ -f "/usr/lib/x86_64-linux-gnu/cmake/Qt5/Qt5Config.cmake" ] && ! [ -f "/usr/lib/x86_64-linux-gnu/cmake/Qt6/Qt6Config.cmake" ]; then
        missing_deps+=("qtbase5-dev qt5-qmake" "或" "qt6-base-dev")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "缺少以下依赖包："
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo
        print_info "安装依赖命令："
        echo "  sudo apt update"
        echo "  sudo apt install cmake g++ qtbase5-dev qt5-qmake libqt5network5"
        echo
        read -p "是否现在安装依赖？(y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo apt update
            sudo apt install -y cmake g++ qtbase5-dev qt5-qmake libqt5network5
        else
            print_error "请先安装依赖后再运行此脚本"
            exit 1
        fi
    else
        print_success "所有依赖已安装"
    fi
}

# 编译程序
build_program() {
    print_info "开始编译程序（这可能需要几分钟）..."
    
    # 获取脚本所在目录
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    cd "$PROJECT_ROOT"
    
    # 创建build目录
    if [ -d "build" ]; then
        print_warning "删除旧的build目录..."
        rm -rf build
    fi
    
    mkdir -p build
    cd build
    
    # 运行cmake
    print_info "配置CMake..."
    if cmake ../src ; then
        print_success "CMake配置成功"
    else
        print_error "CMake配置失败"
        exit 1
    fi
    
    # 编译
    print_info "编译程序（这可能需要几分钟）..."
    if make -j$(nproc); then
        print_success "编译成功"
    else
        print_error "编译失败"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
}

# 安装程序
install_program() {
    print_info "安装程序到系统..."
    
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    
    # 安装可执行文件
    sudo cp "$PROJECT_ROOT/build/bin/BingWallpaperSetter" /usr/local/bin/
    sudo chmod +x /usr/local/bin/BingWallpaperSetter
    print_success "已安装到 /usr/local/bin/BingWallpaperSetter"
    
    # 安装desktop文件
    mkdir -p ~/.local/share/applications
    cp "$PROJECT_ROOT/src/bing-wallpaper-setter.desktop" ~/.local/share/applications/
    chmod +x ~/.local/share/applications/bing-wallpaper-setter.desktop
    
    # 更新desktop数据库
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database ~/.local/share/applications
    fi
    
    print_success "已安装桌面快捷方式"
}

# 创建开机启动
setup_autostart() {
    echo
    read -p "是否设置开机自动启动？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p ~/.config/autostart
        cp ~/.local/share/applications/bing-wallpaper-setter.desktop ~/.config/autostart/
        print_success "已设置开机自动启动"
    fi
}

# 主函数
main() {
    print_header
    
    # 检查依赖
    check_dependencies
    
    echo
    
    # 编译程序
    build_program
    
    echo
    
    # 安装程序
    install_program
    
    # 设置开机启动
    setup_autostart
    
    echo
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}  安装完成！${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo
    print_info "使用方法："
    echo "  1. 从应用程序菜单启动 'Bing壁纸设置器'"
    echo "  2. 或在终端运行: BingWallpaperSetter"
    echo "  3. 程序会自动最小化到系统托盘"
    echo
    print_info "功能特点："
    echo "  • 立即更新壁纸"
    echo "  • 查看当前壁纸"
    echo "  • 打开壁纸文件夹"
    echo "  • 启用自动更新（可设置间隔）"
    echo "  • 系统托盘图标，方便快速操作"
    echo
    
    read -p "是否现在启动程序？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "启动程序..."
        nohup BingWallpaperSetter > /dev/null 2>&1 &
        sleep 1
        print_success "程序已在后台运行"
    fi
}

# 运行主函数
main
