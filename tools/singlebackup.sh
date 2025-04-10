#!/bin/bash

# Konfigurasi
BACKUP_DIR="/var/backups"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
S3_ENDPOINT="https://is3.cloudhost.id"
S3_BUCKET="s3://fileassets"
S3_OPTS="--endpoint-url $S3_ENDPOINT --profile s3-compatible"
USER=""

# Pastikan direktori backup ada
mkdir -p "$BACKUP_DIR"

# Loop semua user di /home
username=$(basename "$USER")

echo "🔄 Backup untuk user: $username"

# 1. Backup file user
tar_file="${BACKUP_DIR}/${username}_files_${DATE}.tar.gz"
tar -czf "$tar_file" "/home/$USER"

echo "📁 File user dibackup: $tar_file"

# 2. Backup database user (asumsi nama database = nama user)
db_file="${BACKUP_DIR}/${username}_db_${DATE}.sql.gz"
mysqldump "$username" | gzip > "$db_file" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "🛢️  Database dibackup: $db_file"
else
    echo "⚠️  Gagal backup database untuk $username."
    rm -f "$db_file"
fi

# 3. Upload ke S3
echo "☁️  Upload ke S3..."
aws s3 cp "$tar_file" "$S3_BUCKET" $S3_OPTS && rm -f "$tar_file"

if [ -f "$db_file" ]; then
    aws s3 cp "$db_file" "$S3_BUCKET" $S3_OPTS && rm -f "$db_file"
fi

echo "✅ Backup selesai."
