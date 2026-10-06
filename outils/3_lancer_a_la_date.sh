#!/bin/sh
# 3_lancer_a_la_date.sh <prefixe> "<AAAA-MM-JJ HH:MM:SS>" [:écran] [document]
# Lance Ami Pro 1.2B avec une horloge réglée : à l'instant du lancement, le logiciel croit que l'horloge
# du PC indique la date donnée (heure locale de votre machine). Le document vierge s'ouvre ~2 s plus tard :
# c'est cet instant qu'Ami Pro enregistre comme date de création.
# Dépendances : gcc avec le support 32 bits (gcc-multilib), wine32, Xvfb, bubblewrap.
set -e
P=${1:?prefixe}; D=${2:?date locale}; E=${3:-:77}; DOC=$4; H=$(dirname "$0")
CIBLE=$(date -d "$D" +%s); NOW=$(date +%s); OFF=$((NOW-CIBLE))
gcc -m32 -shared -fPIC -O1 -nostdlib -nostartfiles -ffreestanding -DOFF=${OFF}LL -o "$P/horloge.so" "$H/horloge.c"
WS=$(ls /usr/lib/i386-linux-gnu/wine/wineserver /usr/lib/wine/wineserver /usr/bin/wineserver 2>/dev/null | head -1)
WINEPREFIX=$P "$WS" -k 2>/dev/null || true; sleep 1.5
echo "lancement : horloge réelle $(date '+%F %T'), horloge vue par Ami Pro $(date -d @$CIBLE '+%F %T')"
LD_PRELOAD=$P/horloge.so sh "$H/lancer.sh" "$P" "$E" $DOC 2>&1 | grep -v "wrong ELF class" || true
