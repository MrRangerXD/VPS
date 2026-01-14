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
MEMORY=128000   # RAM in MB (Approx 125GB)
CPUS=32
SSH_PORT=24
DISK_SIZE=300G

# IDENTITY: AMD Ryzen 9 7900 Emulation
CPU_EMULATION="host,vendor=AuthenticAMD,+topoext"
CPU_EMULATION+=",model-id=AMD Ryzen 9 7900 12-Core Processor @ 5.800GHz"

mkdir -p "$VM_DIR"
cd "$VM_DIR"

# =============================
# VM Image Setup
# =============================
if [ ! -f "$IMG_FILE" ]; then
    echo "[INFO] VM image not found, downloading and creating New VM Image..."
    
    # Download official Jammy (22.04) image
    wget -q https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -O "$IMG_FILE"
    
    # Resize the physical virtual disk file
    qemu-img resize "$IMG_FILE" "$DISK_SIZE"

    # Create the cloud-init configuration
    cat > user-data <<EOF
#cloud-config
hostname: FireNode
manage_etc_hosts: true
disable_root: false
ssh_pwauth: true
chpasswd:
  list: |
    root:root
  expire: false

# Automated disk expansion
growpart:
  mode: auto
  devices: ["/"]
resize_rootfs: true

runcmd:
  - [ sh, -c, "growpart /dev/vda \$(lsblk -no PKNAME,MOUNTPOINT | grep ' /$' | cut -d' ' -f1 | sed 's/.*[^0-9]//') || true" ]
  - [ sh, -c, "resize2fs /dev/vda\$(lsblk -no PARTITION,MOUNTPOINT | grep ' /$' | awk '{print \$1}') || true" ]
  - sed -ri "s/^#?PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config
  - systemctl restart ssh
EOF

    cat > meta-data <<EOF
instance-id: iid-local01
local-hostname: FireNode
EOF

    # Generate the config ISO (Requires cloud-image-utils)
    cloud-localds "$SEED_FILE" user-data meta-data
    echo "[INFO] VM setup complete!"
else
    echo "[INFO] VM image found, skipping setup..."
fi

# =============================
# Start VM
# =============================
echo "[INFO] Starting AMD Ryzen 9 7900 VPS..."
echo "[INFO] Access via: ssh root@localhost -p $SSH_PORT (Password: root)"



exec qemu-system-x86_64 \
    -enable-kvm \
    -m "$MEMORY" \
    -smp "$CPUS",sockets=1,cores=16,threads=2 \
    -cpu "$CPU_EMULATION" \
    -drive file="$IMG_FILE",format=qcow2,if=virtio \
    -drive file="$SEED_FILE",format=raw,if=virtio \
    -boot order=c \
    -device virtio-net-pci,netdev=n0 \
    -netdev user,id=n0,hostfwd=tcp::"$SSH_PORT"-:22 \
    -nographic -serial mon:stdio
