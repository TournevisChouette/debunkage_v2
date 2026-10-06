#!/usr/bin/env python3
"""lire_desc.py <fichier.SAM> — lit le bloc [desc] d'un fichier Ami Pro : description, dernier enregistrement,
nombre de sessions, création. Les deux nombres sont des secondes depuis 1970 ; Ami Pro les calcule en prenant
l'horloge du PC pour l'heure du Pacifique : on les relit donc dans ce fuseau pour retrouver ce que l'horloge affichait."""
import sys, re
from datetime import datetime
from zoneinfo import ZoneInfo
LA = ZoneInfo("America/Los_Angeles")
def pc(v): return datetime.fromtimestamp(int(v), LA).strftime("%d/%m/%Y %H:%M:%S")
t = open(sys.argv[1], "rb").read().decode("latin-1").replace("\r", "")
m = re.search(r"^\[desc\]\n(.*?)(?:^\[|\Z)", t, re.S | re.M)
if not m: sys.exit("pas de bloc [desc]")
l = [x.strip("\t") for x in m.group(1).split("\n")]
print("description :", repr(l[0]))
print("dernier enregistrement :", l[5], "→ horloge du PC", pc(l[5]))
print("sessions :", l[6])
print("création :", l[7], "→ horloge du PC", pc(l[7]))
