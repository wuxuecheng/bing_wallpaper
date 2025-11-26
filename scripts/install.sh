#!/bin/bash

# Bing壁纸设置器 - 快速安装脚本（用户端）
# 适用于已打包好的程序

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  Bing壁纸设置器 v1.0.0${NC}"
    echo -e "${BLUE}  快速安装程序${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo
}

# 检查系统
check_system() {
    if [ ! -f /etc/os-release ]; then
        print_error "无法检测系统类型"
        exit 1
    fi
    
    . /etc/os-release
    
    print_info "检测到系统: $NAME $VERSION"
    
    if [[ "$ID" != "ubuntu" && "$ID_LIKE" != *"ubuntu"* && "$ID_LIKE" != *"debian"* ]]; then
        print_error "此安装脚本仅支持Ubuntu/Debian系统"
        exit 1
    fi
}

# 检查Qt依赖
check_qt_dependencies() {
    print_info "检查Qt运行库..."
    
    local missing_deps=()
    
    if ! dpkg -l | grep -q libqt5core5a; then
        missing_deps+=("libqt5core5a")
    fi
    
    if ! dpkg -l | grep -q libqt5gui5; then
        missing_deps+=("libqt5gui5")
    fi
    
    if ! dpkg -l | grep -q libqt5widgets5; then
        missing_deps+=("libqt5widgets5")
    fi
    
    if ! dpkg -l | grep -q libqt5network5; then
        missing_deps+=("libqt5network5")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_info "需要安装Qt运行库..."
        echo "缺少: ${missing_deps[*]}"
        echo
        read -p "是否现在安装？(需要sudo权限) (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo apt update
            sudo apt install -y "${missing_deps[@]}"
            print_success "依赖安装完成"
        else
            print_error "缺少必要依赖，无法继续安装"
            exit 1
        fi
    else
        print_success "Qt运行库已安装"
    fi
}

# 安装程序
install_program() {
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    
    print_info "开始安装程序..."
    
    # 检查DEB包是否存在
    DEB_FILE=$(find "$SCRIPT_DIR" -name "bing-wallpaper-setter_*.deb" | head -n 1)
    
    if [ -n "$DEB_FILE" ] && [ -f "$DEB_FILE" ]; then
        print_info "使用DEB包安装..."
        sudo dpkg -i "$DEB_FILE"
        
        # 修复可能的依赖问题
        sudo apt-get install -f -y
        
        print_success "DEB包安装完成"
    else
        # 手动安装
        print_info "使用手动方式安装..."
        
        if [ ! -f "$SCRIPT_DIR/BingWallpaperSetter" ]; then
            print_error "找不到可执行文件"
            exit 1
        fi
        
        # 复制可执行文件
        sudo cp "$SCRIPT_DIR/BingWallpaperSetter" /usr/local/bin/
        sudo chmod +x /usr/local/bin/BingWallpaperSetter
        
        # 安装desktop文件
        mkdir -p ~/.local/share/applications
        if [ -f "$SCRIPT_DIR/bing-wallpaper-setter.desktop" ]; then
            cp "$SCRIPT_DIR/bing-wallpaper-setter.desktop" ~/.local/share/applications/
            chmod +x ~/.local/share/applications/bing-wallpaper-setter.desktop
        fi
        
        # 更新desktop数据库
        if command -v update-desktop-database &> /dev/null; then
            update-desktop-database ~/.local/share/applications 2>/dev/null || true
        fi
        
        print_success "程序安装完成"
    fi
}

# 设置开机启动
setup_autostart() {
    echo
    read -p "是否设置开机自动启动？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p ~/.config/autostart
        
        if [ -f ~/.local/share/applications/bing-wallpaper-setter.desktop ]; then
            cp ~/.local/share/applications/bing-wallpaper-setter.desktop ~/.config/autostart/
            print_success "已设置开机自动启动"
        else
            print_error "找不到desktop文件，无法设置自动启动"
        fi
    fi
}

# 启动程序
launch_program() {
    echo
    read -p "是否现在启动程序？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "启动程序..."
        nohup BingWallpaperSetter > /dev/null 2>&1 &
        sleep 1
        print_success "程序已启动，可在系统托盘中查看"
    fi
}

# 显示完成信息
show_completion_info() {
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
    echo "  • 4K超高清壁纸 (3840x2160)"
    echo "  • 立即更新壁纸"
    echo "  • 查看当前壁纸"
    echo "  • 自定义存储路径"
    echo "  • 自动更新设置"
    echo "  • 系统托盘常驻"
    echo
    print_info "卸载方法："
    echo "  sudo dpkg -r bing-wallpaper-setter"
    echo "  或: sudo rm /usr/local/bin/BingWallpaperSetter"
    echo
}

# 主函数
main() {
    print_header
    
    # 检查系统
    check_system
    echo
    
    # 检查依赖
    check_qt_dependencies
    echo
    
    # 安装程序
    install_program
    
    # 设置开机启动
    setup_autostart
    
    # 启动程序
    launch_program
    
    # 显示完成信息
    show_completion_info
}

# 运行主函数
main
