% Disipadores modelo

%% DEFINICION DE PROPIEDADES

% Propiedades disipadores viscosos
Cd = 1.1;
alpha = 0.325;

% Propiedades disipadores friccionales
Fy = 0.51;

% Propiedades disipadores triangulares
k1 = 0.80;
k2 = 0.60;

% Tipo disipador
tipoDisipador = 'viscoso'; % viscoso, friccional, triangular

%% IMPLEMENTA LOS DISIPADORES
if strcmp(tipoDisipador, 'viscoso') % DISIPADOR VISCOSO 2D
    disipadores{1} = DisipadorViscoso2D('DV04-15', nodos{97}, nodos{102}, Cd, alpha); %#ok<SUSENS>
    disipadores{2} = DisipadorViscoso2D('DV14-25', nodos{101}, nodos{106}, Cd, alpha);
    disipadores{3} = DisipadorViscoso2D('DV24-35', nodos{105}, nodos{110}, Cd, alpha);
    disipadores{4} = DisipadorViscoso2D('DV34-44', nodos{109}, nodos{114}, Cd, alpha);
    disipadores{5} = DisipadorViscoso2D('DV43-52', nodos{113}, nodos{118}, Cd, alpha);
    disipadores{6} = DisipadorViscoso2D('DV51-59', nodos{117}, nodos{122}, Cd, alpha);
    disipadores{7} = DisipadorViscoso2D('DV58-65', nodos{121}, nodos{126}, Cd, alpha);
    disipadores{8} = DisipadorViscoso2D('DV64-70', nodos{100}, nodos{103}, Cd, alpha);
    disipadores{9} = DisipadorViscoso2D('DV69-92', nodos{104}, nodos{107}, Cd, alpha);
    disipadores{10} = DisipadorViscoso2D('DV91-102', nodos{108}, nodos{111}, Cd, alpha);
    disipadores{11} = DisipadorViscoso2D('DV101-112', nodos{112}, nodos{115}, Cd, alpha);
    disipadores{12} = DisipadorViscoso2D('DV111-122', nodos{116}, nodos{119}, Cd, alpha);
    disipadores{13} = DisipadorViscoso2D('DV121-132', nodos{120}, nodos{123}, Cd, alpha);
    disipadores{14} = DisipadorViscoso2D('DV131-142', nodos{124}, nodos{127}, Cd, alpha);
    
elseif strcmp(tipoDisipador, 'friccional') % DISIPADOR FRICCIONAL PURO 2D
    disipadores{1} = DisipadorFriccionalPuro2D('DF04-15', nodos{97}, nodos{102}, Fy);
    disipadores{2} = DisipadorFriccionalPuro2D('DF14-25', nodos{101}, nodos{106}, Fy);
    disipadores{3} = DisipadorFriccionalPuro2D('DF24-35', nodos{105}, nodos{110}, Fy);
    disipadores{4} = DisipadorFriccionalPuro2D('DF34-44', nodos{109}, nodos{114}, Fy);
    disipadores{5} = DisipadorFriccionalPuro2D('DF43-52', nodos{113}, nodos{118}, Fy);
    disipadores{6} = DisipadorFriccionalPuro2D('DF51-59', nodos{117}, nodos{122}, Fy);
    disipadores{7} = DisipadorFriccionalPuro2D('DF58-65', nodos{121}, nodos{126}, Fy);
    disipadores{8} = DisipadorFriccionalPuro2D('DF64-70', nodos{100}, nodos{103}, Fy);
    disipadores{9} = DisipadorFriccionalPuro2D('DF69-92', nodos{104}, nodos{107}, Fy);
    disipadores{10} = DisipadorFriccionalPuro2D('DF91-102', nodos{108}, nodos{111}, Fy);
    disipadores{11} = DisipadorFriccionalPuro2D('DF101-112', nodos{112}, nodos{115}, Fy);
    disipadores{12} = DisipadorFriccionalPuro2D('DF111-122', nodos{116}, nodos{119}, Fy);
    disipadores{13} = DisipadorFriccionalPuro2D('DF121-132', nodos{120}, nodos{123}, Fy);
    disipadores{14} = DisipadorFriccionalPuro2D('DF131-142', nodos{124}, nodos{127}, Fy);
    
elseif strcmp(tipoDisipador, 'triangular') % DISIPADOR TRIANGULAR 2D
    disipadores{1} = DisipadorTriangular2D('DT04-15', nodos{97}, nodos{102}, k1, k2);
    disipadores{2} = DisipadorTriangular2D('DT14-25', nodos{101}, nodos{106}, k1, k2);
    disipadores{3} = DisipadorTriangular2D('DT24-35', nodos{105}, nodos{110}, k1, k2);
    disipadores{4} = DisipadorTriangular2D('DT34-44', nodos{109}, nodos{114}, k1, k2);
    disipadores{5} = DisipadorTriangular2D('DT43-52', nodos{113}, nodos{118}, k1, k2);
    disipadores{6} = DisipadorTriangular2D('DT51-59', nodos{117}, nodos{122}, k1, k2);
    disipadores{7} = DisipadorTriangular2D('DT58-65', nodos{121}, nodos{126}, k1, k2);
    disipadores{8} = DisipadorTriangular2D('DT64-70', nodos{100}, nodos{103}, k1, k2);
    disipadores{9} = DisipadorTriangular2D('DT69-92', nodos{104}, nodos{107}, k1, k2);
    disipadores{10} = DisipadorTriangular2D('DT91-102', nodos{108}, nodos{111}, k1, k2);
    disipadores{11} = DisipadorTriangular2D('DT101-112', nodos{112}, nodos{115}, k1, k2);
    disipadores{12} = DisipadorTriangular2D('DT111-122', nodos{116}, nodos{119}, k1, k2);
    disipadores{13} = DisipadorTriangular2D('DT121-132', nodos{120}, nodos{123}, k1, k2);
    disipadores{14} = DisipadorTriangular2D('DT131-142', nodos{124}, nodos{127}, k1, k2);
    
else
    error('Tipo disipador %s invalido, valores: viscoso,friccional,triangular', tipoDisipador);
end

%% OTROS
clear tipoDisipador;