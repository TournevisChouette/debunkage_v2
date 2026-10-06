"""Pilote l'écran virtuel par XTest (python-xlib) : xkey.py :77 click:37,37 text:C:\\TESTS\\A.SAM Return Control_L+End sleep:2
« + » = combinaison de touches ; drag:x1,y1,x2,y2 = glisser bouton gauche ; click:x,y = clic gauche ; text:… = saisie ; sleep:s = pause."""
import sys, time
from Xlib import X, XK, display
from Xlib.ext import xtest
d = display.Display(sys.argv[1])
def kc(name):
    return d.keysym_to_keycode(XK.string_to_keysym(name))
def tap(names):
    codes=[kc(n) for n in names]
    for c in codes: xtest.fake_input(d, X.KeyPress, c); d.sync(); time.sleep(0.03)
    for c in reversed(codes): xtest.fake_input(d, X.KeyRelease, c); d.sync(); time.sleep(0.03)
    time.sleep(0.25)
SPECIAL={',':'comma','\\':'backslash',':':'colon','.':'period','_':'underscore',' ':'space','-':'minus'}
for arg in sys.argv[2:]:
    if arg.startswith('text:'):
        for ch in arg[5:]:
            if ch.isupper(): tap(['Shift_L', ch.lower()])
            elif ch in SPECIAL:
                n=SPECIAL[ch]; tap(['Shift_L',n] if ch in ':_' else [n])
            else: tap([ch])
    elif arg.startswith('sleep:'): time.sleep(float(arg[6:]))
    elif arg.startswith('drag:'):
        x1,y1,x2,y2=map(int,arg[5:].split(','))
        xtest.fake_input(d, X.MotionNotify, x=x1, y=y1); d.sync(); time.sleep(0.1)
        xtest.fake_input(d, X.ButtonPress, 1); d.sync(); time.sleep(0.2)
        for i in range(1,11):
            xtest.fake_input(d, X.MotionNotify, x=x1+(x2-x1)*i//10, y=y1+(y2-y1)*i//10); d.sync(); time.sleep(0.05)
        xtest.fake_input(d, X.ButtonRelease, 1); d.sync(); time.sleep(0.4)
    elif arg.startswith('click:'):
        x,y=map(int,arg[6:].split(','))
        xtest.fake_input(d, X.MotionNotify, x=x, y=y); d.sync(); time.sleep(0.1)
        xtest.fake_input(d, X.ButtonPress, 1); d.sync(); time.sleep(0.05)
        xtest.fake_input(d, X.ButtonRelease, 1); d.sync(); time.sleep(0.4)
    else: tap(arg.split('+'))
