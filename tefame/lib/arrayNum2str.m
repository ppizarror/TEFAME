function textCell = arrayNum2str(a, num)
% arrayNum2str: Function that transform the array of number to a
% array of cell elements that is used to print the array in string format
% = [ a1 a2 a3 ... ]

if ~exist('num', 'var')
    num = length(a);
end

% We create the array of cell that will keep the numbers in str format
textCell = cell(1, 2*num+1);
textCell(1) = {'['};

for i = 1:num  
    if abs(a(i)) < 1e-10
        if i < num
            textCell(2*i) = {pad(num2str(0), 10)};
        else
            textCell(2*i) = {num2str(0)};
        end
    else
        if i < num
            if abs(a(i)) < 1e-4
                textCell(2*i) = {pad(num2str(a(i), '%.05f'), 10)};
            else
                textCell(2*i) = {pad(num2str(a(i), '%.04f'), 10)};
            end
        else
            if abs(a(i)) < 1e-4
                textCell(2*i) = {num2str(a(i), '%.05f')};
            else
                textCell(2*i) = {num2str(a(i), '%.04f')};
            end
        end
    end
    textCell(1+2*i) = {' '};    
end % for i

textCell(2*num+1) = {']'};

end % arrayNum2str function