#!/bin/sh
# =============================================================================
# 首次开机默认 LAN 配置脚本（uci-defaults）
# 作用：固件第一次开机时，把 LAN 口设为 eth0，IP 设为 192.168.5.1/24。
# 说明：
#   * 本脚本被“编译进镜像 rootfs”（构建时拷入 package/base-files/files/etc/uci-defaults/）
#   * 由 OpenWrt 的 uci-defaults 机制「首次开机执行一次」，成功后自动删除
#   * 只写一次静态配置，无任何后台进程 / 循环，对运行性能零影响
# =============================================================================

# 安全守卫：确保 uci 可用
[ -x /sbin/uci ] || exit 0

# 1) 确保 lan 接口存在（首次开机 config_generate 通常已创建，这里兜底）
uci -q get network.lan >/dev/null 2>&1 || uci -q set network.lan='interface'

# 2) 绑定 eth0 为 LAN
#    同时写 ifname 与 device 以兼容 lede 新旧两种网络写法（后者优先，前者兜底）
uci -q set network.lan.ifname='eth0'
uci -q set network.lan.device='eth0'

# 3) 静态 IP：192.168.5.1 / 255.255.255.0
uci -q set network.lan.proto='static'
uci -q set network.lan.ipaddr='192.168.5.1'
uci -q set network.lan.netmask='255.255.255.0'

# 4) 若默认开着 DHCP 服务器，不影响 LAN 的静态 IP；这里确保 IPv4 为静态即可
uci -q commit network

exit 0
