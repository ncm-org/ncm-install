#!/bin/bash
#
# author: iamfan.net@gmail.com
# scripts are available for MacOS and Linux only

os_name=
arch_name=
download_name=
latest_version=

ncm_folder=${HOME}/.ncm

function echo_green() {
	echo -e "\033[32m${1}\033[0m"
}

function echo_red() {
	echo -e "\033[31m${1}\033[0m"
}

function check_dependent_util() {
	if [ ! "$(command -v "$1")" ]; then
		echo_red "${1} is not installed, please try again!"
		return 1
	fi
	return 0
}

function check_dependent_utils() {
	if ! check_dependent_util "curl"; then
		return 1
	fi
	if ! check_dependent_util "unzip"; then
		return 1
	fi
	if ! check_dependent_util "sha256sum"; then
		return 1
	fi
	return 0
}

function get_os_name() {
	os_name="$(uname | tr '[:upper:]' '[:lower:]')"
	if [ -z "${os_name}" ]; then
		return 1
	fi
	return 0
}

function get_arch_name() {
	case $(uname -m) in
	i386)
		arch_name="386"
		;;
	i686)
		arch_name="386"
		;;
	x86_64)
		arch_name="amd64"
		;;
	*)
		echo_red "unsupported architecture: $(uname -m)"
		return 1
		;;
	esac
	return 0
}

function get_latest_version() {
	if [ ! -d "${ncm_folder}" ]; then
		mkdir -p "${ncm_folder}"
	fi

	curl -LSs "https://api.github.com/repos/ncm-org/ncm/releases/latest" -o "${ncm_folder}/latest"
	if [ ! -f "${ncm_folder}/latest" ]; then
		echo_red "failed to get version information, please try again!"
		return 1
	fi

	latest_version=$(grep tag_name "${ncm_folder}/latest" | awk -F '[:,"v]' '{print $6}')
	if [ -z "${latest_version}" ]; then
		echo_red "failed to get version information, please try again!"
		return 1
	fi

	rm -f "${ncm_folder}/latest"
	return 0
}

function download_latest_version() {
	download_name="ncm_${latest_version}_${os_name}_${arch_name}.zip"
	echo_green "download $download_name"

	curl -L "https://github.com/ncm-org/ncm/releases/download/v${latest_version}/${download_name}" -o "${ncm_folder}/${download_name}"
	if [ ! -f "${ncm_folder}/${download_name}" ]; then
		echo_red "download failed, please try again!"
		return 1
	fi
	return 0
}

function check_zip_sum() {
	echo_green "checksum ..."
	local_zip_sum=$(sha256sum "${ncm_folder}/${download_name}" | awk '{print $1}')
	online_zip_sum=$(curl -LSs https://github.com/ncm-org/ncm/releases/download/v"${latest_version}"/checksums.txt | grep "${download_name}" | awk '{print $1}')
	if [ "${local_zip_sum}" != "${online_zip_sum}" ]; then
		echo_red "file hash does not match, please try again!"
		rm -f "${ncm_folder}/${download_name}"
		return 1
	fi
	return 0
}

function unzip_latest_version() {
	unzip -qq -o "${ncm_folder}/${download_name}" -d "${ncm_folder}"
	rm -f "${ncm_folder}/${download_name}"

	if [ ! -f "${ncm_folder}/ncm" ]; then
		echo_red "no NCM was found, please try again!"
		return 1
	fi
	return 0
}

function set_environment_variables() {
	export NCM_HOME="$ncm_folder"
	export PATH="$NCM_HOME":"$PATH"

	ncm_enc=$(printf "\n# added by ncm-install\nexport NCM_HOME=%s\nexport PATH=\$NCM_HOME:\$PATH\n" "${ncm_folder}")

	if [[ -f "${HOME}"/.zshrc ]] && [[ "$(grep -c NCM_HOME <"${HOME}"/.zshrc)" == 0 ]]; then
		echo "${ncm_enc}" >>"${HOME}"/.zshrc
	fi

	if [[ -f "${HOME}"/.bashrc ]] && [[ "$(grep -c NCM_HOME <"${HOME}"/.bashrc)" == 0 ]]; then
		echo "${ncm_enc}" >>"${HOME}"/.bashrc
	fi

	if [[ -f "${HOME}"/.bash_profile ]] && [[ "$(grep -c NCM_HOME <"${HOME}"/.bash_profile)" == 0 ]]; then
		echo "${ncm_enc}" >>"${HOME}"/.bash_profile
	fi

	if [[ -f "${HOME}"/.profile ]] && [[ "$(grep -c NCM_HOME <"${HOME}"/.profile)" == 0 ]]; then
		echo "${ncm_enc}" >>"${HOME}"/.profile
	fi

	chmod +x "${ncm_folder}"/ncm
}

function install() {
	if ! check_dependent_utils; then
		return 1
	fi
	if ! get_os_name; then
		return 1
	fi
	if ! get_arch_name; then
		return 1
	fi
	if ! get_latest_version; then
		return 1
	fi
	if ! download_latest_version; then
		return 1
	fi
	if ! check_zip_sum; then
		return 1
	fi
	if ! unzip_latest_version; then
		return 1
	fi
	set_environment_variables
	echo_green "successfully installed ncm@${latest_version}"
	return 0
}

install
