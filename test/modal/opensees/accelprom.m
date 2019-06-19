function [v, vp, v2p] = accelprom(a, omega, beta, deltat)
K = 4 / (deltat^2) + 4 * beta * omega / deltat + omega^2;
v = zeros(1, length(a));
vp = zeros(1, length(a));
v2p = zeros(1, length(a));
for j = 2:length(a)
    P = -a(j) + v2p(j-1) + 4 * vp(j-1) / deltat + 4 * v(j-1) / (deltat^2) + 2 * beta * omega * (2 * v(j-1) / deltat + vp(j-1));
    v(j) = P / K;
    vp(j) = 2 * (v(j) - v(j-1)) / deltat - vp(j-1);
    v2p(j) = -a(j) - 2 * beta * omega * vp(j) - (omega^2) * v(j);
end
end