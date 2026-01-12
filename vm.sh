#!/bin/bash
set -euo pipefail

# =============================
# Ubuntu 22.04 VM (Auto Setup)
# =============================

clear
cat << "EOF"
================================================

███████╗███████╗███╗   ██╗███████╗███████╗██╗
╚══███╔╝██╔════╝████╗  ██║██╔════╝██╔════╝██║
  ███╔╝ █████╗  ██╔██╗ ██║███████╗█████╗  ██║
 ███╔╝  ██╔══╝  ██║╚██╗██║╚════██║██╔══╝  ██║
███████╗███████╗██║ ╚████║███████║███████╗██║
╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝╚══════╝╚═╝
                                     
             POWERED BY ZenseiTech         
================================================

EOF

# =============================
# Configurable Variables
# =============================
VM_DIR="$HOME/Zensei-s-VPS"
IMG_FILE="$VM_DIR/ubuntu-cloud.img"
SEED_FILE="$VM_DIR/seed.iso"
MEMORY=128000   # PERMB RAM
CPUS=32
SSH_PORT=24
DISK_SIZE=300G
# CPU Model - Changed to AMD Ryzen 9
CPU_MODEL="host"  # Use "host" for best performance, or emulate AMD below

mkdir -p "$VM_DIR"
cd "$VM_DIR"

# =============================
# VM Image Setup
# =============================
if [ ! -f "$IMG_FILE" ]; then
    echo "[INFO] VM image not found, creating new VM..."
    wget -q https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -O "$IMG_FILE"
    qemu-img resize "$IMG_FILE" "$DISK_SIZE"

    # Cloud-init config with hostname = hpccloud
    cat > user-data <<EOF
#cloud-config
hostname: root
manage_etc_hosts: true
disable_root: false
ssh_pwauth: true
chpasswd:
  list: |
    root:root
  expire: false
growpart:
  mode: auto
  devices: ["/"]
  ignore_growroot_disabled: false
resize_rootfs: true
runcmd:
 - growpart /dev/vda 1 || true
 - resize2fs /dev/vda1 || true
 - sed -ri "s/^#?PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config
 - systemctl restart ssh
EOF

    cat > meta-data <<EOF
instance-id: iid-local01
local-hostname: FireNode
EOF

    cloud-localds "$SEED_FILE" user-data meta-data
    echo "[INFO] VM setup complete!"
else
    echo "[INFO] VM image found, skipping setup..."
fi

# =============================
# Start VM
# =============================
echo "[INFO] Starting VM with CPU emulation..."

# CPU Options:
# 1. "host" - Use the host CPU (fastest, but will show Intel on Firebase)
# 2. "max" or "qemu64" - Generic x86_64 CPU
# 3. "EPYC" or "athlon" - AMD server/workstation CPUs
# 4. "kvm64" - Generic KVM CPU

# For AMD Ryzen 9 emulation, try one of these:
CPU_EMULATION="EPYC-Rome-v3"  # Generic x86_64 with most features
# CPU_EMULATION="qemu64"  # Basic x86_64
# CPU_EMULATION="EPYC"  # AMD EPYC server CPU
# CPU_EMULATION="athlon"  # AMD Athlon

# To see all available CPU models: qemu-system-x86_64 -cpu help

exec qemu-system-x86_64 \
    -enable-kvm \
    -m "$MEMORY" \
    -smp "$CPUS" \
    -cpu "$CPU_EMULATION" \
    -drive file="$IMG_FILE",format=qcow2,if=virtio \
    -drive file="$SEED_FILE",format=raw,if=virtio \
    -boot order=c \
    -device virtio-net-pci,netdev=n0 \
    -netdev user,id=n0,hostfwd=tcp::"$SSH_PORT"-:22 \
    -nographic -serial mon:stdio



    # DONT CHANGE ANYTHING HERE
