function y = equalMatrixSize(m, n)
%EQUALMATRIXSIZE Chequea que dos matrices tengan el mismo tamaño
ms = size(m);
ns = size(n);
y = ms(1) == ns(1) && ms(2) == ns(2);
end