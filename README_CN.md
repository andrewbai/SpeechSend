# Target AutoEnter (Typeless / 闪电说)

[![macOS](https://img.shields.io/badge/platform-macOS-lightgrey)](https://www.apple.com/macos/)
[![Objective-C](https://img.shields.io/badge/language-Objective--C-blue)](https://developer.apple.com/documentation/objectivec)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

**中文** | [English](README.md)

适用于 macOS 的菜单栏常驻小工具：在 **Typeless** 或 **闪电说（shandianshuo）** 语音输入结束并通过 `Cmd+V` 粘贴文本后，自动延迟按一次 `Enter`，实现“免手动回车发送”。

---

## 为什么做这个

像 Typeless、闪电说这类语音输入工具，在识别结束后通常会通过 `Cmd+V` 把文字粘贴到当前输入框里。  
但很多聊天软件/网页聊天框仍然需要你再手动按一次回车才能发送。

本工具会监听这一粘贴行为，并在短暂延迟后自动模拟一次 `Enter`，让你在语音输入完成后无需再碰键盘。

---

## 功能特点

- ✅ 菜单栏常驻（`↩` 图标）
- ✅ 支持 **Typeless** 与 **闪电说（shandianshuo）**
- ✅ 仅对目标进程触发（按 PID 过滤）
- ✅ 延迟可调（默认 500ms）
- ✅ 支持全局快捷键开关（`Ctrl + Shift + Enter`）
- ✅ 支持脚本切换（`./toggle.sh`，通过 `SIGUSR1`）
- ✅ 支持 `launchd` 开机自启

---

## 工作原理

1. 每 30 秒扫描一次系统进程列表，按名称查找目标进程（`Typeless` / `shandianshuo`）
2. 通过 `CGEvent Tap` 监听全局 `keyDown` 键盘事件
3. 按事件来源 PID 过滤，只处理来自目标进程的事件
4. 检测到目标进程发出的 `Cmd+V`（即粘贴动作）后，启动延迟计时
5. 在延迟结束时模拟按下并释放 `Enter`
6. 如果延迟期间又收到新的 `Cmd+V`，则重置计时器（防止过早发送）

---

## 编译

```bash
chmod +x build.sh
./build.sh
```

需要安装 Xcode Command Line Tools（如未安装）：

```bash
xcode-select --install
```

---

## 使用

```bash
./target-autoenter
```

首次启动时，macOS 会要求授予 **辅助功能（Accessibility）权限**。  
如果权限不足，程序会弹出提示并显示当前二进制路径。

### 辅助功能授权步骤

1. 打开 **系统设置**
2. 进入 **隐私与安全性 → 辅助功能**
3. 点击 **+**（可能需要先解锁）
4. 选择并添加 `target-autoenter` 二进制文件
5. 确保右侧开关已开启
6. 重新启动程序：`./target-autoenter`

> 注意：macOS 的辅助功能权限通常与二进制文件哈希相关。  
> 如果你重新编译（`./build.sh`）后再次提示没权限，删除旧条目并重新添加即可。

---

## 菜单栏开关

程序运行后，菜单栏会出现一个 `↩` 图标。

点击图标可以打开菜单：

- **AutoEnter**：切换自动发送开关
- **Quit**：退出程序

状态显示：
- 开启时：图标正常显示
- 关闭时：图标变灰（透明度降低）

---

## 全局快捷键

默认全局快捷键：

`Ctrl + Shift + Enter`

按下后可切换 AutoEnter 开/关，并在屏幕中央显示 HUD（`ON` / `OFF`）状态提示。

### 修改快捷键

如需修改快捷键，请编辑 `target-autoenter.m` 中快捷键判断逻辑（`event_callback` 内对应判断代码），然后重新编译。

常用修饰键标志如下：

| 代码 | 按键 |
|------|------|
| `kCGEventFlagMaskControl` | Ctrl |
| `kCGEventFlagMaskShift` | Shift |
| `kCGEventFlagMaskCommand` | Cmd |
| `kCGEventFlagMaskAlternate` | Option |

---

## 脚本切换（无需点菜单栏）

```bash
./toggle.sh
```

该脚本会向运行中的程序发送 `SIGUSR1` 信号，以切换开/关状态。

---

## 自定义

### 1) 自动按 Enter 延迟（默认 500ms）

编辑 `target-autoenter.m` 中的常量：

```c
static const CFTimeInterval DELAY_SEC = 0.5;  // 修改为你希望的延迟秒数
```

然后重新编译：

```bash
./build.sh
```

建议：

- 若偶尔发送过快（文本尚未完全粘贴）→ 调大到 `0.6 ~ 0.8`
- 若感觉发送偏慢 → 调小到 `0.3 ~ 0.45`

---

## 开机自启（launchd）

### 1) 编辑 plist 文件

打开 `com.user.target-autoenter.plist`，将下面路径替换为你本机实际二进制路径：

```xml
<string>/path/to/target-autoenter</string>
```

例如：

```xml
<string>/Users/andrew/Downloads/typeless-autoenter-main/target-autoenter</string>
```

### 2) 复制到 LaunchAgents 并加载

```bash
cp com.user.target-autoenter.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.user.target-autoenter.plist
```

> 如果你修改过 plist，建议先卸载再加载：
>
> ```bash
> launchctl unload ~/Library/LaunchAgents/com.user.target-autoenter.plist 2>/dev/null || true
> launchctl load ~/Library/LaunchAgents/com.user.target-autoenter.plist
> ```

---

## 常见问题

### 1) 明明加了辅助功能权限，程序仍提示没权限？

这通常是因为你重新编译过，二进制哈希变了。解决方法：

- 在 **辅助功能** 中删除旧的 `target-autoenter`
- 重新添加当前编译后的 `target-autoenter`
- 再重新运行程序

---

### 2) 能粘贴但没有自动发送？

可能原因：

- 当前应用不是“Enter 发送”，而是“Enter 换行”
- 延迟太短，文本尚未完全粘贴（把 `DELAY_SEC` 调大）
- AutoEnter 当前处于关闭状态（菜单栏或快捷键检查）

> **微信兼容说明：**  
> 微信 Mac 客户端在“Enter 发送”模式下，可能会将模拟回车识别为换行。若出现该情况，请将微信“发送消息”快捷键改为 `⌘ + Enter`。

---

### 3) 我只想在某些应用里使用，怎么办？

当前版本按“目标语音输入进程（Typeless / 闪电说）+ Cmd+V 粘贴事件”触发。  
如果你需要更严格的“仅在某些聊天应用中自动发送”的白名单逻辑，可以在此基础上继续扩展。

---

## 致谢与来源说明

本项目基于 [ConstantineLiu/typeless-autoenter](https://github.com/ConstantineLiu/typeless-autoenter) 修改，原项目采用 **MIT License**。

本仓库主要修改内容包括：

- 增加对 **闪电说（shandianshuo）** 的支持
- 更新目标进程识别逻辑（兼容 Typeless / 闪电说）
- 调整二进制、脚本与 plist 命名（`target-autoenter`）
- 针对语音转文字粘贴后的自动发送流程进行适配与验证

感谢原作者提供思路与实现。

---

## License

本项目基于 [MIT License](LICENSE) 开源。  
请在再分发或修改时保留许可证文本与原始版权声明。
