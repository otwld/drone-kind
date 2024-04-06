#!/usr/bin/env bash

# Copyright The Helm Authors & Outworld
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o pipefail

DEFAULT_KIND_VERSION=v0.21.0
DEFAULT_CLUSTER_NAME=default-kind
DEFAULT_KUBECTL_VERSION=v1.28.6
DEFAULT_WAIT=60s
DEFAULT_HOSTNAME=kubernetes


main() {
    local version="${PLUGIN_VERSION:-$DEFAULT_KIND_VERSION}"
    local config="$PLUGIN_CONFIG"
    local node_image="$PLUGIN_NODE_IMAGE"
    local install_dir="${PLUGIN_INSTALL_DIR:-/usr/local/bin}"
    local cluster_name="${PLUGIN_CLUSTER_NAME:-$DEFAULT_CLUSTER_NAME}"
    local wait="${PLUGIN_WAIT:-$DEFAULT_WAIT}"
    local verbosity=$PLUGIN_VERBOSE
    local kubectl_version="${PLUGIN_KUBECTL_VERSION:-$DEFAULT_KUBECTL_VERSION}"
    local install_only=$PLUGIN_INSTALL_ONLY
    local clean_only=$PLUGIN_CLEAN_ONLY
    local hostname="${PLUGIN_HOSTNAME:-$DEFAULT_HOSTNAME}"


    local arch
    case $(uname -m) in
        i386)               arch="386" ;;
        i686)               arch="386" ;;
        x86_64)             arch="amd64" ;;
        arm|aarch64|arm64)  arch="arm64" ;;
    esac

    if [[ ! -x "${install_dir}/kind" ]]; then
        install_kind
    fi

    if [[ ! -x "${install_dir}/kubectl" ]]; then
        install_kubectl
    fi

    echo 'Adding kubectl and kind directory to PATH...'
    export PATH="install_dir:$PATH"

    "${install_dir}/kind" version
    "${install_dir}/kubectl" version --client=true

    if [[ -z "${install_only}" ]] && [[ -z "${clean_only}" ]]; then
      create_kind_cluster
    fi

    if [[ -n "${clean_only}" ]]; then
      delete_cluster
    fi
}

install_kind() {
    echo 'Installing kind...'

    curl -sSLo "${install_dir}/kind" "https://github.com/kubernetes-sigs/kind/releases/download/${version}/kind-linux-${arch}"
    chmod +x "${install_dir}/kind"
}

install_kubectl() {
    echo 'Installing kubectl...'

    curl -sSLo "${install_dir}/kubectl" "https://storage.googleapis.com/kubernetes-release/release/${kubectl_version}/bin/linux/${arch}/kubectl"
    chmod +x "${install_dir}/kubectl"
}

create_kind_cluster() {
    echo 'Creating kind cluster...'
    local args=(create cluster "--name=${cluster_name}" "--wait=${wait}")

    if [[ -n "${node_image}" ]]; then
        args+=("--image=${node_image}")
    fi

    if [[ -n "${config}" ]]; then
        args+=("--config=${config}")
    fi

    if [[ -n "${verbosity}" ]]; then
        args+=("--verbosity=${verbosity}")
    fi

    "${install_dir}/kind" "${args[@]}"

    echo "Set hostname to: ${hostname}"
    sed -i -e "s/127.0.0.1/${hostname}/g" "${HOME}/.kube/config"
    sed -i -e "s/localhost/${hostname}/g" "${HOME}/.kube/config"
    sed -i -e "s/0.0.0.0/${hostname}/g" "${HOME}/.kube/config"
}

delete_cluster() {
    echo 'Deleting kind cluster...'
    local args=(delete cluster "--name=${cluster_name}")


    "${install_dir}/kind" "${args[@]}"
}

main