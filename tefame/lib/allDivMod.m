function t = allDivMod(y, r)
% allDivMod: Retorna verdadero si todos los elementos de y son divisibles
% por r

t = true;
for i=1:length(y)
    if mod(y(i), r) ~= 0
        t = false;
        return;
    end
end % for i

end % allDivMod function