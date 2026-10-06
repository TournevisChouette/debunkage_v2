#!/bin/sh
# 4_essai22.sh <prefixe> [python avec python-xlib] [:écran]
# Refait l'essai 22 de bout en bout : dix-huit sessions d'Ami Pro 1.2B, l'horloge réglée, pour obtenir un fichier
# dont le bloc [desc] porte « Reco HYUNDAI », 738115576 (dernier enregistrement), 18 (sessions), 732650811 (création).
#   session 1  : document vierge ouvert quand l'horloge du PC dit 20/03/1993 10:06:51 ; Save As E22.SAM, description.
#   sessions 2 à 17 : le document rouvert à des dates entre le 22/04 et le 21/05/1993, un caractère, File / Save.
#   session 18 : clic sur Save à l'instant où l'horloge du PC dit 22/05/1993 17:06:16.
# Le délai entre le lancement et l'ouverture du document vierge dépend de la machine : il est mesuré d'abord (CAL.SAM).
P=${1:?prefixe}; PY=${2:-python3}; E=${3:-:77}; H=$(cd "$(dirname "$0")" && pwd); . "$H/fonctions.sh"
V1=732650811; V2=738115576
D1=$($PY "$H/pc_vers_date.py" $V1 | sed 's/.*: //'); D2=$($PY "$H/pc_vers_date.py" $V2 | sed 's/.*: //')
creation() { $PY "$H/lire_desc.py" "$1" | awk '/^création/{print $3}'; }
epoch() { date -d "$1" +%s; }
echo "cibles : création $V1 = $D1 (horloge du PC) ; dernier enregistrement $V2 = $D2"
# --- calibrage : combien de secondes entre le lancement et l'ouverture du document vierge ?
rm -f "$DOCS/CAL.SAM" "$DOCS/E22.SAM"
lancer_a "$D1"; $K click:600,400 "text:x" sleep:0.3 >/dev/null; enregistrer_sous CAL; arreter
d=$(( $(creation "$DOCS/CAL.SAM") - V1 )); echo "calibrage : le document s'ouvre $d s après le lancement"
# --- session 1
for essai in 1 2 3; do
  lancer_a "$(date -d "$D1 - $d seconds" '+%Y-%m-%d %H:%M:%S')"; $K click:600,400 "text:x" sleep:0.3 >/dev/null
  enregistrer_sous E22 "Reco HYUNDAI"; arreter
  c=$(creation "$DOCS/E22.SAM"); echo "session 1 : création $c (cible $V1)"; [ "$c" = "$V1" ] && break
  d=$(( d + c - V1 ))
done
# --- sessions 2 à 17 : dates échelonnées
j=0
for s in 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17; do
  j=$((j+2)); D=$(date -d "1993-04-20 10:00:00 + $j days" '+%Y-%m-%d %H:%M:%S')
  lancer_a "$D" 'C:\AMIPRO\DOCS\E22.SAM'; $K click:600,400 "text:x" sleep:0.3 >/dev/null; enregistrer; arreter
  echo "session $s : horloge $D → $($PY "$H/lire_desc.py" "$DOCS/E22.SAM" | awk '/^sessions/{print $3}') sessions"
done
# --- session 18 : Save à la seconde exacte
F0=$(date -d "$D2 - 90 seconds" '+%Y-%m-%d %H:%M:%S'); R0=$(date +%s)
lancer_a "$F0" 'C:\AMIPRO\DOCS\E22.SAM'; $K click:600,400 "text:x" sleep:0.3 click:17,41 sleep:0.7 >/dev/null
cible_reel=$(( R0 + $(epoch "$D2") - $(epoch "$F0") ))
$PY -c "import time; time.sleep(max(0, $cible_reel - time.time()))"
$K click:31,91 sleep:2.5 >/dev/null; fermer_messages; arreter
echo "=== résultat : $DOCS/E22.SAM"; $PY "$H/lire_desc.py" "$DOCS/E22.SAM"
