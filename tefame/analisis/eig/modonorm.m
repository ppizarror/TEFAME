function [phi] = modonorm(phi, M, opt)
% modonorm: Normaliza formas modales
%
% w = modonorm(phi,M,opt)

if nargin < 2
    opt = 1;
end

if nargin < 3 || isempty(opt)
    opt = 2;
end

% Para caso general
if opt == 0
end

% Normaliza con primera linea
if opt == 1
    aux = (phi(1, :));
    if min(abs(aux)) <= eps
        opt = 3;
        warning('No se puede dividir debido a un valor nulo, se usa opt=3');
    else
        phi = phi * diag(1./aux);
    end
end

if opt == 2
    Mn = sqrt(diag(conj(phi)'*M*phi));
    phi = phi * diag(Mn^-1);
end

if opt == 3
    aux = max(phi);
    phi = phi * diag(1./aux);
end

% Simplemente normaliza por el valor absoluto
if opt == 4
    phi = phi ./ norm(phi);
end

end