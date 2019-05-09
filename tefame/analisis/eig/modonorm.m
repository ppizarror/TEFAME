function w = modonorm(v)
% modonorm: Normaliza un modo

vn = norm(v);
w = v ./ vn;

end