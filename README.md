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
