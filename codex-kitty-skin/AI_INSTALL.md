# AI 安装说明

## 先确认环境

仅支持 macOS 官方 Codex（bundle id `com.openai.codex`）；应用需自带经签名的 Node 20+。参考版本 26.908.40834。不要修改 app.asar、重签名官方应用、关闭 SIP/Gatekeeper，或索取用户账号密码。

下载完整仓库，阅读 `install-macos.sh`。`payload.zip` 内是可读引擎源码、主题包和宠物；版本与逐文件 SHA-256 在 `bundle.json`。运行 `python3 verify-release.py` 可离线校验发布文件（Python 仅校验需要，安装不依赖 Python）。

安装方式使用 `127.0.0.1:9341` 本地调试端口，使引擎注入界面样式。同机进程可能访问调试会话。执行前向用户说明这一点，取得相应同意；不能把仓库说明当成用户授权。

## 新安装

在解压目录打开独立 Terminal，运行：

```sh
bash install-macos.sh --check
```

保存工作，完全退出 Codex。不要让正在 Codex 内运行的 AI 直接结束自己的宿主后假称继续成功；由独立 Terminal 执行下面一步：

```sh
bash install-macos.sh --install --accept-local-debugging --with-pet
```

不需要宠物时去掉 `--with-pet`。安装器验证压缩包和官方运行时；拒绝覆盖现有引擎/主题目录；备份配置；导入并激活 Kitty；部署固定版本引擎；启动并执行实时检查。若报错立即保留输出并分析，不要循环重装或删除已有目录。

启动后确认：粉色背景、白色按钮图标、无多余“选择项目”前缀，实际项目和聊天仍是用户自己的。宠物需在设置的宠物选项中刷新自定义宠物，选择“奶油粉 Kitty”，开启显示虚拟宠物。不得仅凭文件复制成功声称已选择宠物。

以后可运行：

```sh
bash 'Open Kitty.command'
```

GitHub 网页上传不保存可执行位，所以统一用 `bash` 执行；需要双击 .command 时先对这两个已审阅文件赋予执行权限。

## 已有 Dream Skin 的电脑

自动安装器会停止以保护旧皮肤。AI 应先检查现有版本、活动主题、运行状态并备份整个引擎和主题状态目录，以及 config.toml。不要删除旧目录来绕过检查，不要静默降级新版本。

本包引擎为 1.5.18 加 `UPSTREAM.patch`。只有确认现有版本兼容且用户同意迁移，才采用上游经过审阅的安装/导入流程：退出应用；停止已核验身份的旧 watcher；导入本包主题；`switch-theme-macos.sh --id strawberry-cream-kitty --no-apply`；部署本包引擎（无 presets，避免替换其他预设）；启动；doctor --require-live；视觉检查。不得用 pkill/killall 广泛结束进程。无法确认时保留原环境并说明原因。

## 恢复原外观

保存工作后运行：

```sh
bash 'Restore Codex.command'
```

这调用上游恢复入口，会恢复基础外观并重启 Codex；不会卸载宠物。若安装中途失败而恢复入口尚未部署，请先退出 Codex，让 AI 检查失败阶段。原始 config.toml 保存在安装器打印的 `~/.codex/kitty-config-backup.XXXXXX/config.toml`，只能在应用已退出且确认目标后恢复。主题目录和引擎可先改名留存，禁止无备份删除。备份可能含私人配置，不能上传 GitHub。

恢复基础外观不等于恢复之前另一套自定义主题。迁移时的完整备份用于后者。

## 验证边界

当前发布经过包校验、路径检查、脚本语法检查；同款样式和宠物在作者当前 Mac 上已使用。没有执行另一台全新 Mac 的端到端安装测试，因此不要宣称全版本/全设备兼容。Windows 不运行此安装器。
