function i = minArrayIndex(A)
% minArrayIndex: Retorna el indice asociado al minimo valor del vector A
% (1xN)

i = find(A == min(A(:)));

end % minArrayIndex function