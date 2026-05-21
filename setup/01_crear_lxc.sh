#!/bin/bash
# ============================================================
# 01_crear_lxc.sh
# Crea los 3 contenedores LXC para el laboratorio SOC casero
# Ejecutar desde la shell del host Proxmox
# ============================================================

set -e

PLANTILLA="local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"

echo "[*] Aplicando sysctl necesario para Wazuh Indexer..."
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144

echo ""
echo "[*] Creando LXC 101 — Servidor Wazuh..."
pct create 101 $PLANTILLA \
  --hostname wazuh-server \
  --memory 5120 \
  --cores 2 \
  --rootfs local-lvm:50 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --unprivileged 0 \
  --features nesting=1 \
  --password Wazuh1234! \
  --start 0
echo "[+] LXC 101 creado."

echo ""
echo "[*] Creando LXC 102 — Monitor Zeek..."
pct create 102 $PLANTILLA \
  --hostname zeek-monitor \
  --memory 1024 \
  --cores 1 \
  --rootfs local-lvm:20 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --unprivileged 1 \
  --features nesting=1 \
  --password Zeek1234! \
  --start 0
echo "[+] LXC 102 creado."

echo ""
echo "[*] Creando LXC 103 — Agente Ubuntu..."
pct create 103 $PLANTILLA \
  --hostname ubuntu-agente \
  --memory 512 \
  --cores 1 \
  --rootfs local-lvm:10 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --unprivileged 1 \
  --features nesting=1 \
  --password Agente1234! \
  --start 0
echo "[+] LXC 103 creado."

echo ""
echo "[*] Arrancando todos los contenedores..."
pct start 101 && sleep 5
pct start 102 && sleep 5
pct start 103 && sleep 5

echo ""
echo "================================================="
echo "[+] Contenedores en marcha. IPs asignadas:"
echo "-------------------------------------------------"
echo -n "  LXC 101 (Wazuh):  "
pct exec 101 -- ip -4 a show eth0 | grep inet | awk '{print $2}' | cut -d/ -f1
echo -n "  LXC 102 (Zeek):   "
pct exec 102 -- ip -4 a show eth0 | grep inet | awk '{print $2}' | cut -d/ -f1
echo -n "  LXC 103 (Agente): "
pct exec 103 -- ip -4 a show eth0 | grep inet | awk '{print $2}' | cut -d/ -f1
echo "================================================="
echo ""
echo "Siguiente paso: pct enter 101 → bash 02_instalar_wazuh.sh"
