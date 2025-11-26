# 贡献指南

感谢你考虑为 Bing 壁纸设置器做出贡献！🎉

## 🤝 如何贡献

### 报告 Bug

如果你发现了 Bug，请通过 [GitHub Issues](https://github.com/your-username/bing-wallpaper-setter/issues) 报告：

1. 检查是否已有相同的 Issue
2. 使用清晰的标题描述问题
3. 提供详细信息：
   - 操作系统版本（如 Ubuntu 22.04）
   - 桌面环境（GNOME/KDE）
   - Qt 版本
   - 复现步骤
   - 预期行为 vs 实际行为
   - 错误日志或截图

### 提出功能建议

我们欢迎新功能建议！请通过 [GitHub Discussions](https://github.com/your-username/bing-wallpaper-setter/discussions) 或 [Issues](https://github.com/your-username/bing-wallpaper-setter/issues)：

1. 清楚描述功能及其用途
2. 说明为什么这个功能有用
3. 如果可能，提供实现思路或参考

### 提交代码

#### 准备工作

1. **Fork 仓库**
   ```bash
   # 在 GitHub 上点击 Fork 按钮
   git clone https://github.com/your-username/bing-wallpaper-setter.git
   cd bing-wallpaper-setter
   ```

2. **配置开发环境**
   ```bash
   # 安装依赖
   sudo apt install cmake g++ qtbase5-dev qt5-qmake libqt5network5
   
   # 创建构建目录
   mkdir build && cd build
   cmake -DCMAKE_BUILD_TYPE=Debug ../src
   make
   ```

3. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   # 或
   git checkout -b fix/bug-description
   ```

#### 开发规范

**代码风格**

- 使用 4 空格缩进（不使用 Tab）
- 类名使用 PascalCase：`MainWindow`
- 函数名使用 camelCase：`updateWallpaper()`
- 变量名使用 camelCase：`wallpaperPath`
- 成员变量使用 `m_` 前缀：`m_timer`
- 常量使用 UPPER_CASE：`MAX_WALLPAPERS`

**注释要求**

```cpp
/**
 * @brief 下载并设置壁纸
 * @param url 壁纸 URL
 * @return 成功返回 true，失败返回 false
 */
bool downloadAndSetWallpaper(const QString& url);
```

**提交信息**

使用清晰的提交信息：

```
类型: 简短描述（50 字符以内）

详细说明（如果需要）
- 第一点
- 第二点

相关 Issue: #123
```

类型可以是：
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建或辅助工具

示例：
```
feat: 添加壁纸历史记录功能

- 实现历史记录数据库存储
- 添加历史浏览界面
- 支持收藏功能

相关 Issue: #42
```

#### 测试

在提交 PR 前，请确保：

1. **编译通过**
   ```bash
   cd build
   make clean
   cmake -DCMAKE_BUILD_TYPE=Release ../src
   make -j$(nproc)
   ```

2. **功能测试**
   - 在 GNOME 和 KDE 环境下测试（如果可能）
   - 测试主要功能流程
   - 检查是否有内存泄漏

3. **打包测试**
   ```bash
   cd ../scripts
   ./package.sh
   ```

#### 提交 Pull Request

1. **推送更改**
   ```bash
   git add .
   git commit -m "feat: your feature description"
   git push origin feature/your-feature-name
   ```

2. **创建 PR**
   - 在 GitHub 上创建 Pull Request
   - 填写 PR 模板
   - 链接相关 Issue
   - 等待代码审查

3. **代码审查**
   - 及时回应审查意见
   - 根据反馈修改代码
   - 保持提交历史清晰

## 📝 开发指南

### 项目架构

```
BingWallpaperSetter (核心类)
├── 网络请求 (QNetworkAccessManager)
├── 文件管理 (下载、清理)
└── 壁纸设置 (gsettings 命令)

MainWindow (GUI 界面)
├── UI 组件布局
├── 信号槽连接
├── 系统托盘
└── 用户交互逻辑
```

### 关键技术点

- **Qt 信号槽机制**: 用于异步操作和组件通信
- **QNetworkAccessManager**: 处理 HTTP 请求
- **QSettings**: 持久化配置
- **QSystemTrayIcon**: 系统托盘
- **gsettings**: Linux 桌面壁纸设置

### 添加新功能示例

假设要添加"收藏壁纸"功能：

1. **修改核心类** (`BingWallpaperSetter.h/cpp`)
   ```cpp
   // 添加方法
   void addToFavorites(const QString& wallpaperPath);
   QStringList getFavorites();
   ```

2. **修改 UI** (`MainWindow.h/cpp`)
   ```cpp
   // 添加按钮
   QPushButton* m_favoriteButton;
   
   // 添加槽函数
   private slots:
       void onFavoriteClicked();
   ```

3. **更新配置**
   ```cpp
   QSettings settings;
   settings.beginGroup("Favorites");
   settings.setValue("list", favoritesList);
   ```

4. **测试功能**
5. **更新文档**

## 🐛 调试技巧

### 启用调试输出

```cpp
#ifdef QT_DEBUG
    qDebug() << "壁纸路径:" << wallpaperPath;
#endif
```

### 使用 Qt Creator

1. 用 Qt Creator 打开 `src/CMakeLists.txt`
2. 配置为 Debug 模式
3. 设置断点调试

### 命令行调试

```bash
QT_LOGGING_RULES="*.debug=true" ./bin/BingWallpaperSetter
```

## 📦 发布流程

1. 更新版本号（`src/CMakeLists.txt`）
2. 更新 CHANGELOG
3. 创建 Git tag
4. 运行 `./scripts/package.sh`
5. 在 GitHub 创建 Release
6. 上传打包文件

## ❓ 需要帮助？

- 查看 [README.md](README.md)
- 查看 [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
- 在 [GitHub Discussions](https://github.com/your-username/bing-wallpaper-setter/discussions) 提问
- 联系维护者

## 📜 行为准则

请遵守基本的开源社区准则：

- 尊重他人
- 接受建设性批评
- 关注对项目最有利的事情
- 对其他社区成员表示同理心

## 🙏 致谢

感谢所有为本项目做出贡献的开发者！

---

再次感谢你的贡献！💖
