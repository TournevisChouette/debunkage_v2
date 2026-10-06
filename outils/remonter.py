"""Remonte au premier plan les boîtes de dialogue d'Ami Pro restées sous la fenêtre principale
(défaut de l'écran virtuel de wine : la boîte existe, reçoit le focus modal, mais reste invisible
et inaccessible à la souris). Usage : remonter.py :77  → imprime les fenêtres remontées."""
import sys, time
from Xlib import display, X
d = display.Display(sys.argv[1])
bureau = d.screen().root.query_tree().children[0]
for c in bureau.query_tree().children:
    try:
        a, g, n = c.get_attributes(), c.get_geometry(), c.get_wm_name()
    except Exception:
        continue
    if a.map_state == X.IsViewable and g.width < d.screen().width_in_pixels:
        c.configure(stack_mode=X.Above)
        print(hex(c.id), n, g.x, g.y, g.width, g.height)
d.sync(); time.sleep(0.5)
