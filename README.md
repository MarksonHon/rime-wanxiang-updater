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

### Linux

大多数 Linux 系统可以正确执行此脚本，如果运行异常，请注意以上三个软件包是否安装。

### macOS

macOS 自带的 `zsh`，理论上可以直接运行此脚本。如果运行失败，建议从 `Homebrew` 安装 `bash`。

### Windows

运行脚本之前先退出小狼毫的算法服务，更新后再重启算法服务并重新部署。

#### Git-Bash

你可以安装 [Windows 版本的 Git][def0]，并在 `git-bash` 内运行此脚本；或者，使用具有类似环境的 `Cygwin`、`MSYS2`。

#### Busybox

使用[**具有 Unicode 支持**的 busybox][def2] 的 `ash` 来运行此脚本，这要求操作系统上已经自带了 `curl.exe`。一般情况下，Windows 10 或更新的操作系统已经自带了该软件。启动 `ash` 的方法是，在 `busybox` 同目录下创建一个批处理文件，内容如下：

```batch
chcp 65001
busybox64u.exe ash
```

保存并运行该脚本即可启动 `ash`，然后就可以运行脚本了。

### Android

需要使用 [Termux][def1]，并在安装 `curl` 之后运行本脚本，需要授予 Termux 完全的文件管理权限。

[def0]: https://git-scm.com/downloads/win
[def1]: https://termux.dev/cn
[def2]: https://frippery.org/files/busybox/busybox64u.exe