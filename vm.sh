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
echo "[INFO] Starting VM with 32 vCores as AMD Ryzen 9 7900..."

GPU_PCI_ADDR="01:00.0" 
CPU_EMULATION="host,vendor=AuthenticAMD,+topoext,model-id=AMD Ryzen 9 7900 12-Core Processor @ 5.80GHz,kvm=off,hv_vendor_id=null,-hypervisor"

exec qemu-system-x86_64 \
    -enable-kvm \
    -m "$MEMORY" \
    -machine q35,accel=kvm,kernel_irqchip=on \
    -smp "$CPUS",cores=16,threads=2,sockets=1 \
    -cpu "$CPU_EMULATION" \
    -device vfio-pci,host="$GPU_PCI_ADDR",multifunction=on \
    -drive file="$IMG_FILE",format=qcow2,if=virtio \
    -drive file="$SEED_FILE",format=raw,if=virtio \
    -boot order=c \
    -device virtio-net-pci,netdev=n0 \
    -netdev user,id=n0,hostfwd=tcp::"$SSH_PORT"-:22 \
    -nographic -serial mon:stdio


    # DONT CHANGE ANYTHING HERE
