#!/bin/bash
set -e

# ============================
# CONFIGURACIÓN LOCAL
# ============================
BASE_DIR="$HOME/.local"
BIN_DIR="$BASE_DIR/bin"
ETC_DIR="$BASE_DIR/etc"
VAR_DIR="$BASE_DIR/var"
LOG_DIR="$BASE_DIR/log"

mkdir -p "$LOG_DIR"

# ============================
# INICIAR PROMETHEUS
# ============================
echo "[+] Iniciando Prometheus..."
"$BIN_DIR/prometheus" \
  --config.file="$ETC_DIR/prometheus/prometheus.yml" \
  --storage.tsdb.path="$VAR_DIR/prometheus" \
  --web.console.templates="$ETC_DIR/prometheus/consoles" \
  --web.console.libraries="$ETC_DIR/prometheus/console_libraries" \
  >> "$LOG_DIR/prometheus.log" 2>&1 &

PROM_PID=$!
echo "Prometheus iniciado (PID: $PROM_PID) en puerto 9090"

# ============================
# INICIAR ALERTMANAGER
# ============================
echo "[+] Iniciando Alertmanager..."
"$BIN_DIR/alertmanager" \
  --config.file="$ETC_DIR/alertmanager/alertmanager.yml" \
  --storage.path="$VAR_DIR/alertmanager" \
  >> "$LOG_DIR/alertmanager.log" 2>&1 &

ALERT_PID=$!
echo "Alertmanager iniciado (PID: $ALERT_PID) en puerto 9093"

# ============================
# INICIAR LOKI
# ============================
echo "[+] Iniciando Loki..."
"$BIN_DIR/loki" \
  --config.file="$ETC_DIR/loki/loki-config.yaml" \
  >> "$LOG_DIR/loki.log" 2>&1 &

LOKI_PID=$!
echo "Loki iniciado (PID: $LOKI_PID) en puerto 3100"

# ============================
# INICIAR GRAFANA (del sistema)
# ============================
echo "[+] Iniciando Grafana..."
/usr/sbin/grafana-server \
  --config=/etc/grafana/grafana.ini \
  --homepath=/usr/share/grafana \
  >> /var/log/grafana.log 2>&1 &

GRAFANA_PID=$!
echo "Grafana iniciado (PID: $GRAFANA_PID) en puerto 3000"
echo "Accede a Grafana en: http://localhost:3000"

# ============================
# INFORME FINAL
# ============================
echo ""
echo "✅ Todos los servicios han sido iniciados correctamente."
echo "Logs disponibles en:"
echo "  Prometheus: $LOG_DIR/prometheus.log"
echo "  Alertmanager: $LOG_DIR/alertmanager.log"
echo "  Loki: $LOG_DIR/loki.log"
echo "  Grafana: /var/log/grafana.log"
echo ""
echo "Para detenerlos puedes usar:"
echo "  kill $PROM_PID $ALERT_PID $LOKI_PID $GRAFANA_PID"
