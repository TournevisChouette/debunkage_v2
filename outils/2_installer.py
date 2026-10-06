#!/usr/bin/env python3
"""Installe Lotus Ami Pro 1.2B (anglais) dans un préfixe wine 32 bits, sans l'installateur DOS (2_installer.py).

Usage :
    2_installer.py <paquet> <prefixe>
      <paquet>  : dossier du paquet 1.2B extrait par 1_telecharger.sh (« Program 1.img.x »,
                  « Program 2.img.x », chaque *.ZIP déjà décompressé dans *.ZIP.x)
      <prefixe> : WINEPREFIX à créer

Suit STRINGS.INS : copie des archives vers C:\\AMIPRO (docs.zip → DOCS, styles.zip → STYLES,
macros.zip → MACROS, drawsym.zip → DRAW ; NewWave et modèles ignorés), puis section [AmiPro]
de WIN.INI (chemins et filtres d'importation), imprimantes CUPS retirées du registre.
Écrit uniquement dans <prefixe>. Lancer ensuite `lancer.sh <prefixe>` (même lanceur que la 3.0).
"""
import glob, os, re, shutil, subprocess, sys

DEST = {"docs": "DOCS", "styles": "STYLES", "macros": "MACROS", "drawsym": "DRAW"}
IGNORE = {"newwave", "newwave2", "template"}


def main(paquet, prefixe):
    env = dict(os.environ, WINEPREFIX=prefixe, WINEDEBUG="-all", CUPS_SERVER="/nonexistent/cups.sock")
    subprocess.run(["xvfb-run", "-a", "wine32", "wineboot", "-i"], env=env, check=False)
    C = os.path.join(prefixe, "drive_c"); A = C + "/AMIPRO"
    for sub in ("", "DOCS", "STYLES", "MACROS", "DRAW"):
        os.makedirs(os.path.join(A, sub), exist_ok=True)
    for x in sorted(glob.glob(os.path.join(glob.escape(paquet), "Program *.img.x", "*.ZIP.x"))):
        nom = os.path.basename(x)[:-6].lower()
        if nom in IGNORE:
            continue
        d = os.path.join(A, DEST.get(nom, ""))
        for f in os.listdir(x):
            shutil.copy(os.path.join(x, f), os.path.join(d, f.upper()))
    ins = open(os.path.join(paquet, "Program 1.img.x", "STRINGS.INS"), "rb").read().decode("cp850")
    lignes = re.findall(r"^\[AmiPro\] (.+?)\r?$", ins, re.M)
    lignes = [l.replace("<INSTDIR>", "C:\\AMIPRO") for l in lignes]
    win = os.path.join(C, "windows", "win.ini")
    s = open(win, "rb").read().decode("cp1252") if os.path.exists(win) else ""
    if "[AmiPro]" not in s:
        s = s.rstrip("\r\n") + "\r\n\r\n[AmiPro]\r\n" + "".join(l + "\r\n" for l in lignes)
        s += ("\r\n[AmiVISD]\r\nWindows Metafile=AmiWMF.dll,.wmf,CF_METAFILEPICT\r\nAmiPaint=AmiPaint.dll,.sdp,CF_BITMAP\r\n"
              "AmiImage=AmiImage.dll,.tgf\r\nAmiDraw=AmiDraw.dll,.sdw\r\n")
        open(win, "wb").write(s.encode("cp1252"))
    reg = os.path.join(prefixe, "reglages.reg")
    open(reg, "w").write("REGEDIT4\n\n[-HKEY_CURRENT_USER\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Devices]\n"
                         "[-HKEY_CURRENT_USER\\Software\\Microsoft\\Windows NT\\CurrentVersion\\PrinterPorts]\n"
                         "[-HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Control\\Print\\Printers]\n\n"
                         "[HKEY_CURRENT_USER\\Software\\Wine\\Explorer]\n\"Desktop\"=\"Default\"\n\n"
                         "[HKEY_CURRENT_USER\\Software\\Wine\\Explorer\\Desktops]\n\"Default\"=\"1024x768\"\n")
    subprocess.run(["wine32", "regedit", "/S", reg], env=env, check=False)
    print("installé dans", A)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
