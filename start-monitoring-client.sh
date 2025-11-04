#!/bin/bash
set -e

# ============================
# CONFIGURACIÓN LOCAL
# ============================
BASE_DIR="$HOME/.local"
BIN_DIR="$BASE_DIR/bin"
ETC_DIR="$BASE_DIR/etc"
LOG_DIR="$BASE_DIR/log"

mkdir -p "$LOG_DIR"

# ============================
# INICIAR NODE EXPORTER
# ============================
echo "[+] Iniciando Node Exporter..."
"$BIN_DIR/node_exporter" >> "$LOG_DIR/node_exporter.log" 2>&1 &

NODE_PID=$!
echo "Node Exporter iniciado (PID: $NODE_PID) en puerto 9100"

# ============================
# INICIAR PROMTAIL
# ============================
echo "[+] Iniciando Promtail..."
"$BIN_DIR/promtail" \
  --config.file="$ETC_DIR/promtail/promtail-config.yaml" \
  >> "$LOG_DIR/promtail.log" 2>&1 &

PROMTAIL_PID=$!
echo "Promtail iniciado (PID: $PROMTAIL_PID)"

# ============================
# INFORME FINAL
# ============================
echo ""
echo "✅ Todos los servicios del cliente están en ejecución."
echo "Logs disponibles en: $LOG_DIR"
echo ""
echo "Para detenerlos, ejecuta:"
echo "  kill $NODE_PID $PROMTAIL_PID"
