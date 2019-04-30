
%% Elementos Modelo
%  DISIPADORES VISCOSOS

<<<<<<< HEAD
disipadoresViscosos{1} = DisipadorViscoso2D('DV04-15', nodos{04}, nodos{15}, Ceq, Keq); %#ok<SUSENS>
disipadoresViscosos{2} = DisipadorViscoso2D('DV14-25', nodos{14}, nodos{25}, Ceq, Keq);
disipadoresViscosos{3} = DisipadorViscoso2D('DV24-35', nodos{24}, nodos{35}, Ceq, Keq);
disipadoresViscosos{4} = DisipadorViscoso2D('DV34-44', nodos{34}, nodos{44}, Ceq, Keq);
disipadoresViscosos{5} = DisipadorViscoso2D('DV43-52', nodos{43}, nodos{52}, Ceq, Keq);
disipadoresViscosos{6} = DisipadorViscoso2D('DV51-59', nodos{51}, nodos{59}, Ceq, Keq);
disipadoresViscosos{7} = DisipadorViscoso2D('DV58-65', nodos{58}, nodos{65}, Ceq, Keq);
disipadoresViscosos{8} = DisipadorViscoso2D('DV64-70', nodos{64}, nodos{70}, Ceq, Keq);
disipadoresViscosos{9} = DisipadorViscoso2D('DV69-92', nodos{69}, nodos{74}, Ceq, Keq);
disipadoresViscosos{10} = DisipadorViscoso2D('DV91-102', nodos{73}, nodos{78}, Ceq, Keq);
disipadoresViscosos{11} = DisipadorViscoso2D('DV101-112', nodos{77}, nodos{82}, Ceq, Keq);
disipadoresViscosos{12} = DisipadorViscoso2D('DV111-122', nodos{81}, nodos{86}, Ceq, Keq);
disipadoresViscosos{13} = DisipadorViscoso2D('DV121-132', nodos{85}, nodos{90}, Ceq, Keq);
disipadoresViscosos{14} = DisipadorViscoso2D('DV131-142', nodos{89}, nodos{94}, Ceq, Keq);
disipadoresViscosos{15} = DisipadorViscoso2D('DV141-152', nodos{93}, nodos{98}, Ceq, Keq);
disipadoresViscosos{16} = DisipadorViscoso2D('DV151-162', nodos{97}, nodos{102}, Ceq, Keq);
disipadoresViscosos{17} = DisipadorViscoso2D('DV161-172', nodos{101}, nodos{106}, Ceq, Keq);
disipadoresViscosos{18} = DisipadorViscoso2D('DV171-182', nodos{105}, nodos{110}, Ceq, Keq);
disipadoresViscosos{19} = DisipadorViscoso2D('DV181-192', nodos{109}, nodos{114}, Ceq, Keq);
disipadoresViscosos{20} = DisipadorViscoso2D('DV191-202', nodos{113}, nodos{118}, Ceq, Keq);
disipadoresViscosos{21} = DisipadorViscoso2D('DV201-212', nodos{117}, nodos{122}, Ceq, Keq);
disipadoresViscosos{22} = DisipadorViscoso2D('DV211-222', nodos{121}, nodos{126}, Ceq, Keq);
disipadoresViscosos{23} = DisipadorViscoso2D('DV221-232', nodos{125}, nodos{130}, Ceq, Keq);
disipadoresViscosos{24} = DisipadorViscoso2D('DV231-242', nodos{129}, nodos{134}, Ceq, Keq);
disipadoresViscosos{25} = DisipadorViscoso2D('DV241-252', nodos{133}, nodos{138}, Ceq, Keq);
=======
disipadoresViscosos{1} = DisipadorViscoso2D('DV04-15', nodos{04}, nodos{15}, Cd, alpha);
disipadoresViscosos{2} = DisipadorViscoso2D('DV14-25', nodos{14}, nodos{25}, Cd, alpha);
disipadoresViscosos{3} = DisipadorViscoso2D('DV24-35', nodos{24}, nodos{35}, Cd, alpha);
disipadoresViscosos{4} = DisipadorViscoso2D('DV34-44', nodos{34}, nodos{44}, Cd, alpha);
disipadoresViscosos{5} = DisipadorViscoso2D('DV43-52', nodos{43}, nodos{52}, Cd, alpha);
disipadoresViscosos{6} = DisipadorViscoso2D('DV51-59', nodos{51}, nodos{59}, Cd, alpha);
disipadoresViscosos{7} = DisipadorViscoso2D('DV58-65', nodos{58}, nodos{65}, Cd, alpha);
disipadoresViscosos{8} = DisipadorViscoso2D('DV64-70', nodos{64}, nodos{70}, Cd, alpha);
disipadoresViscosos{9} = DisipadorViscoso2D('DV69-92', nodos{69}, nodos{74}, Cd, alpha);
disipadoresViscosos{10} = DisipadorViscoso2D('DV91-102', nodos{73}, nodos{78}, Cd, alpha);
disipadoresViscosos{11} = DisipadorViscoso2D('DV101-112', nodos{77}, nodos{82}, Cd, alpha);
disipadoresViscosos{12} = DisipadorViscoso2D('DV111-122', nodos{81}, nodos{86}, Cd, alpha);
disipadoresViscosos{13} = DisipadorViscoso2D('DV121-132', nodos{85}, nodos{90}, Cd, alpha);
disipadoresViscosos{14} = DisipadorViscoso2D('DV131-142', nodos{89}, nodos{94}, Cd, alpha);
disipadoresViscosos{15} = DisipadorViscoso2D('DV141-152', nodos{93}, nodos{98}, Cd, alpha);
disipadoresViscosos{16} = DisipadorViscoso2D('DV151-162', nodos{97}, nodos{102}, Cd, alpha);
disipadoresViscosos{17} = DisipadorViscoso2D('DV161-172', nodos{101}, nodos{106}, Cd, alpha);
disipadoresViscosos{18} = DisipadorViscoso2D('DV171-182', nodos{105}, nodos{110}, Cd, alpha);
disipadoresViscosos{19} = DisipadorViscoso2D('DV181-192', nodos{109}, nodos{114}, Cd, alpha);
disipadoresViscosos{20} = DisipadorViscoso2D('DV191-202', nodos{113}, nodos{118}, Cd, alpha);
disipadoresViscosos{21} = DisipadorViscoso2D('DV201-212', nodos{117}, nodos{122}, Cd, alpha);
disipadoresViscosos{22} = DisipadorViscoso2D('DV211-222', nodos{121}, nodos{126}, Cd, alpha);
disipadoresViscosos{23} = DisipadorViscoso2D('DV221-232', nodos{125}, nodos{130}, Cd, alpha);
disipadoresViscosos{24} = DisipadorViscoso2D('DV231-242', nodos{129}, nodos{134}, Cd, alpha);
disipadoresViscosos{25} = DisipadorViscoso2D('DV241-252', nodos{133}, nodos{138}, Cd, alpha);



















>>>>>>> 8795b4abbedb0e0013ecbdef463adf8edac3e379
