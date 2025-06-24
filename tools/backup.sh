#!/bin/bash

# Konfigurasi
BACKUP_DIR="/var/backups"
DATETIME=$(date +"%Y-%m-%d_%H-%M-%S")
DATE=$(date +"%Y-%m-%d")
S3_ENDPOINT="https://7e640e5a6f0f57607c19797d0bf5b661.r2.cloudflarestorage.com"
S3_BUCKET="s3://backup"
S3_OPTS="--endpoint-url $S3_ENDPOINT --profile s3-compatible"


# Pastikan direktori backup ada
mkdir -p "$BACKUP_DIR"

# Loop semua user di /home
for user_dir in /home/*; do
    username=$(basename "$user_dir")
    
    echo "🔄 Backup untuk user: $username"
    
    # 1. Backup file user
    tar_file="${BACKUP_DIR}/${username}_files_${DATETIME}.tar.gz"
    tar -czf "$tar_file" "$user_dir"
    
    echo "📁 File user dibackup: $tar_file"
    
    # 2. Backup database user (asumsi nama database = nama user)
    db_file="${BACKUP_DIR}/${username}_db_${DATETIME}.sql.gz"
    mysqldump "$username" | gzip > "$db_file" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "🛢️  Database dibackup: $db_file"
    else
        echo "⚠️  Gagal backup database untuk $username."
        rm -f "$db_file"
    fi
    
    # 3. Upload ke S3
    echo "☁️  Upload ke S3..."
    aws s3 cp "$tar_file" "$S3_BUCKET/${DATE}/$(basename "$tar_file")" $S3_OPTS && rm -f "$tar_file"
    
    if [ -f "$db_file" ]; then
        aws s3 cp "$db_file" "$S3_BUCKET/${DATE}/$(basename "$db_file")" $S3_OPTS && rm -f "$db_file"
    fi
done

echo "✅ Backup selesai."
