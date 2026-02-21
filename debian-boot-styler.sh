#!/bin/bash

# 1. Perbaikan PATH agar perintah sistem terbaca
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Pastikan dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
   echo "Silakan jalankan dengan sudo: sudo bash $0"
   exit 1
fi

echo "===================================================="
echo "   DEBIAN 13 - BOOT FIXER (FINAL VERSION)"
echo "===================================================="

# 2. Pastikan Plymouth Terinstal
echo "[1/4] Mengecek paket Plymouth..."
apt update && apt install -y plymouth plymouth-themes

# 3. Menampilkan Pilihan Animasi
echo ""
echo "Berikut adalah daftar tema animasi yang tersedia:"
echo "----------------------------------------------------"
themes=($(plymouth-set-default-theme --list))

for i in "${!themes[@]}"; do
    echo "$((i+1)). ${themes[$i]}"
done
echo "----------------------------------------------------"

# 4. Input Fleksibel (Bisa Angka atau Nama)
read -p "Masukkan NOMOR atau NAMA tema: " user_input

if [[ "$user_input" =~ ^[0-9]+$ ]] && [ "$user_input" -le "${#themes[@]}" ]; then
    SELECTED_THEME=${themes[$((user_input-1))]}
else
    # Jika user ketik nama, cek apakah ada di list
    if [[ " ${themes[*]} " =~ " ${user_input} " ]]; then
        SELECTED_THEME=$user_input
    else
        echo "Input tidak dikenal. Menggunakan tema default 'spinner'."
        SELECTED_THEME="spinner"
    fi
fi

echo ">> Menggunakan tema: $SELECTED_THEME"

# 5. Terapkan Tema & Update Initramfs
echo ""
echo "[2/4] Menerapkan tema $SELECTED_THEME..."
plymouth-set-default-theme -R $SELECTED_THEME

# 6. Konfigurasi GRUB (Quiet Boot & Power Off)
echo "[3/4] Mengonfigurasi file GRUB..."
GRUB_FILE="/etc/default/grub"
[ ! -f "${GRUB_FILE}.bak" ] && cp $GRUB_FILE "${GRUB_FILE}.bak"

sed -i 's/GRUB_TIMEOUT=[0-9]*/GRUB_TIMEOUT=0/' $GRUB_FILE
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash acpi=force vt.global_cursor_default=0"/' $GRUB_FILE

if ! grep -q "GRUB_TIMEOUT_STYLE=hidden" $GRUB_FILE; then
    echo "GRUB_TIMEOUT_STYLE=hidden" >> $GRUB_FILE
fi

# 7. Update GRUB dengan full path agar tidak error
echo "[4/4] Memperbarui GRUB..."
/usr/sbin/update-grub

echo "===================================================="
echo "              BERHASIL DIKONFIGURASI!"
echo "===================================================="
echo "Silakan ketik: reboot"
