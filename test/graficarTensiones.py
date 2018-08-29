# coding=utf-8
"""
Grafica las tensiones a partir de un archivo OUTPUT
Autor: Pablo Pizarro @ppizarror
"""

# Importacion de librerias
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.mlab import griddata
import sys

# Definicion de constantes
ALPHACON = 1.0
PLOT_DIM_X_ADD = 0.2
PLOT_DIM_Y_ADD = 0.2
PLOT_DIM_SIZE = 1000

# Si no tiene argumentos imprime la ayuda
if len(sys.argv) == 2:
    print('uso: graficarTensiones Titulo Archivo.txt TIPO output.png UNIDAD COLORBARLBL X1,Y1,X2,Y2,N X1,Y1....')
    print('en donde TIPO: geom,sigmax,sigmay,sigmaxy,desplx,desply y la UNIDAD es aquello que va en las etiquetas')

# Carga el archivo a partir de la linea de comandos
if len(sys.argv) < 7:
    exit('Argumentos no son correctos')

titulo = str(sys.argv[1]).strip().replace('::', ' ')
archivo = sys.argv[2]
modo = str(sys.argv[3]).lower()
output = str(sys.argv[4])
unidad = str(sys.argv[5])
unidadclb = str(sys.argv[6])

areas = []
for k in range(7, len(sys.argv)):
    u = sys.argv[k].strip().split(',')
    if len(u) != 5:
        exit('Recuadro no valido @' + sys.argv[k])
    x1 = float(u[0])
    y1 = float(u[1])
    x2 = float(u[2])
    y2 = float(u[3])
    n = int(u[4])

    # Realiza otras verificaciones
    if x1 >= x2 or y1 >= y2:
        exit('(x1,y1) debe ser menor a (x2,y2) para ' + sys.argv[k])
    if n <= 1:
        exit('Numero de particiones de recuadro debe ser mayor a 1 para ' + sys.argv[k])

    # Agrega el punto
    areas.append([x1, y1, x2, y2, n])

if modo not in ['sigmax', 'sigmay', 'sigmaxy', 'geom', 'desplx', 'desply']:
    exit('Modo de dibujo no es correcto ({0}), valores correctos: \
    geom,sigmax,sigmay,sigmaxy,desplx,desply'.format(modo))

"""
Lee el archivo y obtiene la lista completa de tensiones
"""
f = open(archivo)
data = []
obt = False
dx = 0
dy = 0
for i in f:
    if 'Tensiones' in i:
        obt = True
        dx = 0
        dy = 0
        continue
    if 'Membrana' in i:
        obt = False
        continue

    if obt:
        j = i.strip().split('\t')
        for k in range(len(j)):
            # noinspection PyTypeChecker
            j[k] = float(j[k])
        dx += j[0]
        dy += j[1]

        # Agrega los datos a la lista
        data.append(j)
f.close()

"""
Modo geometrico
"""
mod_geom = False

"""
Crea las listas de tensiones y posicion (x,y)
"""
p = -1
plt_title = ''
if modo == 'sigmax':
    p = 4
    plt_title = r'$\sigma_x$ ' + titulo
elif modo == 'sigmay':
    p = 5
    plt_title = r'$\sigma_y$ ' + titulo
elif modo == 'sigmaxy':
    p = 6
    plt_title = r'$\sigma_{xy}$ ' + titulo
elif modo == 'desplx':
    p = 7
    plt_title = r'$\epsilon_{x}$ ' + titulo
elif modo == 'desply':
    p = 8
    plt_title = r'$\epsilon_{y}$ ' + titulo
else:
    p = 4  # Solo grafica la geometria, el resto no importa
    mod_geom = True
    plt_title = 'Geometria ' + titulo

x = []
y = []
xy = []
z = []

# Listas solo geometricas
gx = []
gy = []

# Listas de restricciones, solo geometrico
rgx = []
rgy = []

"""
Va por cada recuadro y agrega los nan
"""
for ar in areas:
    x1 = ar[0]
    y1 = ar[1]
    x2 = ar[2]
    y2 = ar[3]
    n = ar[4]

    _dx = abs(x2 - x1) / (n + 1)
    _dy = abs(y2 - y1) / (n + 1)

    for j in range(0, n + 2):
        for i in range(0, n + 2):
            nx = x1 + _dx * i
            ny = y1 + _dy * j
            nxy = (nx, ny)
            if nxy in xy:
                continue
            xy.append(nxy)
            x.append(nx)
            y.append(ny)
            z.append(np.nan)

            # Agrega solo las geometrias
            rgx.append(nx)
            rgy.append(ny)

"""
Agrega los datos obtenidos desde el archivo
"""
for r in data:
    nx = float(r[0])
    ny = float(r[1])
    nxy = (nx, ny)
    if nxy in xy:
        continue
    xy.append(nxy)
    x.append(nx)
    y.append(ny)
    z.append(float(r[p]))

    # Agrega solo las geometrias
    gx.append(nx)
    gy.append(ny)

"""
Obtiene las dimensiones a interpolar
"""
dx = abs(float(max(x)) - float(min(x)))
dy = abs(float(max(y)) - float(min(y)))

minx = float(min(x)) - dx * PLOT_DIM_X_ADD
maxx = float(max(x)) + dx * PLOT_DIM_X_ADD

miny = float(min(y)) - dy * PLOT_DIM_Y_ADD
maxy = float(max(y)) + dy * PLOT_DIM_Y_ADD

numcols = PLOT_DIM_SIZE
numrows = int(PLOT_DIM_SIZE * (dy / dx))

"""
Crea el grafico
"""
fig = plt.figure(figsize=(10, 10 * dy / dx))
plt.title(plt_title)
plt.xlabel('x ({0})'.format(unidad))
plt.ylabel('y ({0})'.format(unidad))

"""
Modo normal de tensiones
"""
if not mod_geom:
    """
    Interpola los datos y genera los graficos
    """
    xi = np.linspace(minx, maxx, numcols)
    yi = np.linspace(miny, maxy, numrows)
    xi, yi = np.meshgrid(xi, yi)

    # noinspection PyTypeChecker,PyArgumentList,PyArgumentEqualDefault
    zi = griddata(x, y, z, xi, yi, interp='linear')  # Puede ser interpolacion 'linear' o 'nn' (nearest)

    con = plt.contour(xi, yi, zi, 50, alpha=0)

    # noinspection PyUnresolvedReferences
    cs1 = plt.contourf(xi, yi, zi, con.levels, extend='max', alpha=ALPHACON)
    plt.gcf().canvas.draw()
    cbar = plt.colorbar(cs1, pad=0.05)
    cbar.ax.get_yaxis().labelpad = 15
    cbar.ax.set_ylabel(unidadclb, rotation=270)

else:
    """
    Modo geometrico
    """

    plt.plot(gx, gy, 'b.', label='Malla')
    if len(rgx) > 0:
        pass
        plt.plot(rgx, rgy, 'k.', label='Discontinuidad')

    plt.xlim([minx, maxx])
    plt.ylim([miny, maxy])
    plt.legend(loc=1)

# Dibuja el grafico
fig.savefig(output, dpi=500)
