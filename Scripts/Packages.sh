#!/bin/bash
# 示例：只更新官方包或自定义插件
UPDATE_PACKAGE() {
    local PKG_NAME=$1
    local PKG_REPO=$2
    local PKG_BRANCH=$3
    local PKG_SPECIAL=$4

    echo "Processing $PKG_NAME ..."
    git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"
    if [ "$PKG_SPECIAL" == "pkg" ]; then
        find ./$PKG_NAME/* -maxdepth 3 -type d -exec cp -rf {} ./ \;
        rm -rf $PKG_NAME
    fi
}

# 示例：添加 aurora（可选）
# UPDATE_PACKAGE "aurora" "ones20250/luci-theme-aurora" "master"
# UPDATE_PACKAGE "aurora-config" "ones20250/luci-app-aurora-config" "master"
