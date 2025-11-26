#!/bin/bash

set -e

echo "================================================"
echo "  Bing壁纸设置器 - 卸载程序"
echo "================================================"
echo

read -p "确定要卸载 Bing壁纸设置器吗？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "取消卸载"
    exit 0
fi

echo
echo "正在停止运行的程序..."
pkill -f BingWallpaperSetter 2>/dev/null || true

echo "正在删除程序文件..."
sudo rm -f /usr/local/bin/BingWallpaperSetter

echo "正在删除桌面文件..."
rm -f ~/.local/share/applications/bing-wallpaper-setter.desktop

echo "正在删除图标文件..."
sudo rm -f /usr/share/pixmaps/bing-wallpaper-setter.png

echo "正在删除配置文件..."
rm -rf ~/.config/BingWallpaper

# 更新desktop数据库
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database ~/.local/share/applications 2>/dev/null || true
fi

echo
read -p "是否删除已下载的壁纸？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/Pictures/BingWallpapers
    echo "壁纸已删除"
fi

echo
echo "✓ 卸载完成！"
echo
