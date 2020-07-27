#!/bin/bash
#
# author: iamfan.net@gmail.com
# scripts are available for MacOS and Linux only

os_name=
arch_name=
download_name=
latest_version=

ncm_folder=$HOME/.ncm

function echo_green() {
	echo -e "\033[32m${1}\033[0m"
}

function echo_red() {
	echo -e "\033[31m${1}\033[0m"
}

function get_os_name() {
	os_name="$(uname | tr '[:upper:]' '[:lower:]')"
}

function get_arch_name() {
	case $(uname -m) in
	i386) arch_name="386" ;;
	i686) arch_name="386" ;;
	x86_64) arch_name="amd64" ;;
	esac
}

function get_latest_version() {
	curl -LkSs "https://api.github.com/repos/ncm-org/ncm/releases/latest" -o "$ncm_folder/latest"
	if [ ! -f "$ncm_folder/latest" ]; then
		echo_red "failed to get version information, please try again!"
		return 1
	fi

	latest_version=$(grep tag_name "$ncm_folder/latest" | awk -F '[:,"v]' '{print $6}')
	if [ -z "$latest_version" ]; then
		echo_red "failed to get version information, please try again!"
		return 1
	fi

	rm -f "$ncm_folder/latest"
	return 0
}

function download_latest_version() {
	download_name="ncm_${latest_version}_${os_name}_${arch_name}.zip"
	echo_green "download $download_name"

	curl -Lk "https://github.com/ncm-org/ncm/releases/download/v$latest_version/$download_name" -o "$ncm_folder/$download_name"
	if [ ! -f "$ncm_folder/$download_name" ]; then
		echo_red "download failed, please try again!"
		return 1
	fi
	return 0
}

function unzip_latest_version() {
	unzip -qq -o "$ncm_folder/$download_name" -d "$ncm_folder"
	rm -f "$ncm_folder/$download_name"

	if [ ! -f "$ncm_folder/ncm" ]; then
		echo_red "no NCM was found, please try again!"
		return 1
	fi
	return 0
}

function set_envionment_variables() {
	export NCM_HOME="$ncm_folder"
	export PATH="$NCM_HOME":"$PATH"

	ncm_enc=$(printf "\n# added by ncm-install\nexport NCM_HOME=%s\nexport PATH=\$NCM_HOME:\$PATH\n" "$ncm_folder")

	if [[ -f "$HOME"/.zshrc ]] && [[ "$(grep -c NCM_HOME <"$HOME"/.zshrc)" == 0 ]]; then
		echo "$ncm_enc" >>"$HOME"/.zshrc
	fi

	if [[ -f "$HOME"/.bashrc ]] && [[ "$(grep -c NCM_HOME <"$HOME"/.bashrc)" == 0 ]]; then
		echo "$ncm_enc" >>"$HOME"/.bashrc
	fi

	if [[ -f "$HOME"/.bash_profile ]] && [[ "$(grep -c NCM_HOME <"$HOME"/.bash_profile)" == 0 ]]; then
		echo "$ncm_enc" >>"$HOME"/.bash_profile
	fi

	if [[ -f "$HOME"/.profile ]] && [[ "$(grep -c NCM_HOME <"$HOME"/.profile)" == 0 ]]; then
		echo "$ncm_enc" >>"$HOME"/.profile
	fi

	chmod +x "$ncm_folder"/ncm
}

function install() {
	mkdir -p "${ncm_folder}"

	get_os_name
	get_arch_name

	get_latest_version
	if [ $? -ne 0 ]; then
		return 1
	fi

	download_latest_version
	if [ $? -ne 0 ]; then
		return 1
	fi

	unzip_latest_version
	if [ $? -ne 0 ]; then
		return 1
	fi

	set_envionment_variables
	echo_green "successfully installed ncm@$latest_version"

	return 0
}

install
