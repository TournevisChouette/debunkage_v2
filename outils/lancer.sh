#!/bin/sh
# Lance Ami Pro 3.0 (installé par installer.py) sous wine32 dans un écran virtuel.
# Usage : lancer.sh <prefixe> [ecran, défaut :77] [document, ex. 'C:\TESTS\SOLUTION.SAM']
# Variables facultatives : POLICES=<dossier> (seules polices visibles, ex. Liberation pour
#   des métriques Times New Roman/Arial) ; GEOMETRIE=1024x768 (taille de l'écran virtuel).
# - Xvfb démarré si besoin (rien ne s'affiche sur le bureau) ;
# - CUPS rendu injoignable : aucune impression possible ;
# - polices système masquées par bubblewrap (/usr/share/fonts, /usr/local/share/fonts,
#   /usr/share/texmf) : avec des centaines de polices, AMIFONT.DLL dépasse la limite
#   de 64 Ko de son tableau 16 bits et plante (offset 0x476 du segment 1).
P=$1; E=${2:-:77}; VIDE=$P/polices_vides; mkdir -p "$VIDE"; POL=${POLICES:-$VIDE}; GEO=${GEOMETRIE:-1024x768}
cat > "$P/fonts.conf" <<CONF
<?xml version="1.0"?><fontconfig><dir>/usr/share/fonts</dir><cachedir>$P/fc_cache</cachedir></fontconfig>
CONF
pgrep -x Xvfb >/dev/null && for p in $(pgrep -x Xvfb); do tr '\0' ' ' < /proc/$p/cmdline | grep -q " $E" && OK=1; done
[ -z "$OK" ] && (setsid nohup Xvfb "$E" -screen 0 ${GEO}x16 >/dev/null 2>&1 < /dev/null &) && sleep 2
export WINEPREFIX=$P WINEDEBUG=-all CUPS_SERVER=/nonexistent/cups.sock DISPLAY=$E FONTCONFIG_FILE=$P/fonts.conf
cd "$P/drive_c/AMIPRO"
setsid nohup bwrap --dev-bind / / --bind "$POL" /usr/share/fonts --bind "$VIDE" /usr/local/share/fonts \
  --bind "$VIDE" /usr/share/texmf wine32 'C:\AMIPRO\AMIPRO.EXE' $3 > "$P/amipro.log" 2>&1 < /dev/null &
echo "Ami Pro lancé sur $E ; captures : DISPLAY=$E import -window root capture.png"
