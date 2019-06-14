% Elementos Modelo

%% DEFINICION DE PROPIEDADES
% Propiedades de la viga
Av = 1 * 0.75; % (m2)
Ev = 923496; % (tonf/m2)
Iv = (0.75 * 1^3) / 12;

% Propiedades de la columna
Ac = 1; % (m2)
Ec = 923496; % (tonf/m2)
Ic = 1 / 12;

% Propiedades de la Fundacion
G = 15295.743; % [tonf/m2]
ro = 1; % [m]
Kr = (32 * (1 - 0.3)) / (7 - 8 * 0.3) * G * ro;
Mr = 10 * 473.567 /9 * 2;

% Densidad del material hormigon
Rhoh = 2.5 / 9.80665; % (ton/m3), se aplica factor carga masa

%% VIGAS
% Piso 1
elementos{1} = VigaColumna2D('V11-12', nodos{11}, nodos{12}, Iv, Ev, Av, Rhoh); %#ok<*SUSENS>
elementos{1}.desactivarGraficoDeformada();
elementos{2} = VigaColumna2D('V12-13', nodos{12}, nodos{13}, Iv, Ev, Av, Rhoh);
elementos{3} = VigaColumna2D('V13-14', nodos{13}, nodos{14}, Iv, Ev, Av, Rhoh);
elementos{4} = VigaColumna2D('V14-15', nodos{14}, nodos{15}, Iv, Ev, Av, Rhoh);
elementos{5} = VigaColumna2D('V15-16', nodos{15}, nodos{16}, Iv, Ev, Av, Rhoh);
elementos{6} = VigaColumna2D('V16-17', nodos{16}, nodos{17}, Iv, Ev, Av, Rhoh);
elementos{7} = VigaColumna2D('V17-18', nodos{17}, nodos{18}, Iv, Ev, Av, Rhoh);
elementos{8} = VigaColumna2D('V18-19', nodos{18}, nodos{19}, Iv, Ev, Av, Rhoh);
elementos{9} = VigaColumna2D('V19-110', nodos{19}, nodos{20}, Iv, Ev, Av, Rhoh);

% Piso 2
elementos{10} = VigaColumna2D('V21-22', nodos{21}, nodos{22}, Iv, Ev, Av, Rhoh);
elementos{11} = VigaColumna2D('V22-23', nodos{22}, nodos{23}, Iv, Ev, Av, Rhoh);
elementos{12} = VigaColumna2D('V23-24', nodos{23}, nodos{24}, Iv, Ev, Av, Rhoh);
elementos{13} = VigaColumna2D('V24-25', nodos{24}, nodos{25}, Iv, Ev, Av, Rhoh);
elementos{14} = VigaColumna2D('V25-26', nodos{25}, nodos{26}, Iv, Ev, Av, Rhoh);
elementos{15} = VigaColumna2D('V26-27', nodos{26}, nodos{27}, Iv, Ev, Av, Rhoh);
elementos{16} = VigaColumna2D('V27-28', nodos{27}, nodos{28}, Iv, Ev, Av, Rhoh);
elementos{17} = VigaColumna2D('V28-29', nodos{28}, nodos{29}, Iv, Ev, Av, Rhoh);
elementos{18} = VigaColumna2D('V29-210', nodos{29}, nodos{30}, Iv, Ev, Av, Rhoh);

% Piso 3
elementos{19} = VigaColumna2D('V31-32', nodos{31}, nodos{32}, Iv, Ev, Av, Rhoh);
elementos{20} = VigaColumna2D('V32-33', nodos{32}, nodos{33}, Iv, Ev, Av, Rhoh);
elementos{21} = VigaColumna2D('V33-34', nodos{33}, nodos{34}, Iv, Ev, Av, Rhoh);
elementos{22} = VigaColumna2D('V34-35', nodos{34}, nodos{35}, Iv, Ev, Av, Rhoh);
elementos{23} = VigaColumna2D('V35-36', nodos{35}, nodos{36}, Iv, Ev, Av, Rhoh);
elementos{24} = VigaColumna2D('V36-37', nodos{36}, nodos{37}, Iv, Ev, Av, Rhoh);
elementos{25} = VigaColumna2D('V37-38', nodos{37}, nodos{38}, Iv, Ev, Av, Rhoh);
elementos{26} = VigaColumna2D('V38-39', nodos{38}, nodos{39}, Iv, Ev, Av, Rhoh);
elementos{27} = VigaColumna2D('V39-310', nodos{39}, nodos{40}, Iv, Ev, Av, Rhoh);

% Piso 4
elementos{28} = VigaColumna2D('V41-42', nodos{41}, nodos{42}, Iv, Ev, Av, Rhoh);
elementos{29} = VigaColumna2D('V42-42', nodos{42}, nodos{43}, Iv, Ev, Av, Rhoh);
elementos{30} = VigaColumna2D('V43-44', nodos{33}, nodos{44}, Iv, Ev, Av, Rhoh);
elementos{31} = VigaColumna2D('V44-45', nodos{44}, nodos{45}, Iv, Ev, Av, Rhoh);
elementos{32} = VigaColumna2D('V45-46', nodos{45}, nodos{46}, Iv, Ev, Av, Rhoh);
elementos{33} = VigaColumna2D('V46-47', nodos{46}, nodos{47}, Iv, Ev, Av, Rhoh);
elementos{34} = VigaColumna2D('V47-48', nodos{47}, nodos{48}, Iv, Ev, Av, Rhoh);
elementos{35} = VigaColumna2D('V48-49', nodos{48}, nodos{49}, Iv, Ev, Av, Rhoh);
elementos{36} = VigaColumna2D('V49-410', nodos{49}, nodos{50}, Iv, Ev, Av, Rhoh);

% Piso 5
elementos{37} = VigaColumna2D('V51-52', nodos{51}, nodos{52}, Iv, Ev, Av, Rhoh);
elementos{38} = VigaColumna2D('V52-53', nodos{52}, nodos{53}, Iv, Ev, Av, Rhoh);
elementos{39} = VigaColumna2D('V53-54', nodos{53}, nodos{54}, Iv, Ev, Av, Rhoh);
elementos{40} = VigaColumna2D('V54-55', nodos{54}, nodos{55}, Iv, Ev, Av, Rhoh);
elementos{41} = VigaColumna2D('V55-56', nodos{55}, nodos{56}, Iv, Ev, Av, Rhoh);
elementos{42} = VigaColumna2D('V56-57', nodos{56}, nodos{57}, Iv, Ev, Av, Rhoh);
elementos{43} = VigaColumna2D('V57-58', nodos{53}, nodos{58}, Iv, Ev, Av, Rhoh);
elementos{44} = VigaColumna2D('V58-59', nodos{58}, nodos{59}, Iv, Ev, Av, Rhoh);
elementos{45} = VigaColumna2D('V59-510', nodos{59}, nodos{60}, Iv, Ev, Av, Rhoh);

%% COLUMNAS
% Piso 0-1
elementos{46} = VigaColumna2D('C01-11', nodos{1}, nodos{11}, Ic, Ec, Ac, Rhoh);
elementos{47} = VigaColumna2D('C02-12', nodos{2}, nodos{12}, Ic, Ec, Ac, Rhoh);
elementos{48} = VigaColumna2D('C03-13', nodos{3}, nodos{13}, Ic, Ec, Ac, Rhoh);
elementos{49} = VigaColumna2D('C04-14', nodos{4}, nodos{14}, Ic, Ec, Ac, Rhoh);
elementos{50} = VigaColumna2D('C05-15', nodos{5}, nodos{15}, Ic, Ec, Ac, Rhoh);
elementos{51} = VigaColumna2D('C06-16', nodos{6}, nodos{16}, Ic, Ec, Ac, Rhoh);
elementos{52} = VigaColumna2D('C07-17', nodos{7}, nodos{17}, Ic, Ec, Ac, Rhoh);
elementos{53} = VigaColumna2D('C08-18', nodos{8}, nodos{18}, Ic, Ec, Ac, Rhoh);
elementos{54} = VigaColumna2D('C09-19', nodos{9}, nodos{19}, Ic, Ec, Ac, Rhoh);
elementos{55} = VigaColumna2D('C010-110', nodos{10}, nodos{20}, Ic, Ec, Ac, Rhoh);

% Piso 1-2
elementos{56} = VigaColumna2D('C11-21', nodos{11}, nodos{21}, Ic, Ec, Ac, Rhoh);
elementos{57} = VigaColumna2D('C12-22', nodos{12}, nodos{22}, Ic, Ec, Ac, Rhoh);
elementos{58} = VigaColumna2D('C13-23', nodos{13}, nodos{23}, Ic, Ec, Ac, Rhoh);
elementos{59} = VigaColumna2D('C14-24', nodos{14}, nodos{24}, Ic, Ec, Ac, Rhoh);
elementos{60} = VigaColumna2D('C15-25', nodos{15}, nodos{25}, Ic, Ec, Ac, Rhoh);
elementos{61} = VigaColumna2D('C16-26', nodos{16}, nodos{26}, Ic, Ec, Ac, Rhoh);
elementos{62} = VigaColumna2D('C17-27', nodos{17}, nodos{27}, Ic, Ec, Ac, Rhoh);
elementos{63} = VigaColumna2D('C18-28', nodos{18}, nodos{28}, Ic, Ec, Ac, Rhoh);
elementos{64} = VigaColumna2D('C19-29', nodos{19}, nodos{29}, Ic, Ec, Ac, Rhoh);
elementos{65} = VigaColumna2D('C110-210', nodos{20}, nodos{30}, Ic, Ec, Ac, Rhoh);

% Piso 2-3
elementos{66} = VigaColumna2D('C21-31', nodos{21}, nodos{31}, Ic, Ec, Ac, Rhoh);
elementos{67} = VigaColumna2D('C22-32', nodos{22}, nodos{32}, Ic, Ec, Ac, Rhoh);
elementos{68} = VigaColumna2D('C23-33', nodos{23}, nodos{33}, Ic, Ec, Ac, Rhoh);
elementos{69} = VigaColumna2D('C24-34', nodos{24}, nodos{34}, Ic, Ec, Ac, Rhoh);
elementos{70} = VigaColumna2D('C25-35', nodos{25}, nodos{35}, Ic, Ec, Ac, Rhoh);
elementos{71} = VigaColumna2D('C26-36', nodos{26}, nodos{36}, Ic, Ec, Ac, Rhoh);
elementos{72} = VigaColumna2D('C27-37', nodos{27}, nodos{37}, Ic, Ec, Ac, Rhoh);
elementos{73} = VigaColumna2D('C28-38', nodos{28}, nodos{38}, Ic, Ec, Ac, Rhoh);
elementos{74} = VigaColumna2D('C29-39', nodos{29}, nodos{39}, Ic, Ec, Ac, Rhoh);
elementos{75} = VigaColumna2D('C210-310', nodos{30}, nodos{40}, Ic, Ec, Ac, Rhoh);

% Piso 3-4
elementos{76} = VigaColumna2D('C31-41', nodos{31}, nodos{41}, Ic, Ec, Ac, Rhoh);
elementos{77} = VigaColumna2D('C32-42', nodos{32}, nodos{42}, Ic, Ec, Ac, Rhoh);
elementos{78} = VigaColumna2D('C33-43', nodos{33}, nodos{43}, Ic, Ec, Ac, Rhoh);
elementos{79} = VigaColumna2D('C34-44', nodos{34}, nodos{44}, Ic, Ec, Ac, Rhoh);
elementos{80} = VigaColumna2D('C35-45', nodos{35}, nodos{45}, Ic, Ec, Ac, Rhoh);
elementos{81} = VigaColumna2D('C36-46', nodos{36}, nodos{46}, Ic, Ec, Ac, Rhoh);
elementos{82} = VigaColumna2D('C37-47', nodos{37}, nodos{47}, Ic, Ec, Ac, Rhoh);
elementos{83} = VigaColumna2D('C38-48', nodos{38}, nodos{48}, Ic, Ec, Ac, Rhoh);
elementos{84} = VigaColumna2D('C39-49', nodos{39}, nodos{49}, Ic, Ec, Ac, Rhoh);
elementos{85} = VigaColumna2D('C310-410', nodos{40}, nodos{50}, Ic, Ec, Ac, Rhoh);

% Piso 4-5
elementos{86} = VigaColumna2D('C41-51', nodos{41}, nodos{51}, Ic, Ec, Ac, Rhoh);
elementos{87} = VigaColumna2D('C42-52', nodos{42}, nodos{52}, Ic, Ec, Ac, Rhoh);
elementos{88} = VigaColumna2D('C43-53', nodos{43}, nodos{53}, Ic, Ec, Ac, Rhoh);
elementos{89} = VigaColumna2D('C44-54', nodos{44}, nodos{54}, Ic, Ec, Ac, Rhoh);
elementos{90} = VigaColumna2D('C45-55', nodos{45}, nodos{55}, Ic, Ec, Ac, Rhoh);
elementos{91} = VigaColumna2D('C46-56', nodos{46}, nodos{56}, Ic, Ec, Ac, Rhoh);
elementos{92} = VigaColumna2D('C47-57', nodos{47}, nodos{57}, Ic, Ec, Ac, Rhoh);
elementos{93} = VigaColumna2D('C48-58', nodos{48}, nodos{58}, Ic, Ec, Ac, Rhoh);
elementos{94} = VigaColumna2D('C49-59', nodos{49}, nodos{59}, Ic, Ec, Ac, Rhoh);
elementos{95} = VigaColumna2D('C410-510', nodos{50}, nodos{60}, Ic, Ec, Ac, Rhoh);


%% Fundaciones
if modelarFundacion
    Kinf = 10^12;
    elementos{238} = Fundacion2D('FN01-FN02', nodos{1}, nodos{2}, Mr, Kinf);
    elementos{239} = Fundacion2D('FN02-FN03', nodos{2}, nodos{3}, Mr, Kinf);
    elementos{240} = Fundacion2D('FN03-FN04', nodos{3}, nodos{4}, Mr, Kinf);
    elementos{241} = Fundacion2D('FN04-FN05', nodos{4}, nodos{5}, Mr, Kinf);
    elementos{242} = Fundacion2D('FN05-FN06', nodos{5}, nodos{6}, Mr, Kinf);
    elementos{243} = Fundacion2D('FN06-FN07', nodos{6}, nodos{7}, Mr, Kinf);
    elementos{244} = Fundacion2D('FN07-FN08', nodos{7}, nodos{8}, Mr, Kinf);
    elementos{245} = Fundacion2D('FN08-FN09', nodos{8}, nodos{9}, Mr, Kinf);
    elementos{246} = Fundacion2D('FN09-FN010', nodos{9}, nodos{10}, Mr, Kinf); 
    elementos{247} = Fundacion2D('aux', nodos{10}, nodos{145}, 10^-10, Kr);
end

%% Otros
wIterDespl = [2.55770213386969 7.16560268459290 12.4566599334486 ...
    18.5604127664363 25.2431954885662 30.9098179115540 ...
    32.8021132019727 34.0128761482208 36.5858886493597 ...
    42.8579427711730 44.8060940047270 53.3692296031510 ...
    59.4652234520037 64.9028128188504 65.5624255868333 ...
    77.1695523410056 82.4577492094391 84.8793197411019 ...
    89.6129863044788 92.3722086828802 93.1081309515012 ...
    102.542136220786 103.068669452994 104.539068890293 ...
    106.510173143805 112.313797933399 127.510616892239 ...
    128.129197535452 131.612438971985 134.014310629741 ...
    135.588674689873 135.992096928713 137.114907475638 ...
    138.924925485962 139.309707400221 145.303274192798 ...
    145.986194753148 147.613919135851 149.583993370884 ...
    150.872205488160 152.240535917133 156.063979833955 ...
    162.265887158119 164.276468582795 171.105439346982 ...
    176.184981651255 177.436993925946 184.742256236947 ...
    186.171303816978 189.395804862162]';

% Suma un numero aleatorio
for i=1:length(wIterDespl)
    wIterDespl(i) = wIterDespl(i) - 0.1*rand();
    wIterDespl(i) = wIterDespl(i)^2; % Necesario para la convergencia
end