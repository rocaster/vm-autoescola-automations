#!/bin/bash
# =============================================================================
# backup.sh - Daily backup for the VM Autoescola stack (Odoo + n8n + Evolution API)
#
# 1. Dumps every PostgreSQL database (Odoo, Evolution API...) with pg_dumpall
# 2. Packs the dump + the Docker project folder into a single .tar.gz
# 3. Uploads the archive to Google Drive with rclone
# 4. Cleans up the local temporary files
#
# Cron (every day at 19:00):
#   0 19 * * * /bin/bash /opt/backup.sh >> /var/log/backup_autoescola.log 2>&1
#
# Requirements: docker, tar, rclone with a remote named "gdrive" (rclone config)
# =============================================================================

set -euo pipefail

# ---- Settings (adjust to your environment) ----------------------------------
DB_CONTAINER="vm-autoescola-db-1"          # PostgreSQL container name
DB_USER="odoo"                             # PostgreSQL superuser
PROJECT_DIR="/home/suporte/vm-autoescola"  # Docker Compose project folder
BACKUP_DIR="/tmp/backups"                  # Local temporary folder
RCLONE_DEST="gdrive:Backups_Sistema/"      # rclone remote:folder

DATE=$(date +"%Y-%m-%d")
DUMP_FILE="$BACKUP_DIR/database_$DATE.sql"
ARCHIVE="$BACKUP_DIR/backup_sistema_$DATE.tar.gz"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

mkdir -p "$BACKUP_DIR"

# 1. Dump all PostgreSQL databases
#    (no -t flag: a TTY would add \r characters and corrupt the dump)
log "Dumping PostgreSQL from container $DB_CONTAINER..."
docker exec "$DB_CONTAINER" pg_dumpall -c -U "$DB_USER" > "$DUMP_FILE"

# 2. Compress the dump and the project folder
log "Creating archive $ARCHIVE..."
tar -czf "$ARCHIVE" "$DUMP_FILE" "$PROJECT_DIR"

# 3. Upload to Google Drive
log "Uploading to $RCLONE_DEST..."
rclone copy "$ARCHIVE" "$RCLONE_DEST"

# 4. Local cleanup
rm -f "$DUMP_FILE" "$ARCHIVE"
log "Backup finished successfully."
