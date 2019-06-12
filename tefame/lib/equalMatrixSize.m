function y = equalMatrixSize(m, n)
% equalMatrixSize: Chequea que dos matrices tengan el mismo largo

ms = size(m);
ns = size(n);
y = ms(1) == ns(1) && ms(2) == ns(2);

end % equalMatrixSize function