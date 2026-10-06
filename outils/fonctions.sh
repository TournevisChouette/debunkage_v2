# Fonctions de pilotage d'Ami Pro 1.2B sur l'écran virtuel (coordonnées pour 1024x768). Usage : . fonctions.sh
# Variables attendues : P (préfixe wine), E (écran, ex. :77), PY (python avec python-xlib). H = dossier des outils.
H=${H:-$(cd "$(dirname "$0")" && pwd)}; PY=${PY:-python3}
K="$PY $H/xkey.py $E"; R="$PY $H/remonter.py $E"; F="$PY $H/fenetres.py $E"
DOCS=$P/drive_c/AMIPRO/DOCS
fermer_messages() { n=0; for i in 1 2 3 4 5 6 7 8; do sleep 2; L=$($F | grep -E "'Ami Pro' [0-9]+,[0-9]+ [23][0-9][0-9]x1[0-9][0-9]" | head -1); if [ -n "$L" ]; then set -- $(echo "$L" | sed -E "s/.*'Ami Pro' ([0-9]+),([0-9]+) ([0-9]+)x([0-9]+).*/\1 \2 \3 \4/"); $K click:$(($1+$3/2)),$(($2+$4-24)) >/dev/null; n=0; else n=$((n+1)); [ $n -ge 2 ] && break; fi; done; }
lancer_a() { sh "$H/3_lancer_a_la_date.sh" "$P" "$1" "$E" "$2" >/dev/null 2>&1; sleep 8; fermer_messages; }
WS=$(ls /usr/lib/i386-linux-gnu/wine/wineserver /usr/lib/wine/wineserver /usr/bin/wineserver 2>/dev/null | head -1)
arreter() { WINEPREFIX=$P "$WS" -k 2>/dev/null || true; sleep 1.5; }
# enregistrer_sous NOM [DESCRIPTION] : File / Save As, nom, description facultative, OK
enregistrer_sous() { $K click:17,41 sleep:1 click:44,108 sleep:1.5 >/dev/null; $R >/dev/null; $K click:328,118 End Shift_L+Home "text:$1" sleep:0.5 >/dev/null; [ -n "$2" ] && $K click:430,355 "text:$2" sleep:0.5 >/dev/null; $K click:527,118 sleep:2.5 >/dev/null; fermer_messages; }
enregistrer() { $K click:17,41 sleep:0.7 click:31,91 sleep:2.5 >/dev/null; fermer_messages; }
capture() { DISPLAY=$E import -window root "$1"; }
