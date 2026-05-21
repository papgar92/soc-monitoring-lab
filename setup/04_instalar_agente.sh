#!/bin/bash
# ============================================================
# 04_instalar_agente.sh
# Instala el agente Wazuh y lo conecta al servidor
# Ejecutar DENTRO del LXC 103: pct enter 103
#
# Uso:
#   WAZUH_MANAGER='192.168.1.X' bash 04_instalar_agente.sh
# ============================================================

set -e

if [ -z "$WAZUH_MANAGER" ]; then
  echo "[!] ERROR: Variable WAZUH_MANAGER no definida."
  echo "    Uso: WAZUH_MANAGER='192.168.1.X' bash 04_instalar_agente.sh"
  exit 1
fi

echo "[*] Actualizando sistema..."
apt update && apt install -y curl gnupg

echo ""
echo "[*] Añadiendo repositorio de Wazuh..."
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH \
  | gpg --no-default-keyring \
  --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import

chmod 644 /usr/share/keyrings/wazuh.gpg

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] \
  https://packages.wazuh.com/4.x/apt/ stable main" \
  | tee /etc/apt/sources.list.d/wazuh.list

apt update

echo ""
echo "[*] Instalando agente Wazuh apuntando a: $WAZUH_MANAGER"
WAZUH_MANAGER="$WAZUH_MANAGER" apt install wazuh-agent -y

echo ""
echo "[*] Activando e iniciando el agente..."
systemctl enable wazuh-agent
systemctl start wazuh-agent

echo ""
echo "[*] Verificando estado..."
systemctl is-active --quiet wazuh-agent \
  && echo "[+] wazuh-agent: activo" \
  || echo "[!] wazuh-agent: FALLO"

echo ""
echo "================================================="
echo "[+] Agente instalado y conectado a: $WAZUH_MANAGER"
echo "    Comprueba el dashboard de Wazuh → sección Agentes."
echo "================================================="
