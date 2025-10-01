#!/bin/sh

set -e

GITHUB_TAGS_URL="https://api.github.com/repos/amzxyz/rime_wanxiang/tags"
GITHUB_RELEASES_URL="https://github.com/amzxyz/rime_wanxiang/releases"
CNB_RELEASES_URL="https://cnb.cool/amzxyz/rime-wanxiang/-/releases"

WHITE_LIST_FILES="简纯+.trime.yaml default.yaml squirrel.yaml weasel.yaml"

echo_red() {
    printf '\033[31m%s\033[0m\n' "$*"
}
echo_yellow() {
    printf '\033[33m%s\033[0m\n' "$*"
}
echo_green() {
    printf '\033[32m%s\033[0m\n' "$*"
}

get_latest_wanxiang_version() {
    latest_version="$(curl -s $GITHUB_TAGS_URL | grep 'name' | awk -F '["]' 'NR == 1 {print $4}')"
}

get_local_wanxiang_version() {
    [ -f "$TARGET_DIR/wanxiang-version.txt" ] && local_version="$(cat "$TARGET_DIR/wanxiang-version.txt")" || local_version="v0.0.0"
}

test_github_api() {
    echo_yellow "测试是否能连接到 GitHub API，这可能需要 10 秒钟左右，如果失败将自动重试若干次..."
    while true; do
        if [ "$(curl -o /dev/null -m 10 -s -w "%{http_code}\n" $GITHUB_TAGS_URL)" != "200" ]; then
            i=$((i + 1))
            echo_yellow "GitHub API 连接失败，尝试重新连接到 GitHub API ($i/6)..."
            [ $i -gt 3 ] && return
            sleep 2
        elif [ "$(curl --doh-url https://223.5.5.5/dns-query -o /dev/null -m 10 -s -w "%{http_code}\n" $GITHUB_TAGS_URL)" != "200" ]; then
            i=$((i + 1))
            echo_yellow "GitHub API 连接失败，尝试重新连接到 GitHub API ($i/6)..."
            [ $i -gt 6 ] && echo_red "连接 GitHub API 失败，请检查网络后再次尝试。" && exit 1
            sleep 2
        else
            echo_green "成功连接到 GitHub API。"
            break
        fi
    done
}

test_github() {
    echo_yellow "测试连接到 GitHub 的延迟，这可能需要 10 秒钟左右..."
    if ! (TIMEOUT_GITHUB=$(curl -o /dev/null -m 10 -s -w "%{time_total}" $GITHUB_RELEASES_URL)); then
        TIMEOUT_GITHUB=1000
    fi
}

test_cnb() {
    echo_yellow "测试连接到 CNB 的延迟，这可能需要 10 秒钟左右..."
    if ! (TIMEOUT_CNB=$(curl -o /dev/null -m 10 -s -w "%{time_total}" $CNB_RELEASES_URL)); then
        TIMEOUT_CNB=1000
    fi
}

test_network() {
    test_github
    test_cnb
    if [ "$TIMEOUT_CNB" = "1000" ] && [ "$TIMEOUT_GITHUB" = "1000" ]; then
        echo_red "无法连接到 GitHub 或 CNB，请检查网络连接。"
        exit 1
    fi
    DOWNLOAD_PLATFORM=$(awk -v timeout_github="$TIMEOUT_GITHUB" -v timeout_cnb="$TIMEOUT_CNB" 'BEGIN {
    if (timeout_github < timeout_cnb) {
        print "github" } else {
            print "cnb"
        }
    }')
}
define_download_urls() {
    if [ "$DOWNLOAD_PLATFORM" = "github" ]; then
    DOWNLOAD_PLATFORM_FULLNAME="GitHub"
        WANXIANG_BASE="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-base.zip"
        WANXIANG_FLYPY="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-flypy-fuzhu.zip"
        WANXIANG_HANXIN="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-hanxin-fuzhu.zip"
        WANXIANG_MOQI="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-moqi-fuzhu.zip"
        WANXIANG_TIGER="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-tiger-fuzhu.zip"
        WANXIANG_WUBI="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-wubi-fuzhu.zip"
        WANXIANG_ZRM="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-zrm-fuzhu.zip"
        LANGUAGE_MODULE="https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram"
    elif [ "$DOWNLOAD_PLATFORM" = "cnb" ]; then
        WANXIANG_BASE="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-base.zip"
        WANXIANG_FLYPY="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-flypy-fuzhu.zip"
        WANXIANG_HANXIN="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-hanxin-fuzhu.zip"
        WANXIANG_MOQI="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-moqi-fuzhu.zip"
        WANXIANG_TIGER="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-tiger-fuzhu.zip"
        WANXIANG_WUBI="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-wubi-fuzhu.zip"
        WANXIANG_ZRM="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-zrm-fuzhu.zip"
        LANGUAGE_MODULE="https://cnb.cool/amzxyz/rime-wanxiang/-/releases/download/model/wanxiang-lts-zh-hans.gram"
        DOWNLOAD_PLATFORM_FULLNAME="CNB - 云原生构建平台"
    fi
    echo_yellow "根据延迟，选择从延迟更低的 $DOWNLOAD_PLATFORM_FULLNAME 下载。"
}

ask_target_directory() {
    echo_green "选择输入框架，或者输入自定义安装位置："
    echo "1. ibus-rime"
    echo "2. fcitx5-rime"
    echo "3. fcitx5-rime(FlatHub)"
    echo "4. Weasel | 小狼毫"
    echo "5. Squirrel | 鼠鬚管 | 鼠须管"
    echo "6. Trime | 同文"
    echo "7. 手动输入自定义目录"
    echo "输入你的选择： "
    read -r INPUT_METHOD
    case $INPUT_METHOD in
    1) TARGET_DIR="$HOME/.config/ibus/rime" ;;
    2) TARGET_DIR="$HOME/.local/share/fcitx5/rime" ;;
    3) TARGET_DIR="$HOME/.var/app/org.fcitx.Fcitx5/data/fcitx5/rime" ;;
    4) TARGET_DIR="$HOME/AppData/Roaming/Rime" ;;
    5) TARGET_DIR="$HOME/Library/Rime" ;;
    6) TARGET_DIR="/storage/emulated/0/rime" ;;
    7) echo_green "输入你的自定义目录: "
       read -r TARGET_DIR
       ;;
    *) TARGET_DIR="error" ;;
    esac
}

ask_target_edition() {
    notice_stand="标准版输入方案"
    notice_zrm="自然码辅助版本"
    notice_tiger="虎码首末辅助版本"
    notice_moqi="墨奇辅助版本"
    notice_xiaohe="小鹤辅助版本"
    notice_wubi="五笔前2辅助版本"
    notice_hanxin="汉芯辅助版本"
    [ -f "$TARGET_DIR/wanxiang-edition.txt" ] && local_edition="$(cat "$TARGET_DIR/wanxiang-edition.txt")" || local_edition="none"
    if [ "$local_edition" != "none" ]; then
        case $local_edition in
        "stand") notice_old=$notice_stand ;;
        "zrm") notice_old=$notice_zrm ;;
        "tiger") notice_old=$notice_tiger ;;
        "moqi") notice_old=$notice_moqi ;;
        "xiaohe") notice_old=$notice_xiaohe ;;
        "wubi") notice_old=$notice_wubi ;;
        "hanxin") notice_old=$notice_hanxin ;;
        *) notice_old="broken" ;;
        esac
    fi
    echo_yellow "当前配置方案：$notice_old"
    echo_yellow "当前版本：$local_version"
    echo_green "请选择输入方案："
    echo "1. $notice_stand"
    echo "2. $notice_zrm"
    echo "3. $notice_tiger"
    echo "4. $notice_moqi"
    echo "5. $notice_xiaohe"
    echo "6. $notice_wubi"
    echo "7. $notice_hanxin"
    echo "输入你的选择："
    read -r EDITION
    case $EDITION in
    1) SELECTED_EDITION="stand" && notice=$notice_stand ;;
    2) SELECTED_EDITION="zrm" && notice=$notice_zrm ;;
    3) SELECTED_EDITION="tiger" && notice=$notice_tiger ;;
    4) SELECTED_EDITION="moqi" && notice=$notice_moqi ;;
    5) SELECTED_EDITION="xiaohe" && notice=$notice_xiaohe ;;
    6) SELECTED_EDITION="wubi" && notice=$notice_wubi ;;
    7) SELECTED_EDITION="hanxin" && notice=$notice_hanxin ;;
    *) SELECTED_EDITION="error" ;;
    esac
    if [ "$local_edition" != "none" ] && [ "$SELECTED_EDITION" != "$local_edition" ]; then
        echo_yellow "您选择的输入方案：$notice"
        echo_yellow "您当前使用的输入方案：$notice_old"
        echo_yellow "如果继续，方案将被替换，继续吗？(y/n)"
        read -r CONFIRM
        if [ "$CONFIRM" != "y" ]; then
            SELECTED_EDITION="error"
        else
            SWITCH_YES="yes"
        fi
    fi
}

compare_versions() {
    if [ "$SWITCH_YES" != "yes" ] && [ "$latest_version" = "$local_version" ]; then
        echo "当前已经是最新版本：$latest_version"
        exit 0
    else
        echo "有新版本可用: $latest_version"
        echo "您当前使用的版本: $notice_old: $local_version"
        echo "新版本: $notice: $latest_version"
    fi
}

define_target_urls() {
    case "$SELECTED_EDITION" in
    "stand") TARGET_URL="$WANXIANG_BASE" ;;
    "zrm") TARGET_URL="$WANXIANG_ZRM" ;;
    "tiger") TARGET_URL="$WANXIANG_TIGER" ;;
    "moqi") TARGET_URL="$WANXIANG_MOQI" ;;
    "xiaohe") TARGET_URL="$WANXIANG_FLYPY" ;;
    "wubi") TARGET_URL="$WANXIANG_WUBI" ;;
    "hanxin") TARGET_URL="$WANXIANG_HANXIN" ;;
    esac
}

install_wanxiang() {
    temp_dir=$(mktemp -d -t "wanxiang-XXXXXXX")
    echo_green "下载 $TARGET_URL"
    if ! curl -# -L -o "$temp_dir/wanxiang.zip" "$TARGET_URL"; then
        echo_red "下载失败，请检查网络连接或稍后重试。"
        rm -rf "$temp_dir"
        exit 1
    fi
    echo_green "下载 $LANGUAGE_MODULE"
    if ! curl -# -L -o "$temp_dir/wanxiang-lts-zh-hans.gram" "$LANGUAGE_MODULE"; then
        echo_red "下载失败，请检查网络连接或稍后重试。"
        rm -rf "$temp_dir"
        exit 1
    fi
    if [ -d "$TARGET_DIR" ]; then
        [ -f "$TARGET_DIR/wanxiang-version.txt" ] && rm -f "$TARGET_DIR/wanxiang-version.txt"
        [ -f "$TARGET_DIR/wanxiang-lts-zh-hans.gram" ] && rm -f "$TARGET_DIR/wanxiang-lts-zh-hans.gram"
    fi
    if [ -f "$TARGET_DIR/filelist.txt" ]; then
        for file in $(cat "$TARGET_DIR/filelist.txt"); do
            [ -f "${TARGET_DIR:?}/$file" ] && rm -f "${TARGET_DIR:?}/$file"
            [ -d "${TARGET_DIR:?}/$file" ] && rm -rf "${TARGET_DIR:?}/$file"
        done
        rm -f "$TARGET_DIR/filelist.txt"
    fi
    [ -d "$TARGET_DIR" ] || mkdir -p "$TARGET_DIR"
    unzip -l "$temp_dir/wanxiang.zip" -x $WHITE_LIST_FILES | awk 'NR>3 && $0 !~ /----/ {print $4}' | tee "$TARGET_DIR"/filelist.txt >/dev/null
    echo_green "将下载的文件安装到 $TARGET_DIR"
    unzip "$temp_dir/wanxiang.zip" -d "$TARGET_DIR" -x $WHITE_LIST_FILES
    for file in $WHITE_LIST_FILES; do
        if [ "$SWITCH_YES" = "yes" ]; then
            [ -f "$TARGET_DIR/$file" ] && rm -f "$TARGET_DIR/$file"
            unzip "$temp_dir/wanxiang.zip" "$file" -d "$TARGET_DIR"
        else
            [ ! -f "$TARGET_DIR/$file" ] && unzip "$temp_dir/wanxiang.zip" "$file" -d "$TARGET_DIR"
        fi
    done
    cp "$temp_dir/wanxiang-lts-zh-hans.gram" "$TARGET_DIR"/wanxiang-lts-zh-hans.gram
    rm -rf "$temp_dir"
    echo "$latest_version" >"$TARGET_DIR/wanxiang-version.txt"
    echo "$SELECTED_EDITION" >"$TARGET_DIR/wanxiang-edition.txt"
}

main() {
    while true; do
        ask_target_directory
        if [ "$TARGET_DIR" = "error" ]; then
            echo_yellow "无效输入，请重试。"
        else
            break
        fi
    done
    get_local_wanxiang_version
    while true; do
        ask_target_edition
        if [ "$SELECTED_EDITION" = "error" ]; then
            echo_yellow "无效输入，请重试。"
        else
            break
        fi
    done
    if ! test_github_api; then
        echo_red "无法连接到 GitHub API，请检查网络连接。"
        exit 1
    fi
    get_latest_wanxiang_version
    compare_versions
    test_network
    define_download_urls
    define_target_urls
    install_wanxiang
}

main
