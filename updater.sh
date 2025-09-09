#!/bin/sh

set -e

GITHUB_TAGS_URL="https://github.com/amzxyz/rime_wanxiang/tags"
GITHUB_RELEASES_URL="https://github.com/amzxyz/rime_wanxiang/releases"

get_latest_wanxiang_version() {
    latest_version="$(curl -s $GITHUB_TAGS_URL | grep -E "tags/v[0-9]+" | awk -F 'tags/' '{print $2}' | grep '.zip' | awk -F '.zip' '{print $1}' | head -n 1)"
}

get_local_wanxiang_version() {
    local_version="$(cat "$TARGET_DIR/wanxiang-version.txt")" || local_version="v0.0.0"
}

compare_versions() {
    if [ "$latest_version" = "$local_version" ]; then
        echo "You are already using the latest version: $latest_version"
        exit 0
    else
        echo "A new version is available: $latest_version (current: $local_version)"
    fi
}

define_download_urls() {
    WANXIANG_BASE="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-base.zip"
    WANXIANG_FLYPY="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-flypy-fuzhu.zip"
    WANXIANG_HANXIN="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-hanxin-fuzhu.zip"
    WANXIANG_MOQI="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-moqi-fuzhu.zip"
    WANXIANG_TIGER="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-tiger-fuzhu.zip"
    WANXIANG_WUBI="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-wubi-fuzhu.zip"
    WANXIANG_ZRM="$GITHUB_RELEASES_URL/download/$latest_version/rime-wanxiang-zrm-fuzhu.zip"
    LANGUAGE_MODULE="https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram"
}

ask_target_directory() {
    echo "Please choose an input method with rime, so we can download"
    echo "files to correct directory:"
    echo "1. ibus-rime"
    echo "2. fcitx5-rime"
    echo "3. Weasel | 小狼毫"
    echo "4. Squirrel | 鼠鬚管 | 鼠须管"
    echo "5. Trime on Android | 安卓同文"
    echo "6. Custom Dictionary"
    echo "Please enter the input method number: "
    read -r INPUT_METHOD
    case $INPUT_METHOD in
    1) TARGET_DIR="$HOME/.config/ibus/rime" ;;
    2) TARGET_DIR="$HOME/.local/share/fcitx5/rime" ;;
    3) TARGET_DIR="$HOME/AppData/Roaming/Rime" ;;
    4) TARGET_DIR="$HOME/Library/Rime" ;;
    5) TARGET_DIR="/sdcard/rime" ;;
    6) 
        echo "Please enter the custom dictionary directory: "
        read -r TARGET_DIR
        ;;
    *) TARGET_DIR="error" ;;
    esac
}

ask_target_edition() {
    echo "Please choose an input edition, such as Pinyin(全拼)、Wubi(五笔)、"
    echo "flypy(小鹤双拼) or others, and whether to "
    echo "use auxiliary solutions:"
    echo "1. Stand IME (Support Shuangpin) | 标准版输入方案（支持双拼）"
    echo "2. ZRM auxiliary Enhanced version | 增强版自然码辅助版本"
    echo "3. Tiger auxiliary Enhanced version | 增强版虎码首末辅助版本"
    echo "4. Moqi auxiliary Enhanced version | 增强版墨奇辅助版本"
    echo "5. Xiaohe(flypy) auxiliary Enhanced version | 增强版小鹤辅助版本"
    echo "6. Wubi | 五笔"
    echo "7. Hanxin auxiliary Enhanced version | 增强版汉芯辅助版本"
    echo "Please enter the edition number: "
    read -r EDITION
    case $EDITION in
    1) SELECTED_EDITION="stand" ;;
    2) SELECTED_EDITION="zrm" ;;
    3) SELECTED_EDITION="tiger" ;;
    4) SELECTED_EDITION="moqi" ;;
    5) SELECTED_EDITION="xiaohe" ;;
    6) SELECTED_EDITION="wubi" ;;
    7) SELECTED_EDITION="hanxin" ;;
    *) SELECTED_EDITION="error" ;;
    esac
}

ask_user() {
    while true; do
        ask_target_directory
        if [ "$TARGET_DIR" = "error" ]; then
            echo "Invalid input. Please try again."
        else
            break
        fi
    done
    while true; do
        ask_target_edition
        if [ "$SELECTED_EDITION" = "error" ]; then
            echo "Invalid input. Please try again."
        else
            break
        fi
    done
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
    curl -# -L -o "$temp_dir/wanxiang.zip" "$TARGET_URL"
    curl -# -L -o "$temp_dir/wanxiang-lts-zh-hans.gram" "$LANGUAGE_MODULE"
    [ -d "$TARGET_DIR" ] || mkdir -p "$TARGET_DIR"
    [ -f "$TARGET_DIR/wanxiang-version.txt" ] && rm -f "$TARGET_DIR/wanxiang-version.txt"
    [ -f "$TARGET_DIR/wanxiang-lts-zh-hans.gram" ] && rm -f "$TARGET_DIR/wanxiang-lts-zh-hans.gram"
    unzip -o "$temp_dir/wanxiang.zip" -d "$TARGET_DIR"
    cp "$temp_dir/wanxiang-lts-zh-hans.gram" "$TARGET_DIR"/wanxiang-lts-zh-hans.gram
    rm -rf "$temp_dir"
    echo "$latest_version" > "$TARGET_DIR/wanxiang-version.txt"
}

main() {    
    ask_user
    get_latest_wanxiang_version
    get_local_wanxiang_version
    compare_versions
    define_download_urls
    define_target_urls
    install_wanxiang
}

main
