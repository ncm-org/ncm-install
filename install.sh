#!/bin/bash

# author: iamfan.net@gmail.com
# scripts are available for MacOS and Linux only

os=
arch=
version=
ncmhome=$HOME/.ncm

function echo_green() {
    echo -e "\033[32m${1}\033[0m"
}

function os_name() {
    os="$(uname | tr '[:upper:]' '[:lower:]')"
}

function arch_name() {
    case $(uname -m) in
    i386) arch="386" ;;
    i686) arch="386" ;;
    x86_64) arch="amd64" ;;
    esac
}

function latest_version() {
    curl -LkSs "https://api.github.com/repos/ncm-org/ncm/releases/latest" -o "$ncmhome/latest"
    version=$(grep tag_name "$ncmhome/latest" | awk -F '[:,"v]' '{print $6}')
    rm -f "$ncmhome/latest"
}

function install() {
    mkdir -p "${ncmhome}"

    os_name
    arch_name
    latest_version

    download_name="ncm_${version}_${os}_${arch}.zip"
    echo_green "download $download_name"

    curl -Lk "https://github.com/ncm-org/ncm/releases/download/v$version/$download_name" -o "$ncmhome/$download_name"
    unzip -qq -o "$ncmhome/$download_name" -d "$ncmhome"
    rm -f "$ncmhome/$download_name"

    export NCM_HOME="$ncmhome"
    export PATH="$NCM_HOME":"$PATH"

    ncmenv=$(printf "\n# added by ncm-install\nexport NCM_HOME=%s\nexport PATH=\$NCM_HOME:\$PATH\n" "$ncmhome")

    if [[ -f "$HOME"/.zshrc ]] && [[ "$(grep -c NCM_HOME <"$HOME"/.zshrc)" == 0 ]]; then
        echo "$ncmenv" >>"$HOME"/.zshrc
    elif [[ -f "$HOME"/.bashrc ]] && [[ "$(grep -c NCM_HOME <"$HOME"/.bashrc)" == 0 ]]; then
        echo "$ncmenv" >>"$HOME"/.bashrc
    elif [[ -f "$HOME"/.bash_profile ]] && [[ "$(grep -c NCM_HOME <"$HOME"/.bash_profile)" == 0 ]]; then
        echo "$ncmenv" >>"$HOME"/.bash_profile
    fi

    chmod +x "$ncmhome"/ncm
    echo_green "successfully installed ncm@$version"
}

install
