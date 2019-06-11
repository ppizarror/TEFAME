function [depl, vel, accl, t] = Newmark(M, K, C, P, Fs, acceleration, do, vo)
% NEWMARK'S METHOD : LINEAR SYSTEM
% Reference : Dynamics of Structures - Anil K. Chopra
%-------------------------------------------------------------------------
% Purpose : Dynamic Response of a system using linear Newmark's Method
% Synopsis :
%       [depl,vel,accl,t] = Newmark(M,K,C,P,acceleration)
%
% Variable Description :
% INPUT :
%       M - Mass Matrix (in modal coordinates)
%       K - Stiffness Matrix (in modal coordinates)
%       C - Damping Matrix (in modal coordinates)
%       P - Force Matrix (in modal coordinates)
%       acceleration - Type of Newmark's Method to be used
%
% OUTPUT :
%        depl - modal displacement's
%        vel - modal velocities
%        accl - modal accelerations
%        t - time values at which integration is done
%--------------------------------------------------------------------------
switch acceleration
    case 'Average'
        gamma = 1 / 2;
        beta = 1 / 4;
    case 'Linear'
        gamma = 1 / 2;
        beta = 1 / 6;
end

% Vector de instantes de tiempo
n = length(P);
dt = 1 / Fs;
t = linspace(0, dt*n, n);

% Constantes usadas en el algoritmo de Newmark
a1 = gamma / (beta * dt);
a2 = 1 / (beta * dt^2);
a3 = 1 / (beta * dt);
a4 = gamma / beta;
a5 = 1 / (2 * beta);
a6 = dt * (gamma / (2 * beta) - 1);

% Calculos Iniciales
depl = zeros(n, 1);
depl(1) = do;
vel = zeros(n, 1);
vel(1) = vo;

accl = zeros(n, 1);
accl(:, 1) = M \ (P(1) - C * vel(1) - K * depl(1));

K_eff = K + a1 * C + a2 * M;

a = a3 * M + a4 * C;
b = a5 * M + a6 * C;

% Condicion de estabilidad
% T = e(K/M) ;
% if dt/T<1/sqrt(gamma-2*beta)*1/(pi*sqrt(2))

% Tme step starts
for i = 1:n - 1
    delP = P(i+1) - P(i) + a * vel(i) + b * accl(i);
    
    delDepl = K_eff \ delP;
    delVel = a1 * delDepl - a4 * vel(i) + a6 * accl(i);
    delAccl = a2 * delDepl - a3 * vel(i) - a5 * accl(i);
    
    depl(i+1) = depl(i) + delDepl;
    vel(i+1) = vel(i) + delVel;
    accl(i+1) = accl(i) + delAccl;
end % for i

end