#!/usr/bin/env bash
set -euo pipefail

DB_FILE="$(dirname "$0")/data/users.db"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USERNAME="$1"

if ! command -v sqlite3 &>/dev/null; then
    echo "sqlite3 not found, installing via apt-get..."
    apt-get install -y sqlite3
fi

if [[ ! -f "$DB_FILE" ]]; then
    echo "Error: database not found at $DB_FILE"
    exit 1
fi

CURRENT_TIER=$(sqlite3 "$DB_FILE" "SELECT tier FROM users WHERE username = '$USERNAME';")

if [[ -z "$CURRENT_TIER" ]]; then
    echo "Error: user '$USERNAME' not found"
    exit 1
fi

if [[ "$CURRENT_TIER" == "admin" ]]; then
    echo "User '$USERNAME' is already an admin"
    exit 0
fi

sqlite3 "$DB_FILE" \
    "UPDATE users SET tier = 'admin', verified = 1 WHERE username = '$USERNAME';"

echo "User '$USERNAME' promoted to admin (was: $CURRENT_TIER)"
