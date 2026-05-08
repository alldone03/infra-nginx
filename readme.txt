# PANDUAN SETUP NGINX & HTTPS (SSL) DENGAN DOCKER + CERTBOT

Repo ini digunakan sebagai Gateway/Reverse Proxy untuk aplikasi Insamo, lengkap dengan VPN Client dan SSL otomatis.
Berikut adalah cara setup dari awal hingga HTTPS aktif.

## 1. Arsitektur
- **Nginx**: Berjalan di port 80 (HTTP) dan 443 (HTTPS).
- **Certbot**: Sidecar container untuk mengambil dan memperbarui sertifikat SSL dari Let's Encrypt secara otomatis.
- **Docker Network**: Menggunakan network external bernama `web`. Pastikan network ini sudah ada.
  `docker network create web`

## 2. Langkah Persiapan
Pastikan Anda sudah memiliki:
1. VPS dengan Docker & Docker Compose terinstal.
2. Domain yang sudah diarahkan (A Record) ke IP VPS:
   - `insamo.id`
   - `www.insamo.id`

## 3. Cara Mendapatkan Sertifikat SSL (Pertama Kali)

Jika ini adalah setup baru dan folder `./certs` masih kosong, Nginx mungkin gagal start karena file `.pem` belum ada. Ikuti langkah "staging" ini:

### A. Jalankan Nginx Temporary
Komentari dulu bagian SSL di `nginx.conf` atau gunakan konfigurasi minimal yang hanya mendengarkan port 80 untuk challenge Certbot. Namun, repo ini sudah menyiapkan folder `.well-known/acme-challenge/`.

### B. Jalankan Perintah Certbot (Manual)
Jalankan perintah ini satu per satu untuk setiap domain agar folder sertifikatnya terpisah (sesuai `nginx.conf`):

```bash
# Borongan untuk semua domain sekaligus:
docker run --rm -it -v $(pwd)/certs:/etc/letsencrypt -v $(pwd)/certbot/www:/var/www/certbot certbot/certbot certonly --webroot -w /var/www/certbot -d insamo.id -d www.insamo.id --email aldanarsenal@gmail.com --agree-tos
```

*Catatan Penting:*
1. **WAJIB jalankan di VPS/Server**, jangan di laptop (kecuali sudah port-forwarding).
2. Pastikan Nginx sudah menyala (`docker compose up -d`).
3. (Pengguna Windows/Git Bash) Jika muncul error path `C:/laragon/...`, tambahkan `MSYS_NO_PATHCONV=1` di depan perintah:
   `MSYS_NO_PATHCONV=1 docker run ...`
4. Ganti email dengan email aktif Anda.

## 4. Cara Menjalankan Stack (Produksi)

Setelah sertifikat berhasil didapatkan di folder `./certs`, jalankan stack secara penuh:

```bash
# Menjalankan container di background
docker-compose -f docker-compose.prod.yml up -d
```

## 5. Struktur Konfigurasi
- `nginx.conf`: Berisi routing untuk domain-domain Insamo.
  - Port 80: Otomatis redirect ke HTTPS.
  - Port 443: Konfigurasi SSL dan Proxy Pass ke service internal.
- `docker-compose.prod.yml`: Definisi service Nginx dan Certbot.

## 6. Maintenance (Perpanjangan Otomatis)
Service `certbot` di `docker-compose.prod.yml` sudah dikonfigurasi untuk mengecek perpanjangan sertifikat setiap 12 jam secara otomatis. Anda tidak perlu melakukan apa-apa selama container tetap berjalan.

## 7. Verifikasi
Cek apakah HTTPS sudah aktif dengan:
```bash
curl -I https://insamo.id
curl -I https://insamo.id/api
```
Semuanya harus mengembalikan HTTP/2 200 atau 301/429 sesuai logika di `nginx.conf`.

## 8. Setup VPN Client
Service `vpn-client` sudah ditambahkan ke `docker-compose.prod.yml`.
1. Isi kredensial VPN di file `.env`.
2. Jalankan stack: `docker compose up -d`.
3. **Penting**: Karena Nginx sekarang menempel ke network VPN, Nginx tidak bisa lagi memanggil service Docker lain (`frontend`/`backend`) lewat nama service. Pastikan service-service tersebut juga bisa diakses via `localhost` atau IP host.

### Cara Memastikan VPN Terhubung
Untuk mengecek apakah VPN sudah mendapatkan IP dan terowongan (*tunnel*) aktif, jalankan:
```bash
# Cek interface jaringan (cari 'ppp0' atau 'tun0')
docker exec vpn-client ip addr

# Cek log koneksi VPN
docker logs vpn-client

# Test ping lewat VPN
docker exec vpn-client ping -c 4 8.8.8.8
```

## 9. Panduan Lengkap HTTPS (SSL)
Ikuti langkah ini secara berurutan:

### Langkah 1: Persiapan DNS & File
- Pastikan domain `insamo.id` dan `www.insamo.id` mengarah ke IP VPS.
- Pastikan file `.env` sudah ada (untuk email Certbot).

### Langkah 2: Dapatkan Sertifikat (Port 80 Terbuka)
Jalankan perintah ini:
```bash
MSYS_NO_PATHCONV=1 docker run --rm -it -v $(pwd)/certs:/etc/letsencrypt -v $(pwd)/certbot/www:/var/www/certbot certbot/certbot certonly --webroot -w /var/www/certbot -d insamo.id -d www.insamo.id --email your_email@gmail.com --agree-tos
docker compose exec nginx-gateway nginx -s reload
```

### Langkah 3: Aktifkan HTTPS di Nginx
Setelah sertifikat muncul di folder `./certs/live/insamo.id/`:
1. Buka `nginx.conf`.
2. **Uncomment** (hapus tanda `#`) pada bagian `server { listen 443 ... }`.
3. Simpan file.

### Langkah 4: Restart Nginx
```bash
docker compose exec nginx-gateway nginx -s reload
```

---
*Dibuat oleh: Antigravity Assistant*