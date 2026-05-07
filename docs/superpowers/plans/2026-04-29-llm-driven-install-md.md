# LLM-driven install markdown — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the script-based ubuntu-rice installer (install.sh + modules/*.sh) with a set of LLM-readable markdown documents that drive selective installs.

**Architecture:** One entry index (`INSTALL.md`) + 7 sub-docs under `docs/`, each following a fixed per-component template (Install / Configure / Pitfalls / Verify). Old scripts get `git rm`'d after their commands and pitfalls are harvested into the new docs. `configs/default/*` is preserved and referenced by the new docs.

**Tech Stack:** Markdown only. Engineer's job is to harvest existing shell modules into structured prose + verbatim command blocks, then delete the modules.

**Spec:** `docs/superpowers/specs/2026-04-29-llm-driven-install-md-design.md`

---

## File Structure

**Files to create:**
- `INSTALL.md` (entry index for the LLM)
- `docs/00-prereq.md` (network proxy + git/SSH)
- `docs/01-shell.md` (ghostty + zsh + fonts)
- `docs/02-input.md` (fcitx5 + locale)
- `docs/03-desktop.md` (theme + gnome-extensions + gnome-settings)
- `docs/04-apps-cn.md` (中文应用)
- `docs/05-apps-dev.md` (dev tools incl. Miniconda + Cursor + Termius + Typora)
- `docs/06-apps-misc.md` (Chrome / VLC / OBS / FileZilla)

**Files to rewrite:**
- `README.md` (project portal — strip script-era sections, add "feed to Claude Code" usage)

**Files to delete (after content has been migrated):**
- `install.sh` `uninstall.sh` `backup.sh` `restore.sh`
- `install-ghostty.sh` `install-apps.sh` `fix-now.sh`
- `lib/utils.sh` `lib/distro.sh` `lib/tui.sh` (entire `lib/` dir)
- `modules/*.sh` (entire `modules/` dir)
- `legacy/` (entire dir, including `beautify-*.sh` and `2026-02-03-system-beautification-backup.md`)

**Files preserved as-is:**
- `configs/default/**`, `configs/custom/` placeholder, `screenshots/`, `LICENSE`, `.gitignore`

**Note on TDD-for-docs:** This is a documentation rewrite, not a code feature. The "test" pattern adapts to: (1) write a grep-based verifier that fails because the doc doesn't yet contain a required term, (2) write the doc, (3) verify the grep passes. Critical session-learned pitfalls (e.g. `no-cursor`, `mkasberg/ghostty-ubuntu`, FileZilla GTK3, Miniconda auto_activate_base) get explicit grep checks so they cannot be silently dropped during transcription.

---

## Task 1: Scaffold empty doc files

**Files:**
- Create: `INSTALL.md` (placeholder)
- Create: `docs/00-prereq.md` (placeholder)
- Create: `docs/01-shell.md` (placeholder)
- Create: `docs/02-input.md` (placeholder)
- Create: `docs/03-desktop.md` (placeholder)
- Create: `docs/04-apps-cn.md` (placeholder)
- Create: `docs/05-apps-dev.md` (placeholder)
- Create: `docs/06-apps-misc.md` (placeholder)

- [ ] **Step 1: Create the 8 files with stub headings**

```bash
cd /home/limx/Desktop/ubuntu-rice
printf '# ubuntu-rice — INSTALL\n\n_TODO_\n' > INSTALL.md
for f in 00-prereq 01-shell 02-input 03-desktop 04-apps-cn 05-apps-dev 06-apps-misc; do
  printf "# %s\n\n_TODO_\n" "$f" > "docs/$f.md"
done
```

- [ ] **Step 2: Verify all 8 files exist and contain `_TODO_`**

Run: `grep -l '_TODO_' INSTALL.md docs/*.md | wc -l`
Expected: `8`

- [ ] **Step 3: Commit**

```bash
git add INSTALL.md docs/
git commit -m "scaffold: create empty INSTALL.md and docs/*.md placeholders"
```

---

## Task 2: Write `INSTALL.md` (entry index)

**Files:**
- Modify: `INSTALL.md`

- [ ] **Step 1: Write the verify check (must fail before content is written)**

Run:
```bash
grep -q '127.0.0.1:7897' INSTALL.md && \
  grep -q '## 给 LLM 的执行规则' INSTALL.md && \
  grep -q '00-prereq' INSTALL.md && \
  grep -q '06-apps-misc' INSTALL.md && \
  echo OK
```
Expected: empty output (FAIL — these tokens not yet present).

- [ ] **Step 2: Replace `INSTALL.md` with the full content**

```markdown
# ubuntu-rice

为新装 Ubuntu 系统快速恢复成个人偏好的桌面环境。
本仓库**面向 LLM 阅读**：你（Claude Code 等）按下面流程逐节执行。

## 给 LLM 的执行规则

1. **先问后装** —— 每读完一节，先把"将要执行的命令"展示给用户，得到 OK 再 Bash 执行。
2. **每节末尾的 `## Verify` 块要先跑** —— 输出 `OK` 就跳过这节，告诉用户"已装"。
3. **失败就停** —— 不要"自动 fallback"。命令报错原文交给用户，问下一步。
4. **代理已就绪** —— 本机 GitHub 走 Clash SOCKS5 (127.0.0.1:7897)，git/SSH 已配好；apt/curl 通常直连即可。如果 `git`/`ssh github.com` 报 TLS 或 DNS 错，去读 `docs/00-prereq.md`。
5. **配置文件来源** —— `configs/default/<组件>/`；只 cp，不要把内容塞进命令里。

## 顺序与依赖

```
00-prereq  →  01-shell  →  02-input  →  03-desktop  →  04 / 05 / 06-apps
```

应用层（04/05/06）相互独立，可按用户需求挑选；但 `01-shell` 必须先装，因为后续步骤靠 ghostty 终端 + apt 仓库。

## 章节索引

| 节 | 文件 | 内容 |
|---|---|---|
| 00 | [docs/00-prereq.md](docs/00-prereq.md)   | 代理 / git / SSH |
| 01 | [docs/01-shell.md](docs/01-shell.md)     | ghostty / zsh / fonts |
| 02 | [docs/02-input.md](docs/02-input.md)     | fcitx5 / locale |
| 03 | [docs/03-desktop.md](docs/03-desktop.md) | theme / gnome-extensions / gnome-settings |
| 04 | [docs/04-apps-cn.md](docs/04-apps-cn.md) | QQ / 微信 / 网易云 / 百度网盘 / SPlayer / ToDesk |
| 05 | [docs/05-apps-dev.md](docs/05-apps-dev.md) | VS Code / Cursor / GitKraken / Termius / Miniconda / Typora |
| 06 | [docs/06-apps-misc.md](docs/06-apps-misc.md) | Chrome / VLC / OBS / FileZilla |

## 单组件章节模板（所有 docs/*.md 通用）

每个组件都按这个结构写，便于扫描：

- `## <组件名>` —— 一句话定位
- `### 安装` —— 可直接复制的命令块
- `### 配置` —— 可直接复制的命令块（如有）
- `### 已知坑` —— bullet list
- `### Verify` —— 一行命令，输出 `OK` 视为已装
```

- [ ] **Step 3: Re-run verify**

Run:
```bash
grep -q '127.0.0.1:7897' INSTALL.md && \
  grep -q '## 给 LLM 的执行规则' INSTALL.md && \
  grep -q '00-prereq' INSTALL.md && \
  grep -q '06-apps-misc' INSTALL.md && \
  echo OK
```
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add INSTALL.md
git commit -m "docs: write INSTALL.md entry index for LLM consumers"
```

---

## Task 3: Write `docs/00-prereq.md`

**Files:**
- Modify: `docs/00-prereq.md`

**Content sources:**
- Session memory: GitHub via Clash SOCKS5 (`127.0.0.1:7897`); `~/.ssh/config` ProxyCommand; `git config --global http.https://github.com/.proxy socks5://127.0.0.1:7897`; `git@<host>:...` for GitLab.
- Lessons file: `~/.claude/lessons.md`.

- [ ] **Step 1: Write the verify check (must fail)**

Run:
```bash
grep -q 'socks5://127.0.0.1:7897' docs/00-prereq.md && \
  grep -q 'ProxyCommand' docs/00-prereq.md && \
  grep -q 'GnuTLS' docs/00-prereq.md && \
  echo OK
```
Expected: empty (FAIL).

- [ ] **Step 2: Replace `docs/00-prereq.md` with the full content**

````markdown
# 00 — 前置条件（网络 / Git / SSH）

只有当 `git push` / `ssh git@github.com` 报 TLS 或 DNS 错误时才需要做这一节。
干净 Ubuntu 上通常 apt / curl / wget 都能直连。

## 现象

本机 DNS 把 `github.com` 解析到 `198.18.0.70`（Clash fake-ip 段）。Ubuntu 自带 git 用 GnuTLS，对透明代理 + fake-ip 的握手不干净，会报：

```
gnutls_handshake() failed: The TLS connection was non-properly terminated
```

`curl https://github.com` 反而能成 —— 因为 curl 用 OpenSSL。所以**只需要让 git / ssh 走代理**，不动 DNS。

## Git over HTTPS：走 SOCKS5

### 安装

```bash
git config --global http.https://github.com/.proxy socks5://127.0.0.1:7897
```

只代理 `github.com`，对 GitLab / 自建仓库无影响。

### 已知坑

- `http.version=HTTP/1.1` **不是**修复方案，已验证无效。
- 走 socks5 后 `git push` 还可能报"认证失败" —— 那是 PAT/SSH 没配，不是代理问题。

### Verify

```bash
git config --global --get http.https://github.com/.proxy && \
  git ls-remote https://github.com/git/git HEAD &>/dev/null && echo OK
```

## SSH over SOCKS5

### 安装

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh

cat >> ~/.ssh/config <<'EOF'
Host github.com
    HostName github.com
    User git
    ProxyCommand nc -X 5 -x 127.0.0.1:7897 %h %p
    IdentityFile ~/.ssh/id_ed25519
EOF
chmod 600 ~/.ssh/config
```

`nc` 用的是 OpenBSD netcat（`ubuntu-server` / `nautilus` 默认就有；如缺，`apt install netcat-openbsd`）。

### 生成密钥并加到 GitHub

```bash
ssh-keygen -t ed25519 -C "<你的邮箱>" -f ~/.ssh/id_ed25519 -N ''
cat ~/.ssh/id_ed25519.pub  # 把这串贴到 https://github.com/settings/keys
```

### Verify

```bash
ssh -T git@github.com 2>&1 | grep -q 'successfully authenticated' && echo OK
```

## GitLab：默认走 SSH

私有 GitLab 实例（如 `http://<host>/...`）的 HTTPS 克隆会卡在交互式账号密码输入（在非交互式工具里直接挂）。

**永远用 SSH URL：** `git@<host>:<group>/<repo>.git`，假定 SSH key 已配；HTTP(S) URL 在执行前手动转成 SSH 形式。
````

- [ ] **Step 3: Re-run verify (Step 1 grep)**

Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add docs/00-prereq.md
git commit -m "docs: write 00-prereq (proxy/git/ssh setup for github + gitlab)"
```

---

## Task 4: Write `docs/01-shell.md`

**Files:**
- Modify: `docs/01-shell.md`

**Content sources:**
- `modules/ghostty.sh` — install commands, default-terminal registration, nautilus extension cleanup
- `modules/zsh.sh` — Oh-My-Zsh + p10k + plugins
- `modules/fonts.sh` — MesloLGS NF download
- `configs/default/ghostty/config`, `configs/default/zsh/zshrc`, `configs/default/zsh/p10k.zsh`
- Session memory: Ghostty 1.3.1 uses `no-cursor` not `-cursor`; PPA name is `mkasberg/ghostty-ubuntu`; `python3-nautilus`/`xclip`/`wl-clipboard` are required; gnome-terminal nautilus extension must be removed.

- [ ] **Step 1: Write the verify check (must fail)**

Run:
```bash
grep -q 'mkasberg/ghostty-ubuntu' docs/01-shell.md && \
  grep -q 'no-cursor' docs/01-shell.md && \
  grep -q 'python3-nautilus' docs/01-shell.md && \
  grep -q 'wl-clipboard' docs/01-shell.md && \
  grep -q 'nautilus-extension-gnome-terminal' docs/01-shell.md && \
  grep -q 'powerlevel10k' docs/01-shell.md && \
  grep -q 'MesloLGS NF' docs/01-shell.md && \
  echo OK
```
Expected: empty (FAIL).

- [ ] **Step 2: Replace `docs/01-shell.md` with the full content**

````markdown
# 01 — 终端环境（Ghostty + Zsh + 字体）

GUI 桌面之外，先把终端栈打通：Ghostty 替掉 gnome-terminal、Zsh 替掉 bash、装上 powerlevel10k 需要的 Nerd Font。

## Ghostty

GPU 加速终端，作为系统默认 `x-terminal-emulator`。

### 安装

```bash
# 准备 add-apt-repository
sudo apt-get update -qq
sudo apt-get install -y software-properties-common

# 社区维护的 PPA（22.04 / 24.04 都有 build；20.04 没有）
sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
sudo apt-get update -qq

# ghostty 主包 + 必备伴生
#   python3-nautilus  → 启用右键"Open in Ghostty"
#   xclip / wl-clipboard → TUI 工具（Claude Code 等）才能访问系统剪贴板
sudo apt-get install -y ghostty python3-nautilus xclip wl-clipboard

# 移除 gnome-terminal 的 nautilus 扩展，否则右键有两个"Open in Terminal"
sudo apt-get remove -y nautilus-extension-gnome-terminal || true
```

### 设为默认终端

```bash
sudo update-alternatives --install /usr/bin/x-terminal-emulator \
    x-terminal-emulator "$(command -v ghostty)" 60
sudo update-alternatives --set x-terminal-emulator "$(command -v ghostty)"

# GNOME 42+ 用这两个 gsetting；老版本会忽略
gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e'
```

### 配置

```bash
mkdir -p ~/.config/ghostty
cp configs/default/ghostty/config ~/.config/ghostty/config
```

### 已知坑

- **PPA 全名是 `ppa:mkasberg/ghostty-ubuntu`**，不是 `mkasberg/ghostty`。
- **Ghostty 1.3.1+ 用 `shell-integration-features = no-cursor`** 禁用光标自动切换；老语法 `-cursor` 已废弃。`configs/default/ghostty/config` 里已经是 `no-cursor`。
- 不装 `python3-nautilus`，"Open in Ghostty" 右键不会出现。
- 不装 `xclip` / `wl-clipboard`，Claude Code 这类 Node/Electron CLI 静默丢失复制粘贴。
- Ubuntu 20.04 PPA 没 build —— 该版本只能源码编译，本仓库不支持。

### Verify

```bash
command -v ghostty &>/dev/null && \
  grep -q 'no-cursor' ~/.config/ghostty/config && \
  ! dpkg -l nautilus-extension-gnome-terminal &>/dev/null && \
  echo OK
```

## Zsh + Oh-My-Zsh + Powerlevel10k

### 安装

```bash
sudo apt-get install -y zsh

# Oh-My-Zsh（unattended）
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Powerlevel10k 主题
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ~/.oh-my-zsh/custom/themes/powerlevel10k

# 插件
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# 默认 shell
chsh -s "$(command -v zsh)"
```

### 配置

```bash
# 备份现有 .zshrc，然后用项目自带的覆盖
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.bak
cp configs/default/zsh/zshrc   ~/.zshrc
cp configs/default/zsh/p10k.zsh ~/.p10k.zsh
```

### 已知坑

- `chsh -s` 修改的是 `/etc/passwd`，**下次登录才生效**。当前 session 想立刻进 zsh 直接 `exec zsh`。
- Oh-My-Zsh 安装脚本会**覆盖 `~/.zshrc`**；自定义内容务必先备份（上面的 `cp .zshrc .zshrc.bak` 已处理）。
- vi-mode 插件会用 DECSCUSR 转义改光标形状 —— 已知和 Ghostty 的 `no-cursor` 冲突；保持默认 plugin 集合即可，不要主动加 `vi-mode`。

### Verify

```bash
test -d ~/.oh-my-zsh && \
  test -d ~/.oh-my-zsh/custom/themes/powerlevel10k && \
  test -f ~/.zshrc && \
  echo OK
```

## Nerd Fonts (MesloLGS NF)

Powerlevel10k 默认风格需要的图标字体。

### 安装

```bash
mkdir -p ~/.local/share/fonts
base="https://github.com/romkatv/powerlevel10k-media/raw/master"
for style in "Regular" "Bold" "Italic" "Bold%20Italic"; do
  wget -q -P ~/.local/share/fonts/ "$base/MesloLGS%20NF%20${style}.ttf"
done
fc-cache -fv
```

### 已知坑

- 文件名包含空格，URL 里要 `%20` 转义。
- `fc-cache -fv` 不跑的话 GTK / Ghostty 看不到新字体。

### Verify

```bash
test -f "$HOME/.local/share/fonts/MesloLGS NF Regular.ttf" && \
  fc-list | grep -q 'MesloLGS NF' && echo OK
```
````

- [ ] **Step 3: Re-run verify**

Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add docs/01-shell.md
git commit -m "docs: write 01-shell (ghostty + zsh + fonts)"
```

---

## Task 5: Write `docs/02-input.md`

**Files:**
- Modify: `docs/02-input.md`

**Content sources:**
- `modules/fcitx5.sh` — apt packages, `im-config`, autostart `.desktop`, `dconf` input-sources entry
- `modules/locale.sh` — `language-pack-zh-hans`, `locale-gen`, `update-locale`, English XDG dirs pin
- `configs/default/fcitx5/*.conf`

- [ ] **Step 1: Write the verify check**

Run:
```bash
grep -q 'fcitx5-chinese-addons' docs/02-input.md && \
  grep -q 'im-config' docs/02-input.md && \
  grep -q 'user-dirs.locale' docs/02-input.md && \
  grep -q 'zh_CN.UTF-8' docs/02-input.md && \
  echo OK
```
Expected: empty (FAIL).

- [ ] **Step 2: Replace `docs/02-input.md` with the full content**

````markdown
# 02 — 输入法 + 系统语言

中文拼音 (fcitx5) + 系统切到 zh_CN.UTF-8，但保持 `~/Desktop` `~/Downloads` 等 XDG 目录是英文。

## fcitx5

### 安装

```bash
sudo apt-get install -y \
    fcitx5 fcitx5-chinese-addons fcitx5-material-color fcitx5-config-qt

# 注册 fcitx5 为活动 IM 框架（写 ~/.xinputrc）
im-config -n fcitx5 || true

# 登录自启
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/fcitx5.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Fcitx 5
GenericName=Input Method
Comment=Start Input Method
Exec=fcitx5 -d
Icon=fcitx
Terminal=false
Categories=System;Utility;
StartupNotify=false
X-GNOME-Autostart-Phase=Applications
X-GNOME-AutoRestart=false
X-GNOME-Autostart-Notify=false
X-KDE-autostart-after=panel
EOF

# 把 fcitx5/pinyin 加进 GNOME input-sources（不加这一步 IM 默认不激活）
current="$(dconf read /org/gnome/desktop/input-sources/sources 2>/dev/null || echo '')"
if [[ "$current" != *"'pinyin'"* ]]; then
    if [[ -z "$current" || "$current" == "@a(ss) []" ]]; then
        dconf write /org/gnome/desktop/input-sources/sources \
            "[('xkb', 'us'), ('fcitx', 'pinyin')]"
    else
        merged="${current%]}, ('fcitx', 'pinyin')]"
        dconf write /org/gnome/desktop/input-sources/sources "$merged"
    fi
fi

# 立刻起来，不用注销
pgrep -x fcitx5 >/dev/null || (nohup fcitx5 -d &>/dev/null & disown)
```

### 配置

```bash
mkdir -p ~/.config/fcitx5/conf
cp configs/default/fcitx5/*.conf ~/.config/fcitx5/conf/

# 重启 fcitx5 让配置生效
pidof fcitx5 >/dev/null && fcitx5 -r -d &
```

### 已知坑

- `im-config` 必须以普通用户跑（不能 sudo），它写的是 `~/.xinputrc`。
- 不加 `dconf` 那一步，登录后 IM 看似装好但**实际没激活**。
- `fcitx5-config-qt` 提供 GUI 配置工具；不装也能用，但自查问题麻烦。
- 切换输入法快捷键默认是 **Ctrl+Space**。

### Verify

```bash
dpkg -l fcitx5 &>/dev/null && \
  test -f ~/.config/autostart/fcitx5.desktop && \
  test -f ~/.config/fcitx5/conf/pinyin.conf && \
  echo OK
```

## 系统语言：zh_CN.UTF-8 + 英文 XDG 目录

### 安装

```bash
sudo apt-get install -y \
    language-pack-zh-hans language-pack-gnome-zh-hans \
    fonts-noto-cjk fonts-noto-cjk-extra

sudo locale-gen zh_CN.UTF-8 en_US.UTF-8
sudo update-locale LANG=zh_CN.UTF-8 LANGUAGE="zh_CN:zh:en_US:en"

# 把 XDG 目录锁成英文 —— 不然下次登录 GNOME 会问"是否把 ~/Desktop 重命名为 ~/桌面"
mkdir -p ~/.config
echo "en_US" > ~/.config/user-dirs.locale
LC_ALL=C LANG=en_US.UTF-8 xdg-user-dirs-update --force || true
```

### 已知坑

- `update-locale` 改的是 `/etc/default/locale`，**注销重登才生效**。
- `LANGUAGE="zh_CN:zh:en_US:en"` 留英文 fallback，避免某些系统消息出现 missing translation 占位符。
- `user-dirs.locale` 必须在第一次登录前写好，否则 GNOME 会弹出重命名提示框。

### Verify

```bash
grep -q 'LANG=zh_CN.UTF-8' /etc/default/locale && \
  [ "$(cat ~/.config/user-dirs.locale 2>/dev/null)" = "en_US" ] && \
  echo OK
```
````

- [ ] **Step 3: Re-run verify**

Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add docs/02-input.md
git commit -m "docs: write 02-input (fcitx5 + zh_CN locale + en XDG dirs)"
```

---

## Task 6: Write `docs/03-desktop.md`

**Files:**
- Modify: `docs/03-desktop.md`

**Content sources:**
- `modules/theme.sh` — Orchis / Tela / Bibata install scripts
- `modules/gnome-extensions.sh` — gnome-tweaks + extension-manager + recommended extensions list
- `modules/gnome-settings.sh` — gsettings calls + dconf load
- `configs/default/gnome_extensions/gnome-extensions.dconf`, `configs/default/gnome_settings/gnome-interface.dconf`, `configs/default/wallpaper/wallhaven-21yzzx.jpg`

- [ ] **Step 1: Write the verify check**

Run:
```bash
grep -q 'Orchis-theme' docs/03-desktop.md && \
  grep -q 'Tela-icon-theme' docs/03-desktop.md && \
  grep -q 'Bibata-Modern-Ice' docs/03-desktop.md && \
  grep -q 'gnome-shell-extension-manager' docs/03-desktop.md && \
  grep -q 'Tela-blue' docs/03-desktop.md && \
  echo OK
```
Expected: empty (FAIL).

- [ ] **Step 2: Replace `docs/03-desktop.md` with the full content**

````markdown
# 03 — 桌面外观（主题 / 扩展 / GNOME 设置）

GTK 主题 + 图标 + 鼠标 + GNOME 扩展 + 字体/缩放/壁纸。

## GTK 主题：Orchis

```bash
mkdir -p ~/.themes
tmp=$(mktemp -d)
git clone --depth=1 https://github.com/vinceliuice/Orchis-theme.git "$tmp/Orchis-theme"
( cd "$tmp/Orchis-theme" && ./install.sh -d ~/.themes )
rm -rf "$tmp"
```

## 图标主题：Tela (blue 变体)

```bash
mkdir -p ~/.icons
tmp=$(mktemp -d)
git clone --depth=1 https://github.com/vinceliuice/Tela-icon-theme.git "$tmp/Tela-icon-theme"
( cd "$tmp/Tela-icon-theme" && ./install.sh -d ~/.icons blue )
rm -rf "$tmp"
```

## 鼠标主题：Bibata Modern Ice

```bash
tmp=$(mktemp -d)
wget -q -P "$tmp" \
  https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz
mkdir -p ~/.icons
tar -xf "$tmp/Bibata-Modern-Ice.tar.xz" -C ~/.icons/
rm -rf "$tmp"
```

## GNOME 扩展工具

```bash
sudo apt-get install -y gnome-tweaks gnome-shell-extension-manager dconf-cli
```

**推荐扩展**（用 Extension Manager GUI 装；apt 里没有）：

- Blur my Shell — https://extensions.gnome.org/extension/3193/blur-my-shell/
- Dash to Dock  — https://extensions.gnome.org/extension/307/dash-to-dock/
- Just Perfection — https://extensions.gnome.org/extension/3843/just-perfection/
- User Themes   — https://extensions.gnome.org/extension/19/user-themes/

## 应用 GNOME 设置（gsettings + dconf）

```bash
gsettings set org.gnome.desktop.interface icon-theme       'Tela-blue'
gsettings set org.gnome.desktop.interface cursor-theme     'Bibata-Modern-Ice'
gsettings set org.gnome.desktop.interface cursor-size      48
gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
gsettings set org.gnome.desktop.interface font-name        'Ubuntu Sans 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Sans Mono 13'

dconf load /org/gnome/desktop/interface/  < configs/default/gnome_settings/gnome-interface.dconf
dconf load /org/gnome/shell/extensions/   < configs/default/gnome_extensions/gnome-extensions.dconf
```

## 壁纸

```bash
mkdir -p ~/Pictures
cp configs/default/wallpaper/*.jpg ~/Pictures/
wp=~/Pictures/wallhaven-21yzzx.jpg
gsettings set org.gnome.desktop.background picture-uri      "file://$wp"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$wp"
```

## 已知坑

- **Dash to Dock 必须先在 Extension Manager 里装好**，再 `dconf load gnome-extensions.dconf` —— 否则 dconf 写的是空白 schema，扩展装上后这些设置不会被应用。
- `text-scaling-factor 1.25` 是高 DPI 屏的设定；外接 1080p 显示器要改回 `1.0`。
- Bibata `cursor-size 48` 适配缩放后的桌面；不缩放就用 `24`。

## Verify

```bash
test -d ~/.themes/Orchis && \
  test -d ~/.icons/Tela-blue && \
  test -d ~/.icons/Bibata-Modern-Ice && \
  command -v gnome-tweaks &>/dev/null && \
  echo OK
```
````

- [ ] **Step 3: Re-run verify**

Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add docs/03-desktop.md
git commit -m "docs: write 03-desktop (Orchis/Tela/Bibata + GNOME extensions + settings)"
```

---

## Task 7: Write `docs/04-apps-cn.md`

**Files:**
- Modify: `docs/04-apps-cn.md`

**Apps:** QQ, 微信 (Linux 原生), 网易云音乐, 百度网盘, SPlayer, ToDesk

**Content sources:**
- `install-apps.sh` — apt + .deb pattern, Zotero tar.xz pattern (Zotero is dev tools, goes in 05)
- Per-app official sites for download URLs (LLM-time fetch is acceptable)
- Spec change: SPlayer must use **GitHub releases**, not the Downloads `.deb`.

**Pattern note:** Several Chinese apps require fetching the latest .deb URL from the official site. Each section gives the *pattern*; the LLM consumer fetches the URL at install time.

- [ ] **Step 1: Write the verify check**

Run:
```bash
grep -q 'im.qq.com' docs/04-apps-cn.md && \
  grep -q 'weixin.qq.com' docs/04-apps-cn.md && \
  grep -q 'github.com/.*splayer' docs/04-apps-cn.md && \
  grep -q 'baidunetdisk' docs/04-apps-cn.md && \
  grep -q 'todesk' docs/04-apps-cn.md && \
  echo OK
```
Expected: empty (FAIL).

- [ ] **Step 2: Replace `docs/04-apps-cn.md` with the full content**

````markdown
# 04 — 中文应用

QQ、微信、网易云音乐、百度网盘、SPlayer、ToDesk。

## 通用模式：`apt install ./xxx.deb`

中文桌面应用大多以 `.deb` 形式分发。固定流程：

```bash
# 1. 从官网下载 .deb 到 ~/Downloads（必要时让用户提供链接）
# 2. 用 apt 装 —— 不要用 dpkg -i，遇缺依赖会卡住
sudo apt-get install -y ./xxx.deb
```

## QQ

### 安装

下载页：https://im.qq.com/linuxqq/index.shtml （选 amd64 .deb）

```bash
sudo apt-get install -y ~/Downloads/QQ_*_amd64.deb
```

### Verify

```bash
command -v qq &>/dev/null || test -f /usr/share/applications/qq.desktop && echo OK
```

## 微信（Linux 原生版）

### 安装

下载页：https://weixin.qq.com/?platform=linux （`.deb` 包）

```bash
sudo apt-get install -y ~/Downloads/WeChat_*_amd64.deb
```

### 已知坑

- 必须用**官方原生 Linux 版**（基于 Electron，腾讯自己出的），不是 wine/deepin-wine 套壳。
- 安装完首次运行可能要扫码登录；扫描时关闭 fcitx5 避免输入法干扰。

### Verify

```bash
test -f /usr/share/applications/wechat.desktop && echo OK
```

## 网易云音乐

### 安装

官方包久未更新，常用社区维护版本：https://github.com/PIPIPIG233666/netease-cloud-music-gtk-rs/releases （或用户自选）。如果用户已经有官方 `.deb`：

```bash
sudo apt-get install -y ~/Downloads/netease-cloud-music_*_amd64.deb
```

### Verify

```bash
test -f /usr/share/applications/netease-cloud-music.desktop && echo OK
```

## 百度网盘

### 安装

下载页：https://pan.baidu.com/download （Linux 客户端 .deb）

```bash
sudo apt-get install -y ~/Downloads/baidunetdisk_*_amd64.deb
```

### 已知坑

- 装完 `baidunetdisk` 命令**不在 PATH**里，但 `Activities` 菜单里能搜到。这是上游打包问题，不是装错了。

### Verify

```bash
test -f /usr/share/applications/baidunetdisk.desktop && echo OK
```

## SPlayer（GitHub releases）

> 与老 `install-apps.sh` 不同 —— 改为从 GitHub releases 直接装。

### 安装

下载页：https://github.com/imsyy/SPlayer/releases （选 `splayer*amd64.deb`）

```bash
sudo apt-get install -y ~/Downloads/splayer-*-amd64.deb
```

### Verify

```bash
test -f /usr/share/applications/SPlayer.desktop && echo OK
```

## ToDesk

### 安装

下载页：https://www.todesk.com/linux.html （`.deb`）

```bash
sudo apt-get install -y ~/Downloads/todesk-*-amd64.deb
```

### Verify

```bash
command -v todesk &>/dev/null && echo OK
```
````

- [ ] **Step 3: Re-run verify**

Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add docs/04-apps-cn.md
git commit -m "docs: write 04-apps-cn (QQ/WeChat/NetEase/BaiduNetdisk/SPlayer/ToDesk)"
```

---

## Task 8: Write `docs/05-apps-dev.md`

**Files:**
- Modify: `docs/05-apps-dev.md`

**Apps:** VS Code, Cursor, GitKraken, Termius, Zotero, Miniconda, Typora

**Critical pitfalls (must appear):**
- Miniconda: `conda config --set auto_activate_base false` after install.
- FileZilla NOT in this file (it's `06-apps-misc.md`).

- [ ] **Step 1: Write the verify check**

Run:
```bash
grep -q 'auto_activate_base false' docs/05-apps-dev.md && \
  grep -q 'cursor.com' docs/05-apps-dev.md && \
  grep -q 'gitkraken' docs/05-apps-dev.md && \
  grep -q 'termius' docs/05-apps-dev.md && \
  grep -q 'typora.io' docs/05-apps-dev.md && \
  grep -q 'Miniconda3' docs/05-apps-dev.md && \
  grep -q '/opt/zotero' docs/05-apps-dev.md && \
  echo OK
```
Expected: empty (FAIL).

- [ ] **Step 2: Replace `docs/05-apps-dev.md` with the full content**

````markdown
# 05 — 开发工具

VS Code, Cursor, GitKraken, Termius, Zotero, Miniconda, Typora。

## VS Code

### 安装

```bash
# 走微软官方仓库
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
  sudo gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
  https://packages.microsoft.com/repos/code stable main" | \
  sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt-get update -qq && sudo apt-get install -y code
```

### 已知坑

- 第一次 `apt update` 可能会跳出交互式 whiptail 问"是否启用微软仓库"；非交互式环境提前 `export DEBIAN_FRONTEND=noninteractive`。

### Verify

```bash
command -v code && echo OK
```

## Cursor

AI 代码编辑器（VS Code fork）。

### 安装

下载页：https://cursor.com/download （Linux x64）。可能是 `.AppImage` 或 `.deb`：

```bash
# 如果是 .deb：
sudo apt-get install -y ~/Downloads/cursor*_amd64.deb

# 如果是 .AppImage：
sudo install -m 755 ~/Downloads/cursor-*.AppImage /opt/cursor.AppImage
sudo ln -sf /opt/cursor.AppImage /usr/local/bin/cursor
# 自己写 .desktop 启动器（图标自带；下面给个最小版）
cat | sudo tee /usr/share/applications/cursor.desktop <<'EOF'
[Desktop Entry]
Name=Cursor
Exec=/opt/cursor.AppImage --no-sandbox %U
Type=Application
Icon=cursor
Categories=Development;IDE;
Terminal=false
EOF
```

### Verify

```bash
command -v cursor &>/dev/null || test -f /usr/share/applications/cursor.desktop && echo OK
```

## GitKraken

### 安装

下载页：https://www.gitkraken.com/download/linux-deb

```bash
sudo apt-get install -y ~/Downloads/gitkraken-amd64.deb
```

### Verify

```bash
command -v gitkraken && echo OK
```

## Termius

SSH 客户端（GUI）。

### 安装

下载页：https://termius.com/linux （提供 snap 和 .deb）。

```bash
# .deb 路线
sudo apt-get install -y ~/Downloads/Termius-*.deb

# 或 snap 路线
sudo snap install termius-app
```

### Verify

```bash
command -v termius &>/dev/null || snap list | grep -q termius-app && echo OK
```

## Zotero

文献管理。上游 tar.xz，不进 apt。

### 安装

下载页：https://www.zotero.org/download/

```bash
sudo rm -rf /opt/zotero
sudo tar -xJf ~/Downloads/Zotero-*_linux-x86_64.tar.xz -C /opt
sudo mv /opt/Zotero_linux-x86_64 /opt/zotero
sudo /opt/zotero/set_launcher_icon
sudo ln -sf /opt/zotero/zotero.desktop /usr/share/applications/zotero.desktop
sudo ln -sf /opt/zotero/zotero          /usr/local/bin/zotero
sudo update-desktop-database /usr/share/applications 2>/dev/null || true
```

### 已知坑

- `set_launcher_icon` 必须跑 —— 它会修正 `.desktop` 里的绝对路径。
- 装完 GNOME 不会自动看到，跑 `update-desktop-database` 或注销重登。

### Verify

```bash
test -x /opt/zotero/zotero && command -v zotero && echo OK
```

## Miniconda

### 安装

```bash
# 装到 ~/miniconda3，避免和系统 Python 抢 PATH
wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  -O /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
rm /tmp/miniconda.sh

# 让 conda 命令在当前 session 可用并把 init 写进 ~/.zshrc
"$HOME/miniconda3/bin/conda" init zsh
```

### **必做** —— 关闭 base 环境自动激活

```bash
"$HOME/miniconda3/bin/conda" config --set auto_activate_base false
```

### 已知坑

- **不关 `auto_activate_base`，每次开 shell 都会进 `(base)`，挡住别的 venv / nvm 提示**。这是设计这一节的核心动机。
- `conda init zsh` 修改 `~/.zshrc`；如果在 01-shell 里已经用项目 zshrc 覆盖过，**这一步必须在 zsh 配置生效之后跑**。
- 不要装 Anaconda 全家桶 —— 太重；要哪个包用 `conda install` 加。

### Verify

```bash
command -v conda &>/dev/null && \
  conda config --show auto_activate_base 2>/dev/null | grep -q 'False' && \
  echo OK
```

## Typora

Markdown 编辑器（付费但支持 Linux apt 仓库）。

### 安装

```bash
wget -qO - https://typora.io/linux/public-key.asc | \
  sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/typora.gpg
echo 'deb https://typora.io/linux ./' | \
  sudo tee /etc/apt/sources.list.d/typora.list
sudo apt-get update -qq && sudo apt-get install -y typora
```

### Verify

```bash
command -v typora && echo OK
```
````

- [ ] **Step 3: Re-run verify**

Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add docs/05-apps-dev.md
git commit -m "docs: write 05-apps-dev (VSCode/Cursor/GitKraken/Termius/Zotero/Miniconda/Typora)"
```

---

## Task 9: Write `docs/06-apps-misc.md`

**Files:**
- Modify: `docs/06-apps-misc.md`

**Apps:** Chrome, VLC, OBS Studio, FileZilla.

**Critical pitfall:** FileZilla MUST go through apt (GTK3); never use upstream tarball (GTK2 → invisible cursor under fcitx5).

- [ ] **Step 1: Write the verify check**

Run:
```bash
grep -q 'google-chrome' docs/06-apps-misc.md && \
  grep -q 'GTK3' docs/06-apps-misc.md && \
  grep -q 'apt-get install -y filezilla' docs/06-apps-misc.md && \
  grep -q 'apt-get install -y vlc' docs/06-apps-misc.md && \
  grep -q 'obs-studio' docs/06-apps-misc.md && \
  echo OK
```
Expected: empty (FAIL).

- [ ] **Step 2: Replace `docs/06-apps-misc.md` with the full content**

````markdown
# 06 — 其他应用

Chrome, VLC, OBS Studio, FileZilla。

## Google Chrome

### 安装

```bash
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
  -O /tmp/chrome.deb
sudo apt-get install -y /tmp/chrome.deb
rm /tmp/chrome.deb
```

### Verify

```bash
command -v google-chrome && echo OK
```

## VLC

```bash
sudo apt-get install -y vlc
```

### Verify

```bash
command -v vlc && echo OK
```

## OBS Studio

### 安装

```bash
sudo add-apt-repository -y ppa:obsproject/obs-studio
sudo apt-get update -qq
sudo apt-get install -y obs-studio
```

### Verify

```bash
command -v obs && echo OK
```

## FileZilla（必须走 apt / GTK3）

### 安装

```bash
sudo apt-get install -y filezilla
```

### 已知坑

- **绝对不要用 https://filezilla-project.org 上游 tarball** —— 它绑定的是 wxWidgets-GTK2，在现代 Ubuntu + fcitx5 下文本输入框光标完全不可见。
- apt 仓库里的 `filezilla` 链接的是 `wxgtk3`，是 **GTK3** 构建，没这个 bug。
- 老 `install-apps.sh` 之前从 Downloads 装 GTK2 tarball 翻车过 —— 已废弃，统一走 apt。

### Verify

```bash
command -v filezilla && \
  ldd "$(command -v filezilla)" 2>/dev/null | grep -q 'wxgtk3\|gtk-3' && \
  echo OK
```
````

- [ ] **Step 3: Re-run verify**

Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add docs/06-apps-misc.md
git commit -m "docs: write 06-apps-misc (Chrome/VLC/OBS/FileZilla; FileZilla via apt only)"
```

---

## Task 10: Rewrite `README.md`

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Write the verify check**

Run:
```bash
grep -q 'Claude Code' README.md && \
  grep -q 'INSTALL.md' README.md && \
  ! grep -q 'whiptail' README.md && \
  ! grep -q 'Module Development' README.md && \
  echo OK
```
Expected: empty (FAIL — old README still has whiptail/Module Development).

- [ ] **Step 2: Replace `README.md` with the new content**

````markdown
# ubuntu-rice

为新装 Ubuntu 系统快速恢复个人偏好的桌面环境。
本仓库**面向 LLM 阅读** —— 把它扔给 Claude Code，让它读 `INSTALL.md` 引导你完成安装。

![Ubuntu 22.04](https://img.shields.io/badge/Ubuntu-22.04-E95420?logo=ubuntu)
![Ubuntu 24.04](https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu)
![License](https://img.shields.io/badge/License-MIT-blue)

## Screenshots

![Desktop Preview](screenshots/desktop-preview.png)

## 使用方法

```bash
git clone git@github.com:Mizoreww/ubuntu-rice.git
cd ubuntu-rice
# 然后开 Claude Code，让它读 INSTALL.md 即可
```

LLM 会按章节问你装哪些组件、把命令贴出来等你 OK 再跑。**不再有"一键脚本"。**

## 内容覆盖

| 节 | 文件 | 内容 |
|---|---|---|
| 00 | [docs/00-prereq.md](docs/00-prereq.md) | 代理 / git / SSH（仅 Clash fake-ip 环境需要） |
| 01 | [docs/01-shell.md](docs/01-shell.md) | Ghostty 终端 + Zsh + Powerlevel10k + MesloLGS NF 字体 |
| 02 | [docs/02-input.md](docs/02-input.md) | fcitx5 中文输入法 + zh_CN.UTF-8（保留英文 XDG 目录） |
| 03 | [docs/03-desktop.md](docs/03-desktop.md) | Orchis GTK / Tela 图标 / Bibata 鼠标 / GNOME 扩展 / 壁纸 |
| 04 | [docs/04-apps-cn.md](docs/04-apps-cn.md) | QQ / 微信 / 网易云 / 百度网盘 / SPlayer / ToDesk |
| 05 | [docs/05-apps-dev.md](docs/05-apps-dev.md) | VS Code / Cursor / GitKraken / Termius / Zotero / Miniconda / Typora |
| 06 | [docs/06-apps-misc.md](docs/06-apps-misc.md) | Chrome / VLC / OBS / FileZilla |

## 自定义配置

替换 `configs/default/<组件>/` 下的文件即可（git 跟踪它们，方便对比变更）。
`configs/custom/` 已 gitignore，留给本机覆盖（如有需要）。

## License

[MIT](LICENSE)
````

- [ ] **Step 3: Re-run verify**

Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README for LLM-driven install workflow"
```

---

## Task 11: Delete legacy scripts and dirs

**Pre-condition:** All `docs/*.md` written and committed (Tasks 4–9). The pitfall content in `modules/` has been migrated.

- [ ] **Step 1: Sanity-check the migration is complete**

Run this aggregate verify — all required pitfall keywords from the spec must be present somewhere in `docs/`:

```bash
cd /home/limx/Desktop/ubuntu-rice
for kw in \
  'mkasberg/ghostty-ubuntu' 'no-cursor' 'python3-nautilus' \
  'wl-clipboard' 'nautilus-extension-gnome-terminal' \
  'auto_activate_base false' 'GTK3' 'wxgtk3' \
  'user-dirs.locale' 'socks5://127.0.0.1:7897' 'ProxyCommand' ; do
  if ! grep -rq "$kw" docs/ INSTALL.md ; then
    echo "MISSING: $kw"
  fi
done
echo "DONE"
```

Expected: only `DONE`. Any `MISSING:` line means a Task 3-9 was incomplete — go fix the relevant doc before deleting anything.

- [ ] **Step 2: Run the deletes**

```bash
cd /home/limx/Desktop/ubuntu-rice
git rm install.sh uninstall.sh backup.sh restore.sh
git rm install-ghostty.sh install-apps.sh fix-now.sh
git rm -r lib/ modules/ legacy/
```

- [ ] **Step 3: Verify the working tree is clean of scripts**

Run:
```bash
test ! -e install.sh && \
  test ! -e modules && \
  test ! -e legacy && \
  test ! -e lib && \
  echo OK
```
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git commit -m "chore: remove legacy install scripts (replaced by docs/)

All commands and pitfall notes have been migrated into docs/01..06 and
INSTALL.md. The TUI installer (install.sh + lib/ + modules/) plus
auxiliary scripts (install-ghostty.sh, install-apps.sh, fix-now.sh,
backup.sh, restore.sh) and the legacy/ archive are no longer needed."
```

---

## Task 12: Final cross-check

**Files:**
- Read-only verification across all new docs.

- [ ] **Step 1: Confirm directory listing matches spec**

Run:
```bash
ls -A /home/limx/Desktop/ubuntu-rice
```
Expected (no scripts, no `lib/`, no `modules/`, no `legacy/`):

```
.git
.gitignore
INSTALL.md
LICENSE
README.md
configs
docs
screenshots
```

- [ ] **Step 2: Run every doc's `Verify` block in dry-run mode**

For each doc, the `## Verify` block at end should be syntactically valid bash. Quick check — extract them and `bash -n`:

```bash
cd /home/limx/Desktop/ubuntu-rice
for f in INSTALL.md docs/*.md; do
  awk '/^### Verify$/{flag=1; next} /^```bash/{if(flag){bash=1; next}} /^```/{if(bash){bash=0; flag=0}} bash' "$f" \
    | bash -n - 2>&1 | head -5
done
```
Expected: no syntax errors printed.

- [ ] **Step 3: Run the aggregate pitfall-keyword verify (same as Task 11 Step 1)**

Expected: only `DONE`.

- [ ] **Step 4: Push to origin**

```bash
git push origin main
```

If this fails with a TLS or auth error, see `docs/00-prereq.md` (the SOCKS5 + SSH config it documents should already be active on this machine — `~/.ssh/config` and `git config --global http.https://github.com/.proxy` were set in a prior session).

- [ ] **Step 5: Final task list update**

Mark all plan tasks complete in TaskList.

---

## Spec coverage check

- ✅ Goal 1 (md-driven, no scripts) — Tasks 1–11
- ✅ Goal 2 (preserve all known pitfalls) — Task 11 Step 1 enforces grep coverage
- ✅ Goal 3 (clone → Claude Code reads INSTALL.md → restore desktop) — Task 2 + per-component docs
- ✅ Goal 4 (老脚本 git rm) — Task 11
- ✅ App list (16 apps incl. Cursor/Termius/Miniconda/Typora) — Tasks 7–9
- ✅ Single source for configs (`configs/default/*`) — preserved, referenced not duplicated
- ✅ Each component has Install / Configure / Pitfalls / Verify — template enforced in INSTALL.md and per-doc verify greps
- ✅ Miniconda `auto_activate_base false` — Task 8 verify locks it in
- ✅ FileZilla via apt only (GTK3) — Task 9 verify locks it in
- ✅ SPlayer source change to GitHub releases — Task 7 verify locks it in
- ✅ legacy/ removed — Task 11
