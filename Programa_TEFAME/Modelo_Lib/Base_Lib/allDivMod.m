function t = allDivMod(y, r)
%ALLDIVMOD Function returns true if all elements in array y are divisible
%by r
t = true;
for i=1:length(y)
    if mod(y(i), r) ~= 0
        t = false;
        return;
    end
end
end