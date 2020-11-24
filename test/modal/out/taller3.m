clc;
clear all; %#ok<*CLALL>
close all;
fs = 200;
n = fs*120;
y = randn(1, n);
t = 0:1/fs:(n-1)/fs;

figure();
hold on;
plot(t, y);
grid on;
grid minor;

%%
figure();
y = detrend(y);
hist(y, 100);