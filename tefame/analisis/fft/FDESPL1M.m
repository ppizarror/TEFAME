function v = FDESPL1M(d, t, N, x)
% FDESPL1M: Respuesta de un modo
v = zeros(1, length(t));
omega = x(:, 1);
beta = x(:, 2);
theta = x(:, 3);
rho = x(:, 4);
for i = 1:N
    v = v + rho(i) * exp(-beta(i)*omega(i)*t') .* sin(omega(i)*sqrt(1+beta(i).^2)*t'-theta(i));
end % for i
v = v' - d;
end