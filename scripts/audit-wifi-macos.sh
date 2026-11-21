#!/bin/bash
# Audit Wi-Fi / Freebox - macOS - LECTURE SEULE (aucun paramètre modifié)
# Usage : bash scripts/audit-wifi-macos.sh avant
LABEL="${1:-avant}"; FREEBOX="${2:-192.168.1.254}"
DIR="$(cd "$(dirname "$0")/.." && pwd)/resultats"; mkdir -p "$DIR"
OUT="$DIR/audit-macos-$LABEL-$(date +%Y%m%d-%H%M).txt"
run(){ echo -e "\n===== $1 =====" | tee -a "$OUT"; shift; "$@" 2>&1 | tee -a "$OUT"; }
echo "Audit Wi-Fi - label=$LABEL - $(date)" | tee "$OUT"
run "Systeme" sw_vers
run "Wi-Fi (signal, bruit, canal, PHY, débit)" system_profiler SPAirPortDataType
run "Interfaces" ifconfig
run "Passerelle" route -n get default
run "ARP" arp -an
GW=$(route -n get default 2>/dev/null | awk '/gateway/{print $2}'); GW=${GW:-$FREEBOX}
run "Ping passerelle $GW" ping -c 50 "$GW"
run "Ping Internet 1.1.1.1" ping -c 30 1.1.1.1
run "Traceroute" traceroute -n -m 8 1.1.1.1
echo -e "\n===== Débit descendant (3 x 10 Mo) =====" | tee -a "$OUT"
for i in 1 2 3; do
  s=$(curl -s -o /dev/null -w "%{speed_download}" "https://speed.cloudflare.com/__down?bytes=10000000")
  echo "Essai $i : $(echo "$s*8/1000000" | bc -l | cut -c1-5) Mbit/s" | tee -a "$OUT"
done
echo -e "\n===== Débit montant (1 Mo) =====" | tee -a "$OUT"
s=$(head -c 1000000 /dev/zero | curl -s -o /dev/null -w "%{speed_upload}" --data-binary @- "https://speed.cloudflare.com/__up")
echo "Montant : $(echo "$s*8/1000000" | bc -l | cut -c1-5) Mbit/s" | tee -a "$OUT"
echo -e "\nTerminé. Fichier : $OUT"
