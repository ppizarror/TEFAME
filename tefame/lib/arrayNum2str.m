function textCell = arrayNum2str(a, num)
% textCell = array2str(a,num) function that transform the array of number to a
% array of cell elements that is used to print the array in string format
% = [ a1 a2 a3 ... ]

% We create the array of cell that will keep the numbers in str format
textCell = cell(1, 2*num+1);
textCell(1) = {'['};

for i = 1:num  
    if abs(a(i)) < 1e-10
        textCell(2*i) = {pad(num2str(0), 10)};
    else
        if abs(a(i)) < 1e-4
            textCell(2*i) = {pad(num2str(a(i), '%.05f'), 10)};
        else
            textCell(2*i) = {pad(num2str(a(i), '%.04f'), 10)};
        end
    end
    textCell(1+2*i) = {' '};    
end % for i

textCell(2*num+1) = {']'};
end