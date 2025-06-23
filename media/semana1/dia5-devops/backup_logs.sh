#!/bin/bash

# Automate:
# 1. Compress /var/log/ folder
# 2. Save with timestamp into /backup/logs/
# 3. Delete backups older than 7 days

function compress_logs() {
  local target_dir=$1
  local backup_dir=$2
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local backup_file="${backup_dir}/logs_${timestamp}.tar.gzip"
  # Create backup directory if it doesn't exist
  mkdir -p "$backup_dir"
  # Compress the logs
  tar -czf "$backup_file" -C "$target_dir" .
  echo "Logs compressed and saved to $backup_file"
}

function delete_old_backups() {
  local backup_dir=$1
  find "$backup_dir" -type f -name "logs_*.tar.gzip" -mtime +7 -exec rm {} \;
  echo "Old backups deleted from $backup_dir"
}

function main() {
  local log_dir="/var/log"
  local backup_dir="/home/omnius/backup/logs"
  compress_logs "$log_dir" "$backup_dir"
  delete_old_backups "$backup_dir"
}

main "$@"
