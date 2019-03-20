:: Crea los graficos de la tarea computacional
@echo off

echo GEOMETRIA
python graficarTensiones.py Modelo::Muro out/Modelo_TareaComputacional5.txt geom out/Modelo_TareaComputacional5_GEOMETRIA.png cm cm 250,100,350,350,100 350,200,500,350,50

echo SIGMA X
python graficarTensiones.py Modelo::Muro out/Modelo_TareaComputacional5.txt sigmax out/Modelo_TareaComputacional5_SIGMAX.png cm kgf/cm^2 250,100,350,350,200 350,200,500,350,100

echo SIGMA Y
python graficarTensiones.py Modelo::Muro out/Modelo_TareaComputacional5.txt sigmay out/Modelo_TareaComputacional5_SIGMAY.png cm kgf/cm^2 250,100,350,350,200 350,200,500,350,100

echo SIGMA XY
python graficarTensiones.py Modelo::Muro out/Modelo_TareaComputacional5.txt sigmaxy out/Modelo_TareaComputacional5_SIGMAXY.png cm kgf/cm^2 250,100,350,350,200 350,200,500,350,100

echo DESPLAZAMIENTO X
python graficarTensiones.py Modelo::Muro out/Modelo_TareaComputacional5.txt desplx out/Modelo_TareaComputacional5_DESPLX.png cm cm 250,100,350,350,200 350,200,500,350,100

echo DESPLAZAMIENTO y
python graficarTensiones.py Modelo::Muro out/Modelo_TareaComputacional5.txt desply out/Modelo_TareaComputacional5_DESPLY.png cm cm 250,100,350,350,200 350,200,500,350,100

@echo on