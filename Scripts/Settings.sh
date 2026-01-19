#!/bin/bash

# -----------------------------
# 默认网络 / 主机名
# -----------------------------
CFG_FILE="./package/base-files/files/bin/config_generate"
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

# -----------------------------
# WiFi 默认配置
# -----------------------------
WIFI_SH=$(find ./target/linux/*/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh" 2>/dev/null)
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"

if [ -f "$WIFI_SH" ]; then
    sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" $WIFI_SH
    sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WORD'/g" $WIFI_SH
elif [ -f "$WIFI_UC" ]; then
    sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
    sed -i "s/key='.*'/key='$WRT_WORD'/g" $WIFI_UC
    sed -i "s/country='.*'/country='CN'/g" $WIFI_UC
    sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" $WIFI_UC
fi

# -----------------------------
# LuCI 基础包
# -----------------------------
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config

# 手动添加插件
if [ -n "$WRT_PACKAGE" ]; then
    echo -e "$WRT_PACKAGE" >> ./.config
fi

# -----------------------------
# 系统调优：min_free_kbytes
# -----------------------------
MIN_FREE_VAL=8192
CONF_FILE="./package/base-files/files/etc/sysctl.conf"
CURRENT_VAL=$(sed -n 's/^vm\.min_free_kbytes=\([0-9]\+\).*/\1/p' "$CONF_FILE")

if [ -z "$CURRENT_VAL" ]; then
    echo "" >> "$CONF_FILE"
    echo "vm.min_free_kbytes=$MIN_FREE_VAL" >> "$CONF_FILE"
    echo "Memory patch added: $MIN_FREE_VAL."
elif [ "$CURRENT_VAL" -lt "$MIN_FREE_VAL" ]; then
    sed -i "s/^vm\.min_free_kbytes=.*/vm.min_free_kbytes=$MIN_FREE_VAL/" "$CONF_FILE"
    echo "Memory patch upgraded $CURRENT_VAL -> $MIN_FREE_VAL."
else
    echo "Memory patch: current value ($CURRENT_VAL) sufficient."
fi
