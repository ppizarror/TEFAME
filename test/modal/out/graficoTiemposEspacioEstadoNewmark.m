modos = [50, 75, 100, 125, 150, 175, 200, 225, 250];
newmark = [31.499, 32.145, 37.186, 40.098, 44.068, 46.439, 50.527, 53.797, 58.290];
ee = [0,0,0,0,0,0,0,54.054];

for i=1:55
    if y1(i) == 0
        ss(i) = ss(i-1);
    else
        ss(i) = abs((x0(i)-x1(i)))/x0(i);
    end
end
figure();
plot(ss, y1, '*-', 'Color', [0, 0, 0], 'linewidth', 1);
grid on;
xlabel('Error absoluto (-)');
ylabel('Altura (m)');
xlim([0, 0.05]);
title('Comparacion Envolvente de Aceleracion');