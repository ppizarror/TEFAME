function c = colorFactor(c, factor)
% colorFactor: Multiplica un color por un factor.

c = c .* factor;
for i=1:3
    c(i) = max(0, min(1, c(i)));
end % for i

end