function s = mat2strchain(m)
%MAT2STRCHAIN: Convierte una matrix a una cadena de strings
s = '|';
lasts = num2str(round(m(1, 1), 3));
lastc = 1;
z = size(m);
if z(1) == 1 && z(2) == 1
    s = strcat(s, strcat(num2str(m(1)), '|'));
end
for i = 1:z(1)
    for j = 1:z(2)
        if i == 1 && j == 1
            continue;
        end
        ss = num2str(round(m(i, j), 3));
        if ~strcmp(ss, lasts) || (i == z(1) && j == z(2))
            if strcmp(ss, lasts)
                lastc = lastc + 1;
            end
            s = strcat(strcat(s, strcat(strcat(num2str(lastc), '@'), lasts)), '|');
            lastc = 1;
            if ~strcmp(ss, lasts) && (i == z(1) && j == z(2))
                s = strcat(strcat(s, strcat('1@', ss)), '|');
            end
            lasts = ss;
        else
            lastc = lastc + 1;
        end
    end
end
s = strrep(s, '1@', '');
end