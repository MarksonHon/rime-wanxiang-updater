# 万象输入方案更新器

## 使用方式

打开一个终端然后运行：

```sh
sh -c "$(curl -Ls https://github.com/MarksonHon/rime-wanxiang-updater/raw/refs/heads/main/updater.sh)"
```

## 运行环境要求

要求计算机上安装了 `curl`、`unzip` 与一个符合 POSIX Shell 语言标准的解析器，例如 `bash`。这些工具在大多数操作系统上都能免费获取且正常运行。

### Linux

大多数 Linux 系统可以正确执行此脚本，如果运行异常，请注意以上三个软件包是否安装。

### macOS

macOS 自带的 `zsh`，理论上可以直接运行此脚本。如果运行失败，建议从 `Homebrew` 安装 `bash`。

### Windows

Windows 需要安装 [Git 的 Windows 客户端][def0]，并在 `git-bash` 内运行此脚本。

或者，你也可以从 `scoop` 安装 `busybox`，然后在 `ash` 里面运行此脚本，但此种方式未作测试，也不保证可用性。

### Android

需要使用 [Termux][def1]，并在安装 `curl` 之后运行本脚本，需要给 Termux 授予完全的文件管理权限。

[def0]: https://git-scm.com/downloads/win
[def1]: https://termux.dev/cn