#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# Grafana Dashboard Validation Script
# Validates all provisioned dashboards via Grafana HTTP API
# ─────────────────────────────────────────────────────────────

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3200}"
GRAFANA_USER="${GRAFANA_USER:-admin}"
GRAFANA_PASS="${GRAFANA_PASS:-admin}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

python3 "${SCRIPT_DIR}/validate.py" \
    --url "$GRAFANA_URL" \
    --user "$GRAFANA_USER" \
    --password "$GRAFANA_PASS" \
    --dashboard-dir "$SCRIPT_DIR"
