function textCell = arrayStr2str(a, num)
% textCell = array2str(a,num) function that transform the array of string to a
% array of cell elements that is used to print the array in string format
% = [ a1 a2 a3 ... ]

if ~exist('num', 'var')
    num = length(a);
end

% We create the array of cell that will keep the numbers in str format
textCell = cell(1, 2*num+1);
textCell(1) = {'['};

for i = 1:num
    textCell(2*i) = {a(i)};
    textCell(1+2*i) = {' '};
end % for i

textCell(2*num+1) = {']'};
end