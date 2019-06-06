function [d, v, a, f, Pw, FRF] = respfrec(m, T, beta, P, FS)
% respfrec: Genera respuesta de oscilador en el espacio de la frecuencia
%
% [d, v , a, P, Pw, FRF] = respfrec(m, T, beta, P, FS)
%
% Parametros de entrada:
% 	beta    Amortiguamiento critico
% 	T       Periodo del oscilador en segundos
% 	P       Senal de entrada
% 	m       Masa del oscilador
% 	FS      Frecuencia de muestreo de la señal
%  	d       Respuesta de desplazamiento
%  	Pw      FFT de P

%% Datos de entrada
% Longitud vector de entrada
nP = length(P);

% Frecuencia natural y rigidez
fo = 1 / T;
k = m * (2 * pi / T)^2; % REVISAR

%% Señal en el espacio de la frecuencia
Pw = fft(P);

%% Definicion de simetria de FRF
if ~any(any(imag(P) ~= 0))
    if rem(nP, 2)
        select = (1:(nP + 1) / 2)';
    else
        select = (1:nP / 2 + 1)';
    end
else
    select = (1:nP)';
end
f = (select - 1) * FS / nP;

%% Funcion de respuesta
FRF = zeros(nP, 1);
fratio = f / fo;
unos = ones(length(f), 1);

% Para una senal compleja
FRF(select) = (unos / k) ./ (unos - (fratio).^2 + ...
    (1i * 2 * beta) .* (fratio));
%% Correccion para doble sidedspectra
if ~any(any(imag(P) ~= 0)) % Si no es necesario corregir para el otro lado
    % Correccion de frecuencia
    f = [f; zeros(nP-length(f), 1)];
    if rem(nP, 2)
        FRF(select(end)+1:end) = conj(FRF(((nP + 1) / 2):-1:2));
        % Simetria completa
        f(select(end)+1:end) = -f(((nP + 1) / 2):-1:2);
    else
        FRF(select(end)+1:end) = conj(FRF(nP/2:-1:2)); % Par
        f(select(end)+1:end) = f((nP / 2):-1:2);
    end
end

d = real(ifft(FRF.*Pw));
v = real(ifft((1i * f * 2 * pi).*FRF.*Pw));
a = real(ifft((1i * f * 2 * pi).^2.*FRF.*Pw));

end