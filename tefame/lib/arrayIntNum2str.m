function textCell = arrayIntNum2str(a, num)
% arrayIntNum2str: function that transform the array of number to a
% array of cell elements that is used to print the array in string format
% = [ a1 a2 a3 ... ], numbers are integer

if ~exist('num', 'var')
    num = length(a);
end

% We create the array of cell that will keep the numbers in str format
textCell = cell(1, 2*num+1);
textCell(1) = {'['};

for i = 1:num
    if i < num
        textCell(2*i) = {pad(num2str(a(i), '%d'), 10*(i < num))};
    else
        textCell(2*i) = {num2str(a(i), '%d')};
    end
    textCell(1+2*i) = {' '};
end % for i

textCell(2*num+1) = {']'};
end