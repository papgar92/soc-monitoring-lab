#!/bin/bash
# ============================================================
# 02_instalar_wazuh.sh
# Instala Wazuh all-in-one: Manager + Indexer + Dashboard
# Ejecutar DENTRO del LXC 101: pct enter 101
# ============================================================

set -e

echo "[*] Actualizando sistema..."
apt update && apt upgrade -y
apt install curl -y

echo ""
echo "[*] Descargando instalador de Wazuh..."
curl -sO https://packages.wazuh.com/4.12/wazuh-install.sh

echo ""
echo "[*] Ejecutando instalación all-in-one de Wazuh..."
echo "    Esto tardará entre 15 y 20 minutos. Por favor, espera."
echo ""
bash wazuh-install.sh -a

echo ""
echo "[*] Verificando servicios..."
systemctl is-active --quiet wazuh-manager   && echo "[+] wazuh-manager:   activo" || echo "[!] wazuh-manager:   FALLO"
systemctl is-active --quiet wazuh-indexer   && echo "[+] wazuh-indexer:   activo" || echo "[!] wazuh-indexer:   FALLO"
systemctl is-active --quiet wazuh-dashboard && echo "[+] wazuh-dashboard: activo" || echo "[!] wazuh-dashboard: FALLO"

echo ""
echo "================================================="
echo "[+] Instalación de Wazuh completada."
echo "    Accede al dashboard en: https://$(hostname -I | awk '{print $1}')"
echo "    Las credenciales se mostraron arriba — guárdalas ahora."
echo "================================================="
