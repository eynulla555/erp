#!/bin/bash
set -e

echo "=== Lumiere ERP: Port 80 Quraşdırılması ==="

# 1. Qovluq yaradılır və icazələr verilir
sudo mkdir -p /var/www/lumiere-erp
sudo chown -R $USER:$USER /var/www/lumiere-erp

# Layihə fayllarını bu qovluğa yükləyin və ora keçin
cd /var/www/lumiere-erp

if [ ! -f "package.json" ]; then
    echo "XƏTA: package.json tapılmadı!"
    echo "Zəhmət olmasa bu skripti işə salmazdan əvvəl layihə fayllarını /var/www/lumiere-erp qovluğuna kopyalayın."
    exit 1
fi

# 2. NPM paketləri yazılır və statik fayllar (dist) yaradılır
npm install
npm run build

# 3. Nginx quraşdırılır (əgər yoxdursa)
if ! command -v nginx &> /dev/null; then
    sudo apt update
    sudo apt install nginx -y
fi

# 4. Nginx konfiqurasiyası yaradılır (Port 80)
sudo tee /etc/nginx/sites-available/lumiere-erp > /dev/null <<EOF
server {
    listen 80;
    server_name 103.252.118.49; # Sizin serverin IP ünvanı

    root /var/www/lumiere-erp/dist;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# 5. Konfiqurasiyanı aktivləşdirib Nginx-i yenidən başladırıq
sudo ln -sf /etc/nginx/sites-available/lumiere-erp /etc/nginx/sites-enabled/
# Köhnə default nginx səhifəsini silirik ki, bizim sayt görünsün
sudo rm -f /etc/nginx/sites-enabled/default || true

sudo nginx -t
sudo systemctl restart nginx

echo "=== Uğurla Tamamlandı! ==="
echo "Sayt artıq canlıdır: http://103.252.118.49"