:: Crea los graficos de la tarea computacional
@echo off

echo GEOMETRIA
python graficarTensiones.py Modelo::Muro out/Modelo_TareaComputacional5.txt geom out/Modelo_TareaComputacional5_GEOMETRIA.png cm 250,100,350,350,100 350,200,500,350,50

echo SIGMAX
python graficarTensiones.py Modelo::Muro out/Modelo_TareaComputacional5.txt sigmax out/Modelo_TareaComputacional5_SIGMAX.png cm 250,100,350,350,200 350,200,500,350,100

echo SIGMAY
python graficarTensiones.py Modelo::Muro out/Modelo_TareaComputacional5.txt sigmay out/Modelo_TareaComputacional5_SIGMAY.png cm 250,100,350,350,200 350,200,500,350,100

echo SIGMAXY
python graficarTensiones.py Modelo::Muro out/Modelo_TareaComputacional5.txt sigmaxy out/Modelo_TareaComputacional5_SIGMAXY.png cm 250,100,350,350,200 350,200,500,350,100

@echo on