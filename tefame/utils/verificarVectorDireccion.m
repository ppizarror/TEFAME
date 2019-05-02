function y = verificarVectorDireccion(vec, ndg)
%verificarVectorDireccion: Verifica que un vector direccion tenga sentido y
%este bien definido

% Chequea que solo existan 0 o 1
y = true;
nv = length(vec);
for i=1:nv
    if ~ (vec(i) == 0 || vec(i) == 1)
        y = false;
        return;
    end
end % for i

% Chequea el largo
y = y && nv <= ndg;

% Chequea que la direccion no sea nula
y = y && sum(vec) > 0;

end