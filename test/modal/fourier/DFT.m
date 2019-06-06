function [f, fftt, ts] = DFT(FS, senal)
% DISCRETE FOURIER TRANSFORM
% -------------------------------------------------------------------
% DFT: Determina la Transformada discreta de Fourier de una senal
%      discreta
%
%   f = Vector de frecuencias
%   fftt = Fast Fourier Transform de la senal
% 	ts = Vector de tiempo de la senal
% -------------------------------------------------------------------

% Intervalo de tiempo
dt = 1 / FS;

% Tamano de la senal
N = length(senal);
L = dt * N;

% Numero de elementos de la senal
Nfft = 2^nextpow2(N);

% Vector de frecuencia
df = FS / Nfft;
fn = FS / 2; % Nyquist cut-off frequency
f = -fn:df:fn - df;

% Vector de tiempo
ts = 0:dt:L - dt;
ts = ts';

% FAST FOURIER TRANSFORM
fftt = fft(senal, Nfft) ./ Nfft;

end