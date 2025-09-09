# Wanxiang Input Scheme Updater

## Usage

Open a Terminal and input:

```sh
sh -c "$(curl -Ls https://github.com/MarksonHon/rime-wanxiang-updater/raw/refs/heads/main/updater.sh)"
```

## System Requirements

Requires `curl`, `unzip`, and a POSIX-compliant shell interpreter (e.g., `bash`) installed on your computer. These tools are freely available and functional on most operating systems.

### Linux

Most Linux systems can execute this script correctly. If encountering issues, verify the installation of the three aforementioned packages.

### macOS

macOS's built-in `zsh` should theoretically run this script directly. If it fails, install `bash` via `Homebrew`.

### Windows

Windows requires the [Git for Windows client][def0]. Run this script within `git-bash`.

Alternatively, you can install `busybox` via `scoop` and run the script within `ash`. However, this method has not been tested and its functionality is not guaranteed.

### Android

Requires [Termux][def1]. After installing `curl`, run this script. Grant Termux full file management permissions.

[def0]: https://git-scm.com/downloads/win
[def1]: https://termux.dev/cn