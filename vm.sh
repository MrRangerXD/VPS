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
MEMORY=128000   # RAM in MB
CPUS=32
SSH_PORT=24
DISK_SIZE=300G

# --- IMPORTANT: GPU ADDRESS ---
# Run 'lspci -nn | grep NVIDIA' on your host. 
# Replace 01:00.0 with your actual ID (e.g., 02:00.0 or 00:04.0)
GPU_PCI_ADDR="01:00.0" 

# --- CPU IDENTITY & FREQUENCY ---
# Hides hypervisor from GPU drivers to avoid Error 43 while keeping KVM speed
CPU_EMULATION="host,vendor=AuthenticAMD,+topoext"
CPU_EMULATION+=",model-id=AMD Ryzen 9 7900 12-Core Processor @ 5.80GHz"
CPU_EMULATION+=",kvm=off,hv_vendor_id=null,-hypervisor"

mkdir -p "$VM_DIR"
cd "$VM_DIR"

# =============================
# VM Image Setup
# =============================
if [ ! -f "$IMG_FILE" ]; then
    echo "[INFO] VM image not found, creating new VM..."
    wget -q https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -O "$IMG_FILE"
    qemu-img resize "$IMG_FILE" "$DISK_SIZE"

    # Cloud-init config
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
echo "[INFO] Starting VM with 32 vCores as AMD Ryzen 9 7900 @ 5.80GHz..."

# Using 'q35' machine type for proper PCI-Express/GPU support
exec qemu-system-x86_64 \
    -enable-kvm \
    -m "$MEMORY" \
    -machine q35,accel=kvm,kernel_irqchip=on \
    -smp "$CPUS",sockets=1,cores=16,threads=2 \
    -cpu "$CPU_EMULATION" \
    -device vfio-pci,host="$GPU_PCI_ADDR",multifunction=on \
    -drive file="$IMG_FILE",format=qcow2,if=virtio \
    -drive file="$SEED_FILE",format=raw,if=virtio \
    -boot order=c \
    -device virtio-net-pci,netdev=n0 \
    -netdev user,id=n0,hostfwd=tcp::"$SSH_PORT"-:22 \
    -nographic -serial mon:stdio

# DONT CHANGE ANYTHING HERE
