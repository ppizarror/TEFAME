:: Crea los graficos del test membrana 2 muro simplemente apoyado
@echo off

echo GEOMETRIA
python graficarTensiones.py Muro::largo::simplemente::apoyado out/Test_Membrana2.txt geom out/Test_Membrana2_GEOMETRIA.png cm cm

echo SIGMA X
python graficarTensiones.py Muro::largo::simplemente::apoyado out/Test_Membrana2.txt sigmax out/Test_Membrana2_SIGMAX.png cm kgf/cm^2

echo SIGMA Y
python graficarTensiones.py Muro::largo::simplemente::apoyado out/Test_Membrana2.txt sigmay out/Test_Membrana2_SIGMAY.png cm kgf/cm^2

echo SIGMA XY
python graficarTensiones.py Muro::largo::simplemente::apoyado out/Test_Membrana2.txt sigmaxy out/Test_Membrana2_SIGMAXY.png cm kgf/cm^2

echo DESPLAZAMIENTO X
python graficarTensiones.py Muro::largo::simplemente::apoyado out/Test_Membrana2.txt desplx out/Test_Membrana2_DESPLX.png cm cm

echo DESPLAZAMIENTO y
python graficarTensiones.py Muro::largo::simplemente::apoyado out/Test_Membrana2.txt desply out/Test_Membrana2_DESPLY.png cm cm

@echo on