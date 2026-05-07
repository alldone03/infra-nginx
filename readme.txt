# PANDUAN SETUP NGINX & HTTPS (SSL) DENGAN DOCKER + CERTBOT

Repo ini digunakan sebagai Gateway/Reverse Proxy untuk aplikasi Insamo.
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
   - `app.insamo.id`
   - `apiapp.insamo.id`
   - `cogniva.insamo.id`

## 3. Cara Mendapatkan Sertifikat SSL (Pertama Kali)

Jika ini adalah setup baru dan folder `./certs` masih kosong, Nginx mungkin gagal start karena file `.pem` belum ada. Ikuti langkah "staging" ini:

### A. Jalankan Nginx Temporary
Komentari dulu bagian SSL di `nginx.conf` atau gunakan konfigurasi minimal yang hanya mendengarkan port 80 untuk challenge Certbot. Namun, repo ini sudah menyiapkan folder `.well-known/acme-challenge/`.

### B. Jalankan Perintah Certbot (Manual)
Jalankan perintah ini satu per satu untuk setiap domain agar folder sertifikatnya terpisah (sesuai `nginx.conf`):

```bash
# Domain 1
docker run --rm -it -v $(pwd)/certs:/etc/letsencrypt -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot certonly --webroot -w /var/www/certbot -d app.insamo.id --email aldan@example.com --agree-tos

# Domain 2
docker run --rm -it -v $(pwd)/certs:/etc/letsencrypt -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot certonly --webroot -w /var/www/certbot -d apiapp.insamo.id --email aldan@example.com --agree-tos

# Domain 3
docker run --rm -it -v $(pwd)/certs:/etc/letsencrypt -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot certonly --webroot -w /var/www/certbot -d cogniva.insamo.id --email aldan@example.com --agree-tos
```

*Catatan: Ganti email dengan email aktif Anda.*

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
curl -I https://app.insamo.id
curl -I https://apiapp.insamo.id
curl -I https://cogniva.insamo.id
```
Semuanya harus mengembalikan HTTP/2 200 atau 301/429 sesuai logika di `nginx.conf`.

---
*Dibuat oleh: Antigravity Assistant*