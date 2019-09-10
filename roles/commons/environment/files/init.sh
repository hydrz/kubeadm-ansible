#!/bin/bash

# 获取系统发行版
OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o "\w*" | head -n 1)

# 修改软件镜像
case "${OS_NAME}" in
  "CentOS")
    sudo curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    sudo curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
    sudo yum -y install wget net-tools screen lsof tcpdump nc mtr openssl-devel vim bash-completion lrzsz nmap telnet tree ntpdate
    ;;
  "Ubuntu")
    sudo sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
    sudo apt -y install wget net-tools screen lsof tcpdump netcat mtr libssl-dev vim bash-completion lrzsz nmap telnet tree ntpdate
    ;;
  *)
    echo "${OS_NAME} is not support ..."
    exit 1
    ;;
esac

# 修改时区
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 关闭 selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
setenforce 0

# 禁用 firewall
systemctl stop firewalld.service
systemctl disable firewalld.service

# 修改文件句柄数
cat >> /etc/security/limits.conf <<EOF
root        soft   nofile       65535 
root        hard   nofile       65535 
*           soft   nofile       65535 
*           hard   nofile       65535 
EOF

# 优化内核参数
cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_fin_timeout = 1 
net.ipv4.tcp_keepalive_time = 600 
net.ipv4.tcp_mem = 94500000 915000000 927000000 
net.ipv4.tcp_timestamps = 0 
net.ipv4.tcp_synack_retries = 1 
net.ipv4.tcp_syn_retries = 1 
net.core.rmem_max = 16777216 
net.core.wmem_max = 16777216 
net.core.netdev_max_backlog = 262144 
net.core.somaxconn = 20480 
net.ipv4.tcp_max_orphans = 3276800 
net.ipv4.tcp_max_syn_backlog = 262144 
net.core.wmem_default = 8388608 
net.core.rmem_default = 8388608
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
vm.swappiness = 0
net.ipv4.icmp_echo_ignore_all = 1
EOF

/sbin/sysctl -p

cat << EOF 
+-------------------------------------------------+ 
|               optimizer is done                 | 
|   it's recommond to restart this server !       | 
+-------------------------------------------------+ 
EOF