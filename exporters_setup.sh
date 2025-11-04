#!/bin/bash
set -e

# ============================
# CONFIGURACIÓN BASE
# ============================
INSTALL_DIR="$HOME/.local"
BIN_DIR="$INSTALL_DIR/bin"
ETC_DIR="$INSTALL_DIR/etc"
VAR_DIR="$INSTALL_DIR/var"
TMP_DIR="/tmp"

mkdir -p "$BIN_DIR" "$ETC_DIR" "$VAR_DIR"

# ============================
# 1. NODE EXPORTER
# ============================
echo "[+] Instalando Node Exporter..."

cd "$TMP_DIR"
wget -q https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xzf node_exporter-1.6.1.linux-amd64.tar.gz
cd node_exporter-1.6.1.linux-amd64

cp node_exporter "$BIN_DIR/"

echo "✅ Node Exporter instalado en $BIN_DIR/node_exporter"

# ============================
# 2. PROMTAIL
# ============================
echo "[+] Instalando Promtail..."

cd "$TMP_DIR"
wget -q https://github.com/grafana/loki/releases/download/v2.9.2/promtail-linux-amd64.zip
unzip -q promtail-linux-amd64.zip
mv promtail-linux-amd64 "$BIN_DIR/promtail"

mkdir -p "$ETC_DIR/promtail" "$VAR_DIR/promtail"

# ============================
# CONFIGURACIÓN DE PROMTAIL
# ============================
# Detectar el hostname para ponerlo dinámicamente en la configuración
HOSTNAME=$(hostname)

cat > "$ETC_DIR/promtail/promtail-config.yaml" <<EOF
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: $VAR_DIR/promtail/positions.yaml

clients:
  - url: http://192.168.122.195:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          host: $HOSTNAME
          __path__: /var/log/*.log

  - job_name: ssh_auth
    static_configs:
      - targets:
          - localhost
        labels:
          job: auth
          host: $HOSTNAME
          __path__: /var/log/auth.log

  - job_name: syslog
    static_configs:
      - targets:
          - localhost
        labels:
          job: syslog
          host: $HOSTNAME
          __path__: /var/log/syslog
EOF

echo "✅ Promtail configurado en $ETC_DIR/promtail/promtail-config.yaml"

# ============================
# EXPORTAR PATH
# ============================
if ! grep -q "$BIN_DIR" <<< "$PATH"; then
  echo "export PATH=\$PATH:$BIN_DIR" >> "$HOME/.bashrc"
  export PATH="$PATH:$BIN_DIR"
fi

# ============================
# FIN
# ============================
echo ""
echo "✅ Instalación completada."
echo ""
echo "Binarios instalados en: $BIN_DIR"
echo "Configuración Promtail: $ETC_DIR/promtail/promtail-config.yaml"
echo ""
echo "Para ejecutar los servicios manualmente:"
echo "  node_exporter &"
echo "  promtail --config.file=$ETC_DIR/promtail/promtail-config.yaml &"
echo ""
echo "Para ver logs: tail -f ~/.local/var/promtail/positions.yaml"
