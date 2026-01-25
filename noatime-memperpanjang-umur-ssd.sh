#!/bin/bash

# =============================================================
# SCRIPT OPTIMASI SSD (NOATIME)
# Fitur: Mengurangi aktivitas tulis ke SSD agar lebih awet
# =============================================================

echo "Memulai optimasi SSD dengan noatime..."

# 1. Backup file fstab asli untuk keamanan
sudo cp /etc/fstab /etc/fstab.bak

# 2. Mengubah relatime atau default menjadi noatime pada semua partisi ext4/xfs/btrfs
# Script ini akan mengecek baris yang mengandung 'ext4', 'xfs', atau 'btrfs' 
# dan memastikan ada opsi 'noatime' di dalamnya.
sudo sed -i '/ext4\|xfs\|btrfs/ s/defaults/defaults,noatime/g' /etc/fstab
sudo sed -i '/ext4\|xfs\|btrfs/ s/relatime/noatime/g' /etc/fstab

# 3. Melakukan remount agar perubahan langsung terasa tanpa restart
sudo mount -o remount /

echo "-------------------------------------------------------"
echo "OPTIMASI NOATIME SELESAI!"
echo "File /etc/fstab telah diperbarui (Backup tersedia di /etc/fstab.bak)."
echo "Mantap Bang."
echo "-------------------------------------------------------"
