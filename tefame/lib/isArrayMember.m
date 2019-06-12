function y = isArrayMember(a, b)
% isArrayMember: Check if b exists in array a

y = find(a==b) ~= 0;

end % isArrayMember function