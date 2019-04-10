function y = isArrayEqual(x, a)
%ISARRAYEQUAL Check if array x is equal to number a
y = false;
for i=1:length(x)
    if x(i) ~= a
        return;
    end
end
y = true;
end