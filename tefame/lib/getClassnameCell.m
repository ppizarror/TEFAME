function c = getClassnameCell(a)
% getClassnameCell: Returns cell containing the classes in cell and the
% number of elements each
%
% c = getClassnameCell(a)

% Create map
c = containers.Map;
k = {};
ki = 0;

for i=1:length(a)
    
    % Get classname
    cn = class(a{i});
    
    % Check if cn in k, if not then append
    bj = 0;
    for j = 1:ki
        if strcmp(k{j}, cn)
            bj = j;
            break;
        end
    end % for j
    if bj ~= 0
        c(cn) = c(cn) + 1;
    else
        ki = ki + 1;
        k{ki} = cn; %#ok<AGROW>
        c(cn) = 1;
    end
        
end % for i

end