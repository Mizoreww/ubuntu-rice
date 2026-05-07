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
