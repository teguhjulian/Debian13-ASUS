#!/bin/bash

# =============================================================
# SCRIPT OPTIMASI ASUS VIVOBOOK
# Fitur: zRAM (zstd), udev Power Management, & Thermal Policy
# =============================================================

echo "Memulai proses optimasi... Mohon tunggu sebentar."

# 1. Update dan Instal Tools yang dibutuhkan
sudo apt update
sudo apt install zram-tools cpufrequtils -y

# 2. Konfigurasi zRAM (Kantong Ajaib 60%)
echo "Mengatur zRAM..."
sudo bash -c 'cat << EOF > /etc/default/zramswap
ALGO=zstd
PERCENT=60
PRIORITY=100
EOF'
sudo systemctl restart zramswap

# 3. Membuat Script Pengatur CPU & Kipas (udev script)
echo "Membuat script otomatis Power Management..."
sudo bash -c 'cat << EOF > /usr/local/bin/asus-power-save.sh
#!/bin/bash
# Cek status charger di AC0 (1 = dicolok, 0 = baterai)
AC_STATUS=\$(cat /sys/class/power_supply/AC0/online)

if [ "\$AC_STATUS" -eq 0 ]; then
    # MODE BATERAI: Kipas Silent & CPU Powersave
    echo 2 > /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy
    cpufreq-set -g powersave
else
    # MODE CHARGER: Kipas Balanced & CPU Schedutil
    echo 0 > /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy
    cpufreq-set -g schedutil
fi
EOF'

# 4. Memberi izin eksekusi pada script
sudo chmod +x /usr/local/bin/asus-power-save.sh

# 5. Membuat Aturan udev (Otomatis jalan saat cabut/colok)
echo "Membuat aturan udev..."
sudo bash -c 'echo "SUBSYSTEM==\"power_supply\", KERNEL==\"AC0\", ATTR{online}==\"*\", RUN+=\"/usr/local/bin/asus-power-save.sh\"" > /etc/udev/rules.d/99-asus-power.rules'

# 6. Reload udev agar aturan langsung aktif
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "-------------------------------------------------------"
echo "OPTIMASI SELESAI!"
echo "Sekarang laptop sudah mengatur RAM dan CPU secara otomatis."
echo "Silakan cabut dan colok charger untuk mencoba perubahannya."
echo "-------------------------------------------------------"
