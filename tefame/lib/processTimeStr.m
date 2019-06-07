function s = processTimeStr(tini)
% processTimeStr: Retorna un string con el tiempo parseado en segundos o
% minutos segun corresponda

tot = etime(clock, tini);
min = floor(tot/60);
seg = floor(tot - 60*min);
mil = tot - 60*min - seg;

s = '';
if min ~= 0
    s = strcat(s, sprintf('%d minutos', min));
end
if seg ~= 0
    if ~isempty(s)
        s = strcat(s, sprintf(' %d segundos', seg));
    else
        s = strcat(s, sprintf('%d segundos', seg));
    end
if mil ~= 0
end
end

end