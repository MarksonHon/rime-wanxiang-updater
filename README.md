# 万象输入方案更新器

## 获取并运行

打开一个终端然后运行：

```sh
sh -c "$(curl -Ls https://github.com/MarksonHon/rime-wanxiang-updater/raw/refs/heads/main/updater.sh)"
```

如果你在中国境内，那么可能需要通过以下方式才能正常获取脚本：

```sh
sh -c "$(curl --doh-url https://223.5.5.5/dns-query -Ls https://cdn.jsdelivr.net/gh/MarksonHon/rime-wanxiang-updater@main/updater.sh)"
```

## 运行环境要求

要求计算机上安装了 `curl`、`unzip` 与一个符合 POSIX Shell 语言标准的解析器，例如 `bash`。这些工具在大多数操作系统上都能免费获取且正常运行。

### Linux 与 macOS

此脚本应当能顺利地在“终端”中运行，不过要留意 Linux 的 `apparmor` 或 macOS 的权限管理所带来的访问限制。

### Windows

运行脚本之前先退出小狼毫的算法服务，更新后再重启算法服务并重新部署。你可以安装 [Windows 版本的 Git][def0]，并在 `git-bash` 内运行此脚本；或者，使用具有类似环境的 `Cygwin`、`MSYS2` 也可以正常运行此脚本。

### Android

#### 同文

需要使用 [Termux][def1]，并在安装 `curl` 之后运行本脚本，需要授予 Termux 完全的文件管理权限。

#### fcitx5-rime

由于 Android 限制，`/data/data` 是不可访问的，因此你需要通过小企鹅输入法的“设置”手动打开 Rime 的配置目录，然后把已经配置好的文件复制过去。

[def0]: https://git-scm.com/downloads/win
[def1]: https://termux.dev/cn
