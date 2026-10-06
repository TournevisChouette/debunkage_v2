#!/usr/bin/env python3
"""pc_vers_date.py <nombre> — convertit un nombre du bloc [desc] (ex. 732650811) en date lue sur l'horloge du PC,
et donne la chaîne à passer à 3_lancer_a_la_date.sh ou 4_essai22.sh (heure locale de votre machine)."""
import sys
from datetime import datetime
from zoneinfo import ZoneInfo
v = int(sys.argv[1]); w = datetime.fromtimestamp(v, ZoneInfo("America/Los_Angeles")).replace(tzinfo=None)
print(v, "→ horloge du PC :", w.strftime("%Y-%m-%d %H:%M:%S"))
