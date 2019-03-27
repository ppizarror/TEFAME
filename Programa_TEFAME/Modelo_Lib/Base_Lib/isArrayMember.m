function y = isArrayMember(a, b)
%ISARRAYMEMBER Check if b exists in array a
y = find(a==b) ~= 0;
end