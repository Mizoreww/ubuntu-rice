# LLM-driven install markdown — design spec

**Date:** 2026-04-29
**Status:** approved (pending implementation plan)
**Author:** brainstorming session with project owner

## Background

`ubuntu-rice` 当前是一套 shell 脚本（`install.sh` + whiptail TUI + `modules/*.sh`），用于在新装 Ubuntu 上恢复个人桌面/终端/输入法/中文应用。脚本路线已被反复证明脆弱：

- PPA 名字漂移（`mkasberg/ghostty` → `mkasberg/ghostty-ubuntu`）
- 上游配置语法变更（Ghostty 1.3.1 `-cursor` → `no-cursor`）
- 上游 tarball 依赖问题（FileZilla GTK2 vs apt 的 GTK3）
- nautilus 扩展冲突（gnome-terminal vs ghostty）
- pipx 包名不存在等"假成功"
- 网络层（Clash fake-ip + GnuTLS）影响 git/curl/apt 行为

每次踩坑都得改脚本、调试 set -e 行为、加 fallback。**结论：脚本不是这个工作的正确抽象。** LLM 助手（Claude Code 等）能边读边判断、按现状选命令、出错时停下来问；把"安装流程"从代码改写成 LLM 可读的文档，跑出来比脚本更稳。

## Goals

1. 把项目从「脚本驱动」改成「markdown 驱动」—— 唯一事实源是 md，LLM 阅读后协助用户安装。
2. 把现有所有踩坑经验保留下来（不丢失任何已验证的"已知坑"）。
3. 重装系统时，把仓库扔给 Claude Code，几次往返就能恢复出当前桌面。
4. **老脚本直接 `git rm`**（不归档；git 历史保留即可）。

## Non-goals

- 不再做"全自动一键脚本" —— 走 LLM 引导路线。
- 不重写 `configs/default/`下的配置文件 —— 沿用现状，md 引用即可。
- 不替换具体应用的安装来源（除明确指定的：SPlayer 改用 GitHub releases）。
- 不做 backup/restore 工具（暂时归档；将来需要再说）。

## Final project layout

```
ubuntu-rice/
├── README.md             项目门户：定位 + 「LLM 怎么用这份指南」
├── INSTALL.md            入口索引（LLM 第一份要读的文件）
├── docs/
│   ├── 00-prereq.md      网络代理 + git/SSH（Clash SOCKS5）
│   ├── 01-shell.md       ghostty + zsh + fonts
│   ├── 02-input.md       fcitx5 + locale
│   ├── 03-desktop.md     theme + gnome-extensions + gnome-settings
│   ├── 04-apps-cn.md     QQ / 微信 / 网易云 / 百度网盘 / SPlayer / ToDesk
│   ├── 05-apps-dev.md    VS Code / Cursor / GitKraken / Termius / Miniconda
│   └── 06-apps-misc.md   Chrome / VLC / OBS / FileZilla
├── configs/              （保留）默认 dotfiles / 配置；md 引用 `configs/default/<x>`
├── screenshots/          （保留）README 引用
└── LICENSE
```

## `INSTALL.md` (入口索引) skeleton

```markdown
# ubuntu-rice

为新装 Ubuntu 系统快速恢复成我个人偏好的桌面环境。
本仓库面向 LLM 阅读：你（Claude Code 等）按下面流程逐节执行。

## 给 LLM 的执行规则

1. 先问后装 —— 每读完一节，先把"将要执行的命令"展示给用户，得到 OK 再执行。
2. 每节末尾的 `## Verify` 块要先跑 —— 已满足就跳过这节。
3. 失败就停 —— 不要"自动 fallback"。命令报错原文交给用户，问下一步。
4. 代理已就绪 —— 本机 GitHub 走 Clash SOCKS5 (127.0.0.1:7897)，git/SSH 已配好，apt/curl 直连。
5. 配置文件来源 —— `configs/default/<组件>/`；只 cp，不要把内容塞进命令里。

## 顺序与依赖

00-prereq → 01-shell → 02-input → 03-desktop → 04/05/06-apps（应用层可并行）

## 章节索引

| 节 | 文件 | 内容 |
|---|---|---|
| 00 | docs/00-prereq.md | 代理 / git / SSH |
| 01 | docs/01-shell.md  | ghostty / zsh / fonts |
| 02 | docs/02-input.md  | fcitx5 / locale |
| 03 | docs/03-desktop.md | theme / gnome-extensions / gnome-settings |
| 04 | docs/04-apps-cn.md | 中文应用 |
| 05 | docs/05-apps-dev.md | 开发工具 |
| 06 | docs/06-apps-misc.md | 其他应用 |
```

## 单组件章节模板

每个组件按下列固定结构写，便于 LLM 扫描：

```markdown
## <组件名>

<一句话定位>

### 安装

\`\`\`bash
<可直接复制的命令块>
\`\`\`

### 配置

\`\`\`bash
<可直接复制的命令块>
\`\`\`

### <可选：默认设置 / 卸载 等>

### 已知坑

- <要点 1>
- <要点 2>

### Verify

\`\`\`bash
<一行命令；输出 OK 则视为已装>
\`\`\`
```

**字段规则：**

- 命令块都是可直接复制 —— LLM 不用再拼字符串。
- 「已知坑」是这次重写的核心价值，每个组件都要从现有代码注释 / 会话记忆中萃取。
- `Verify` 优先用幂等性检查（`command -v` / `grep -q` / `dpkg -l`），跑完输出 `OK`。

## 应用清单（最终）

| 应用 | 来源 | 文件 | 备注 |
|---|---|---|---|
| Ghostty | `ppa:mkasberg/ghostty-ubuntu` | 01-shell | + python3-nautilus + xclip + wl-clipboard |
| Zsh + Oh-My-Zsh + p10k | curl install + git clone | 01-shell | — |
| Nerd Fonts (MesloLGS) | upstream zip | 01-shell | — |
| fcitx5 | apt | 02-input | 中文拼音 |
| locale (zh_CN) | apt + locale-gen | 02-input | — |
| Orchis GTK / Tela / Bibata | upstream installer | 03-desktop | — |
| GNOME extensions | extension manager + 列表 | 03-desktop | — |
| GNOME 外观设置 | gsettings / dconf | 03-desktop | — |
| QQ | im.qq.com .deb | 04-apps-cn | — |
| 微信 (Linux 原生) | weixin.qq.com .deb | 04-apps-cn | — |
| 网易云音乐 | 第三方 .deb | 04-apps-cn | — |
| 百度网盘 | .deb | 04-apps-cn | — |
| SPlayer | **GitHub releases**（变更点） | 04-apps-cn | 之前从 Downloads `.deb` 装；改为 GH releases |
| ToDesk | .deb | 04-apps-cn | — |
| VS Code | 官方 .deb | 05-apps-dev | — |
| Cursor | cursor.com (.deb / AppImage) | 05-apps-dev | 🆕 |
| GitKraken | .deb | 05-apps-dev | — |
| Termius | snap / .deb | 05-apps-dev | 🆕 |
| Miniconda | upstream installer | 05-apps-dev | 🆕；**装完必须** `conda config --set auto_activate_base false` |
| Typora | typora.io apt repo | 05-apps-dev | 🆕 markdown 编辑器 |
| Chrome | google.com .deb | 06-apps-misc | — |
| VLC | apt | 06-apps-misc | — |
| OBS Studio | apt / PPA | 06-apps-misc | — |
| FileZilla | apt（**GTK3**） | 06-apps-misc | 不要用上游 GTK2 tarball |

## 必须保留的「已知坑」清单

下面这些来自本会话调试结果，必须落到对应 md 章节：

- **Ghostty PPA 全名**：`ppa:mkasberg/ghostty-ubuntu`，不是 `mkasberg/ghostty`。
- **Ghostty shell-integration 语法**：1.3.1+ 用 `no-cursor` 而非 `-cursor`。
- **Ghostty 装包附带**：`python3-nautilus`（右键"Open in Ghostty"）+ `xclip` + `wl-clipboard`（TUI 剪贴板）。
- **Nautilus 双菜单**：装 ghostty 后须 `apt-get remove -y nautilus-extension-gnome-terminal`。
- **FileZilla**：必须走 apt（GTK3），不要用上游 tarball（GTK2 + fcitx5 → 光标不可见）。
- **Miniconda**：装完关闭 base 自动激活：`conda config --set auto_activate_base false`。
- **GitHub 网络**：`github.com` 在本机解析到 198.18.0.70（Clash fake-ip）；`git`/`ssh` 走 SOCKS5 `127.0.0.1:7897`。`~/.ssh/config` 已有 `ProxyCommand nc -X 5 -x 127.0.0.1:7897 %h %p`，全局 `git config http.https://github.com/.proxy socks5://127.0.0.1:7897`。
- **GitLab 克隆默认走 SSH**（项目级经验，写入 prereq）。

## 迁移表（删除 / 抽取 / 重写）

**先抽取再删 —— 删之前确认每条「已知坑」/ 命令都已落到对应 `docs/*.md`。**

| 现有文件 | 处理 | 备注 |
|---|---|---|
| `install.sh` `uninstall.sh` `backup.sh` `restore.sh` | `git rm` | TUI 框架不再需要 |
| `install-ghostty.sh` `install-apps.sh` `fix-now.sh` | `git rm` | 内容已在 modules/ 里覆盖 |
| `lib/utils.sh` `lib/distro.sh` `lib/tui.sh` | `git rm` | 仅服务于旧 TUI |
| `modules/*.sh` | `git rm`（先抽取入 docs/） | 命令 + 注释里的"坑"都要先迁出 |
| `legacy/beautify-*.sh` `legacy/2026-02-03-…md` | `git rm`（整个 `legacy/` 删除） | 已是死代码 |
| `configs/` `screenshots/` `LICENSE` `.gitignore` | 原位保留 | — |
| `README.md` | 重写 | 见下 |

## `README.md` 重写要点

- 一句话定位（保留）
- 删除：Quick Start、Project Structure（旧版）、Module Development、Backup & Restore、Uninstall
- 新增：「使用方法」—— 把项目克隆下来，扔给 Claude Code，让它读 `INSTALL.md`
- 新增：「内容覆盖」—— 表格列出 docs/ 各节涵盖的组件
- 保留：Screenshots、License

## Open questions

无。所有设计决策已确认。

## Out of scope

- backup/restore 工具的现代化重写
- 多发行版支持（仅 Ubuntu 22.04 / 24.04，老脚本里 20.04 的特殊处理一并归档）
- 自动检测系统已装组件并跳过 —— Verify 块由 LLM 解释结果决定跳过；不做静态检测代码

## Success criteria

- 在一台干净的 Ubuntu 24.04 上：把仓库克隆下来，开 Claude Code，让它读 `INSTALL.md`，按章节走，最终能恢复 dock 上 ~20 个应用 + 桌面外观 + 终端 + 输入法。
- 任意一节执行失败，LLM 停在该节、报错、问用户；不破坏其他节状态。
- 所有现有「已知坑」全部以正文形式出现在对应章节（grep 可查）。
