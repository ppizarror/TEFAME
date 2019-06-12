function y = padFillNum(x, a)
% padFillNum: Fill a number respect to <a>

y = pad(num2str(x), floor(log10(a))+1, 'left', '0');

end % padFillNum function