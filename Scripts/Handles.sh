#!/bin/bash

PKG_PATH="$GITHUB_WORKSPACE/wrt/package/"

# -----------------------------
# TailScale 配置修复（官方可选）
# -----------------------------
TS_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/tailscale/Makefile")
if [ -f "$TS_FILE" ]; then
    echo "Fixing TailScale Makefile..."
    sed -i '/\/files/d' $TS_FILE
    echo "TailScale has been fixed!"
fi

# -----------------------------
# DiskMan 修复（可选）
# -----------------------------
DM_FILE="./luci-app-diskman/applications/luci-app-diskman/Makefile"
if [ -f "$DM_FILE" ]; then
    echo "Fixing DiskMan Makefile..."
    # 删除依赖 ntfs-3g-utils，官方 OpenWrt 默认支持 fs-ntfs3
    sed -i '/ntfs-3g-utils /d' $DM_FILE
    echo "DiskMan has been fixed!"
fi

# -----------------------------
# luci-app-netspeedtest 修复
# -----------------------------
if [ -d "$PKG_PATH/luci-app-netspeedtest" ]; then
    echo "Fixing luci-app-netspeedtest..."
    cd "$PKG_PATH/luci-app-netspeedtest"

    # 防止编译脚本退出报错
    [ -f ./netspeedtest/files/99_netspeedtest.defaults ] && sed -i '$a\exit 0' ./netspeedtest/files/99_netspeedtest.defaults
    # 修复 ca-certificates 包名差异
    [ -f ./speedtest-cli/Makefile ] && sed -i 's/ca-certificates/ca-bundle/g' ./speedtest-cli/Makefile

    cd "$PKG_PATH"
    echo "luci-app-netspeedtest has been fixed!"
fi

# -----------------------------
# 脚本结束
# -----------------------------
echo "All package fixes completed!"
