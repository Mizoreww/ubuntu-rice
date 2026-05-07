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
