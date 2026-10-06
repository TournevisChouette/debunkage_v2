"""fenetres.py :77 [motif]  → liste les fenêtres visibles (id, nom, géométrie) ; avec motif, remonte celle dont le nom le contient."""
import sys
from Xlib import display, X
d = display.Display(sys.argv[1]); root = d.screen().root
motif = sys.argv[2] if len(sys.argv) > 2 else None
def parcourir(w, prof=0):
    for c in w.query_tree().children:
        try:
            a, g, n = c.get_attributes(), c.get_geometry(), c.get_wm_name()
        except Exception:
            continue
        if a.map_state == X.IsViewable and n:
            print(f"{'  '*prof}{hex(c.id)} {n!r} {g.x},{g.y} {g.width}x{g.height}")
            if motif and motif in n:
                c.configure(stack_mode=X.Above); print("  -> remontée")
        if prof < 2: parcourir(c, prof+1)
parcourir(root); d.sync()
