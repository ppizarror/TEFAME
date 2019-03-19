"""
Renombra los elementos del modelo
"""

fl = open('Modelo_DinamicaAvanzadaElementos.m')

# Guarda las lineas en una matriz
d = []
elem = 1
nl = 0 # Numero de linea
for i in fl:
    nl += 1
    j = i # Copia el string
    nj = ''
    if not ('elementos' in j) or nl <= 6 :
        d.append(j)
        continue

    for k in range(len(j)): # Recorre el string
        if j[k] == '{':
            nj += j[0:k+1] + str(elem)
        if j[k] == '}':
            nj += j[k:len(j)]
            break
    elem += 1
    d.append(nj)
fl.close()

fln = open('Modelo_DinamicaAvanzadaElementos2.m', 'w')
for i in d:
    fln.write(i)
fln.close()
