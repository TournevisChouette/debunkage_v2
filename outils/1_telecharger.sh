#!/bin/sh
# 1_telecharger.sh <dossier>  — télécharge Lotus Ami Pro 1.2B (Internet Archive), vérifie l'empreinte,
# extrait les deux images de disquette puis les archives .ZIP qu'elles contiennent.
# Dépendances : curl, 7z (p7zip-full), md5sum.
set -e
D=${1:?dossier de destination}; mkdir -p "$D"; cd "$D"
URL="https://archive.org/download/lotus-ami-pro-1.2b/Lotus%20Ami%20Pro%201.2B.7z"
MD5=1198dca56ab564d6db1d2a28698ab919
[ -f ami_pro_1.2B.7z ] || curl -L --max-time 900 -o ami_pro_1.2B.7z "$URL"
echo "$MD5  ami_pro_1.2B.7z" | md5sum -c -
7z x -y -opaquet ami_pro_1.2B.7z >/dev/null
for img in paquet/*.img; do 7z x -y -o"$img.x" "$img" >/dev/null; done
for z in paquet/*.img.x/*.ZIP; do 7z x -y -o"$z.x" "$z" >/dev/null; done
echo "paquet extrait dans $D/paquet"; ls paquet/*.img.x
