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
    latest_version="$(curl -s $GITHUB_TAGS_URL| grep 'name' | awk -F '["]' 'NR == 1 {print $4}')"
}

get_local_wanxiang_version() {
    [ -f "$TARGET_DIR/wanxiang-version.txt" ] && local_version="$(cat "$TARGET_DIR/wanxiang-version.txt")" || local_version="v0.0.0"
}

define_download_urls() {
    WANXIANG_BASE="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-base.zip"
    WANXIANG_FLYPY="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-flypy-fuzhu.zip"
    WANXIANG_HANXIN="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-hanxin-fuzhu.zip"
    WANXIANG_MOQI="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-moqi-fuzhu.zip"
    WANXIANG_TIGER="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-tiger-fuzhu.zip"
    WANXIANG_WUBI="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-wubi-fuzhu.zip"
    WANXIANG_ZRM="$CNB_RELEASES_URL/download/$latest_version/rime-wanxiang-zrm-fuzhu.zip"
    LANGUAGE_MODULE="https://cnb.cool/amzxyz/rime-wanxiang/-/releases/download/model/wanxiang-lts-zh-hans.gram"
}

ask_target_directory() {
    echo_green "选择输入框架，或者输入自定义安装位置："
    echo "1. ibus-rime"
    echo "2. fcitx5-rime"
    echo "3. Weasel | 小狼毫"
    echo "4. Squirrel | 鼠鬚管 | 鼠须管"
    echo "5. Trime | 同文"
    echo "6. 手动输入自定义目录"
    echo "输入你的选择： "
    read -r INPUT_METHOD
    case $INPUT_METHOD in
    1) TARGET_DIR="$HOME/.config/ibus/rime" ;;
    2) TARGET_DIR="$HOME/.local/share/fcitx5/rime" ;;
    3) TARGET_DIR="$HOME/AppData/Roaming/Rime" ;;
    4) TARGET_DIR="$HOME/Library/Rime" ;;
    5) TARGET_DIR="/sdcard/rime" ;;
    6) 
        echo_green "输入你的自定义目录: "
        read -r TARGET_DIR
        ;;
    *) TARGET_DIR="error" ;;
    esac
}

ask_target_edition() {
    notice_stand="标准版输入方案"
    notice_zrm="增强版自然码辅助版本"
    notice_tiger="增强版虎码首末辅助版本"
    notice_moqi="增强版墨奇辅助版本"
    notice_xiaohe="增强版小鹤辅助版本"
    notice_wubi="五笔"
    notice_hanxin="增强版汉芯辅助版本"
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
    echo "当前配置方案: $notice_old：$local_version"
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
        echo_yellow "您选择的输入方案与当前方案 ($notice_old) 不同，当前方案将被替换为新方案 ($notice)。继续吗？(y/n)"
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
    curl -# -L -o "$temp_dir/wanxiang.zip" "$TARGET_URL"
    echo_green "下载 $LANGUAGE_MODULE"
    curl -# -L -o "$temp_dir/wanxiang-lts-zh-hans.gram" "$LANGUAGE_MODULE"
    [ -d "$TARGET_DIR" ] || mkdir -p "$TARGET_DIR"
    [ -f "$TARGET_DIR/wanxiang-version.txt" ] && rm -f "$TARGET_DIR/wanxiang-version.txt"
    [ -f "$TARGET_DIR/wanxiang-lts-zh-hans.gram" ] && rm -f "$TARGET_DIR/wanxiang-lts-zh-hans.gram"
    if [ -f "$TARGET_DIR/filelist.txt" ]; then
        for file in $(cat "$TARGET_DIR/filelist.txt"); do
           rm -rf "${TARGET_DIR:?}/$file"
        done
        rm -f "$TARGET_DIR/filelist.txt"
    fi
    unzip -l "$temp_dir/wanxiang.zip" -x $WHITE_LIST_FILES | awk 'NR>3 && $0 !~ /----/ {print $4}' > "$TARGET_DIR"/filelist.txt
    echo_green "Installing to $TARGET_DIR"
    unzip -o "$temp_dir/wanxiang.zip" -d "$TARGET_DIR" -x $WHITE_LIST_FILES
    for file in $WHITE_LIST_FILES; do
        [ ! -f "$TARGET_DIR/$file" ] && unzip "$temp_dir/wanxiang.zip" "$file" -d "$TARGET_DIR"
    done
    cp "$temp_dir/wanxiang-lts-zh-hans.gram" "$TARGET_DIR"/wanxiang-lts-zh-hans.gram
    rm -rf "$temp_dir"
    echo "$latest_version" > "$TARGET_DIR/wanxiang-version.txt"
    echo "$SELECTED_EDITION" > "$TARGET_DIR/wanxiang-edition.txt"
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
    get_latest_wanxiang_version
    compare_versions
    define_download_urls
    define_target_urls
    install_wanxiang
}

main
