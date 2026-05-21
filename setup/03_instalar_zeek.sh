#!/bin/bash
# ============================================================
# 03_instalar_zeek.sh
# Instala el monitor de red Zeek en Ubuntu 24.04
# Ejecutar DENTRO del LXC 102: pct enter 102
# ============================================================

set -e

echo "[*] Actualizando sistema..."
apt update && apt install -y curl gnupg

echo ""
echo "[*] Añadiendo repositorio de Zeek..."
echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_24.04/ /' \
  | tee /etc/apt/sources.list.d/security:zeek.list

curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_24.04/Release.key \
  | gpg --dearmor \
  | tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null

echo ""
echo "[*] Instalando Zeek..."
apt update && apt install zeek -y

echo ""
echo "[*] Configurando PATH..."
echo 'export PATH=$PATH:/opt/zeek/bin' >> ~/.bashrc
export PATH=$PATH:/opt/zeek/bin

echo ""
echo "[*] Detectando interfaz de red..."
IFACE=$(ip route | grep default | awk '{print $5}' | head -1)
echo "    Interfaz detectada: $IFACE"
sed -i "s/interface=.*/interface=$IFACE/" /opt/zeek/etc/node.cfg

echo ""
echo "[*] Desplegando Zeek..."
/opt/zeek/bin/zeekctl deploy

echo ""
echo "[*] Verificando estado..."
/opt/zeek/bin/zeekctl status

echo ""
echo "================================================="
echo "[+] Zeek instalado correctamente."
echo "    Logs en: /opt/zeek/logs/current/"
echo "    Ver conexiones: cat /opt/zeek/logs/current/conn.log"
echo "================================================="
