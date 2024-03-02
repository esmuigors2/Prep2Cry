#!/usr/bin/python

import sys, math

if len(sys.argv) < 2 or len(sys.argv) > 3 or sys.argv[1] == "-h":
    print("Usage: gpa2hb3.py YOUR_NUMBER")
    print("Conversion is both ways, between GPa and Eh/bohr^3")
    print("We find the direction from the magnitute of initial data; the threshold is 0.01 .")
    print("   You can still force conversion FROM less than 0.01 GPa by supplying option -g .")
    print("The script will not work if the pressure is below atmospheric one") # this is because Python starts printing numbers with exponent if less than 10e-4, not because I am so smart %)
    sys.exit(1)
virz = 0
if len(sys.argv) == 3:
    if sys.argv[1] == "-g":
        virz = 1
        inpv = sys.argv[2]
    else:
        print("Option was not recognized: " + sys.argv[1])
        sys.exit(3)
else:
    inpv = sys.argv[1]
inpvs = inpv.replace(".","")
while inpvs[0] == "0":
    inpvs = inpvs[1:]
nsig = len(inpvs)
try:
    inpv = float(inpv)
except ValueError:
    print("Usage: gpa2hb3.py YOUR_NUMBER")
    print("You did not give me a number...")
    sys.exit(2)
if inpv >= 0.01 or virz: # from GPa to atomic
    resu = inpv/2.94210190066201/10000
    mtpr = int(math.log10(resu/2))
    resus = str(resu)
    dotpos = resus.index(".")
    dotpos = min(nsig, dotpos)
    if mtpr < 0:
        fstring = '{:.' + str(nsig - mtpr) + 'f}'
        print(fstring.format(round(resu,nsig - mtpr)))
    else: # probably never
        print(int(10**(mtpr-1)*round(resu/10**(mtpr-1), nsig - dotpos)))
else: # from atomic to GPa
    resu = inpv*2.94210190066201*10000
    resus = str(resu)
    if resu < 1:
        fresus = resus.replace("0.","")
        flresus = len(fresus)
        while fresus[0] == "0":
            fresus = fresus[1:]
        prezeros = flresus - len(fresus)
        papil = 1 + prezeros
        mtpr = 0
    else:
        papil = 0
        mtpr = int(math.log10(resu/2))
    dotpos = resus.index(".") - papil
    if dotpos < nsig:
        fstring = '{:' + str(max(dotpos,0)) + '.' + str(nsig - dotpos) + 'f}'
        print(fstring.format(round(resu, nsig - dotpos)))
    else:
        print(int(10**mtpr*round(resu/10**mtpr, nsig - 1)))

