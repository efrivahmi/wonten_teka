#!/bin/bash

# Script to sync and push ONLY the backend folder to the separate backend repo
# Usage: ./push-backend.sh "Your custom commit message"

if [ -z "$1" ]; then
    echo "❌ Error: Pesan commit (deskripsi) tidak boleh kosong."
    echo "Cara pakai: ./push-backend.sh \"Pesan commit untuk backend\""
    exit 1
fi

COMMIT_MSG="$1"

echo "=================================================="
echo "🔄 Menyalin folder backend ke repository backend-wonten-teka..."

MAIN_BACKEND_DIR="/home/ep/wonten_teka/backend/"
TARGET_BACKEND_DIR="/home/ep/backend-wonten-teka/"

rsync -a --exclude='.git' --exclude='node_modules' --exclude='vendor' --exclude='.env' --exclude='bootstrap/cache/*' --exclude='storage/framework/views/*' --exclude='storage/logs/*' "$MAIN_BACKEND_DIR" "$TARGET_BACKEND_DIR"

if [ $? -ne 0 ]; then
    echo "❌ Error: Gagal menyalin file backend."
    exit 1
fi

echo "🚀 Melakukan push ke repo backend-wonten-teka..."
cd "$TARGET_BACKEND_DIR" || exit 1

if [ -n "$(git status --porcelain)" ]; then
    git add .
    git commit -m "$COMMIT_MSG"
    git push
    if [ $? -eq 0 ]; then
        echo "✅ Berhasil push ke repository backend dengan pesan: \"$COMMIT_MSG\""
    else
        echo "❌ Error: Gagal melakukan push ke GitHub."
    fi
else
    echo "✅ Tidak ada perubahan baru di backend yang perlu di-push."
fi

echo "=================================================="
