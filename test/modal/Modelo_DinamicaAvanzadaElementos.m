% Elementos Modelo

%% DEFINICION DE PROPIEDADES

% Propiedades de la viga
Av = 0.65 * 0.4; % (m2)
Ev = 2625051; % (tonf/m2)
Iv = (0.4 * 0.65^3) / 12;

% Propiedades de la columna
Ac = 1; % (m2)
Ec = 2625051; % (tonf/m2)
Ic = 1 / 12;

% Densidad del material hormigon
Rhoh = 2.5; % (tonf/m3)

%% VIGAS
% Piso 1
elementos{1} = VigaColumnaMasa2D('V11-12', nodos{11}, nodos{12}, Iv, Ev, Av, Rhoh); %#ok<*SUSENS>
elementos{1}.desactivarGraficoDeformada();
elementos{2} = VigaColumnaMasa2D('V12-13', nodos{12}, nodos{13}, Iv, Ev, Av, Rhoh);
elementos{3} = VigaColumnaMasa2D('V13-14', nodos{13}, nodos{14}, Iv, Ev, Av, Rhoh);
elementos{4} = VigaColumnaMasa2D('V14-15', nodos{14}, nodos{15}, Iv, Ev, Av, Rhoh);
elementos{5} = VigaColumnaMasa2D('V15-16', nodos{15}, nodos{16}, Iv, Ev, Av, Rhoh);
elementos{6} = VigaColumnaMasa2D('V16-17', nodos{16}, nodos{17}, Iv, Ev, Av, Rhoh);
elementos{7} = VigaColumnaMasa2D('V17-18', nodos{17}, nodos{18}, Iv, Ev, Av, Rhoh);
elementos{8} = VigaColumnaMasa2D('V18-19', nodos{18}, nodos{19}, Iv, Ev, Av, Rhoh);
elementos{9} = VigaColumnaMasa2D('V19-110', nodos{19}, nodos{20}, Iv, Ev, Av, Rhoh);

% Piso 2
elementos{10} = VigaColumnaMasa2D('V21-22', nodos{21}, nodos{22}, Iv, Ev, Av, Rhoh);
elementos{11} = VigaColumnaMasa2D('V22-23', nodos{22}, nodos{23}, Iv, Ev, Av, Rhoh);
elementos{12} = VigaColumnaMasa2D('V23-24', nodos{23}, nodos{24}, Iv, Ev, Av, Rhoh);
elementos{13} = VigaColumnaMasa2D('V24-25', nodos{24}, nodos{25}, Iv, Ev, Av, Rhoh);
elementos{14} = VigaColumnaMasa2D('V25-26', nodos{25}, nodos{26}, Iv, Ev, Av, Rhoh);
elementos{15} = VigaColumnaMasa2D('V26-27', nodos{26}, nodos{27}, Iv, Ev, Av, Rhoh);
elementos{16} = VigaColumnaMasa2D('V27-28', nodos{27}, nodos{28}, Iv, Ev, Av, Rhoh);
elementos{17} = VigaColumnaMasa2D('V28-29', nodos{28}, nodos{29}, Iv, Ev, Av, Rhoh);
elementos{18} = VigaColumnaMasa2D('V29-210', nodos{29}, nodos{30}, Iv, Ev, Av, Rhoh);

% Piso 3
elementos{19} = VigaColumnaMasa2D('V31-32', nodos{31}, nodos{32}, Iv, Ev, Av, Rhoh);
elementos{20} = VigaColumnaMasa2D('V32-33', nodos{32}, nodos{33}, Iv, Ev, Av, Rhoh);
elementos{21} = VigaColumnaMasa2D('V33-34', nodos{33}, nodos{34}, Iv, Ev, Av, Rhoh);
elementos{22} = VigaColumnaMasa2D('V34-35', nodos{34}, nodos{35}, Iv, Ev, Av, Rhoh);
elementos{23} = VigaColumnaMasa2D('V35-36', nodos{35}, nodos{36}, Iv, Ev, Av, Rhoh);
elementos{24} = VigaColumnaMasa2D('V36-37', nodos{36}, nodos{37}, Iv, Ev, Av, Rhoh);
elementos{25} = VigaColumnaMasa2D('V37-38', nodos{37}, nodos{38}, Iv, Ev, Av, Rhoh);
elementos{26} = VigaColumnaMasa2D('V38-39', nodos{38}, nodos{39}, Iv, Ev, Av, Rhoh);
elementos{27} = VigaColumnaMasa2D('V39-310', nodos{39}, nodos{40}, Iv, Ev, Av, Rhoh);

% Piso 4
elementos{28} = VigaColumnaMasa2D('V41-42', nodos{41}, nodos{42}, Iv, Ev, Av, Rhoh);
elementos{29} = VigaColumnaMasa2D('V42-43', nodos{42}, nodos{43}, Iv, Ev, Av, Rhoh);
elementos{30} = VigaColumnaMasa2D('V43-44', nodos{43}, nodos{44}, Iv, Ev, Av, Rhoh);
elementos{31} = VigaColumnaMasa2D('V44-45', nodos{44}, nodos{45}, Iv, Ev, Av, Rhoh);
elementos{32} = VigaColumnaMasa2D('V45-46', nodos{45}, nodos{46}, Iv, Ev, Av, Rhoh);
elementos{33} = VigaColumnaMasa2D('V46-47', nodos{46}, nodos{47}, Iv, Ev, Av, Rhoh);
elementos{34} = VigaColumnaMasa2D('V47-48', nodos{47}, nodos{48}, Iv, Ev, Av, Rhoh);

% Piso 5
elementos{35} = VigaColumnaMasa2D('V51-52', nodos{49}, nodos{50}, Iv, Ev, Av, Rhoh);
elementos{36} = VigaColumnaMasa2D('V52-53', nodos{50}, nodos{51}, Iv, Ev, Av, Rhoh);
elementos{37} = VigaColumnaMasa2D('V53-54', nodos{51}, nodos{52}, Iv, Ev, Av, Rhoh);
elementos{38} = VigaColumnaMasa2D('V54-55', nodos{52}, nodos{53}, Iv, Ev, Av, Rhoh);
elementos{39} = VigaColumnaMasa2D('V55-56', nodos{53}, nodos{54}, Iv, Ev, Av, Rhoh);
elementos{40} = VigaColumnaMasa2D('V56-57', nodos{54}, nodos{55}, Iv, Ev, Av, Rhoh);
elementos{41} = VigaColumnaMasa2D('V57-58', nodos{55}, nodos{56}, Iv, Ev, Av, Rhoh);

% Piso 6
elementos{42} = VigaColumnaMasa2D('V61-62', nodos{57}, nodos{58}, Iv, Ev, Av, Rhoh);
elementos{43} = VigaColumnaMasa2D('V62-63', nodos{58}, nodos{59}, Iv, Ev, Av, Rhoh);
elementos{44} = VigaColumnaMasa2D('V63-64', nodos{59}, nodos{60}, Iv, Ev, Av, Rhoh);
elementos{45} = VigaColumnaMasa2D('V64-65', nodos{60}, nodos{61}, Iv, Ev, Av, Rhoh);
elementos{46} = VigaColumnaMasa2D('V65-66', nodos{61}, nodos{62}, Iv, Ev, Av, Rhoh);

% Piso 7
elementos{47} = VigaColumnaMasa2D('V71-72', nodos{63}, nodos{64}, Iv, Ev, Av, Rhoh);
elementos{48} = VigaColumnaMasa2D('V72-73', nodos{64}, nodos{65}, Iv, Ev, Av, Rhoh);
elementos{49} = VigaColumnaMasa2D('V73-74', nodos{65}, nodos{66}, Iv, Ev, Av, Rhoh);
elementos{50} = VigaColumnaMasa2D('V74-75', nodos{66}, nodos{67}, Iv, Ev, Av, Rhoh);
elementos{51} = VigaColumnaMasa2D('V75-76', nodos{67}, nodos{68}, Iv, Ev, Av, Rhoh);

% Piso 8
elementos{52} = VigaColumnaMasa2D('V81-82', nodos{69}, nodos{70}, Iv, Ev, Av, Rhoh);
elementos{53} = VigaColumnaMasa2D('V82-83', nodos{70}, nodos{71}, Iv, Ev, Av, Rhoh);
elementos{54} = VigaColumnaMasa2D('V83-84', nodos{71}, nodos{72}, Iv, Ev, Av, Rhoh);

% Piso 9
elementos{55} = VigaColumnaMasa2D('V91-92', nodos{73}, nodos{74}, Iv, Ev, Av, Rhoh);
elementos{56} = VigaColumnaMasa2D('V92-93', nodos{74}, nodos{75}, Iv, Ev, Av, Rhoh);
elementos{57} = VigaColumnaMasa2D('V93-94', nodos{75}, nodos{76}, Iv, Ev, Av, Rhoh);

% Piso 10
elementos{58} = VigaColumnaMasa2D('V101-102', nodos{77}, nodos{78}, Iv, Ev, Av, Rhoh);
elementos{59} = VigaColumnaMasa2D('V102-103', nodos{78}, nodos{79}, Iv, Ev, Av, Rhoh);
elementos{60} = VigaColumnaMasa2D('V103-104', nodos{79}, nodos{80}, Iv, Ev, Av, Rhoh);

% Piso 11
elementos{61} = VigaColumnaMasa2D('V111-112', nodos{81}, nodos{82}, Iv, Ev, Av, Rhoh);
elementos{62} = VigaColumnaMasa2D('V112-113', nodos{82}, nodos{83}, Iv, Ev, Av, Rhoh);
elementos{63} = VigaColumnaMasa2D('V113-114', nodos{83}, nodos{84}, Iv, Ev, Av, Rhoh);

% Piso 12
elementos{64} = VigaColumnaMasa2D('V121-122', nodos{85}, nodos{86}, Iv, Ev, Av, Rhoh);
elementos{65} = VigaColumnaMasa2D('V122-123', nodos{86}, nodos{87}, Iv, Ev, Av, Rhoh);
elementos{66} = VigaColumnaMasa2D('V123-124', nodos{87}, nodos{88}, Iv, Ev, Av, Rhoh);

% Piso 13
elementos{67} = VigaColumnaMasa2D('V131-132', nodos{89}, nodos{90}, Iv, Ev, Av, Rhoh);
elementos{68} = VigaColumnaMasa2D('V132-133', nodos{90}, nodos{91}, Iv, Ev, Av, Rhoh);
elementos{69} = VigaColumnaMasa2D('V133-134', nodos{91}, nodos{92}, Iv, Ev, Av, Rhoh);

% Piso 14
elementos{70} = VigaColumnaMasa2D('V141-142', nodos{93}, nodos{94}, Iv, Ev, Av, Rhoh);
elementos{71} = VigaColumnaMasa2D('V142-143', nodos{94}, nodos{95}, Iv, Ev, Av, Rhoh);
elementos{72} = VigaColumnaMasa2D('V143-144', nodos{95}, nodos{96}, Iv, Ev, Av, Rhoh);

% Piso 15
elementos{73} = VigaColumnaMasa2D('V151-152', nodos{97}, nodos{98}, Iv, Ev, Av, Rhoh);
elementos{74} = VigaColumnaMasa2D('V152-153', nodos{98}, nodos{99}, Iv, Ev, Av, Rhoh);
elementos{75} = VigaColumnaMasa2D('V153-154', nodos{99}, nodos{100}, Iv, Ev, Av, Rhoh);

% Piso 16
elementos{76} = VigaColumnaMasa2D('V161-162', nodos{101}, nodos{102}, Iv, Ev, Av, Rhoh);
elementos{77} = VigaColumnaMasa2D('V162-163', nodos{102}, nodos{103}, Iv, Ev, Av, Rhoh);
elementos{78} = VigaColumnaMasa2D('V163-164', nodos{103}, nodos{104}, Iv, Ev, Av, Rhoh);

% Piso 17
elementos{79} = VigaColumnaMasa2D('V171-172', nodos{105}, nodos{106}, Iv, Ev, Av, Rhoh);
elementos{80} = VigaColumnaMasa2D('V173-174', nodos{107}, nodos{108}, Iv, Ev, Av, Rhoh);

% Piso 18
elementos{81} = VigaColumnaMasa2D('V181-182', nodos{109}, nodos{110}, Iv, Ev, Av, Rhoh);
elementos{82} = VigaColumnaMasa2D('V183-184', nodos{111}, nodos{112}, Iv, Ev, Av, Rhoh);

% Piso 19
elementos{83} = VigaColumnaMasa2D('V191-192', nodos{113}, nodos{114}, Iv, Ev, Av, Rhoh);
elementos{84} = VigaColumnaMasa2D('V193-194', nodos{115}, nodos{116}, Iv, Ev, Av, Rhoh);

% Piso 20
elementos{85} = VigaColumnaMasa2D('V201-202', nodos{117}, nodos{118}, Iv, Ev, Av, Rhoh);
elementos{86} = VigaColumnaMasa2D('V203-204', nodos{119}, nodos{120}, Iv, Ev, Av, Rhoh);

% Piso 21
elementos{87} = VigaColumnaMasa2D('V211-212', nodos{121}, nodos{122}, Iv, Ev, Av, Rhoh);
elementos{88} = VigaColumnaMasa2D('V212-213', nodos{122}, nodos{123}, Iv, Ev, Av, Rhoh);
elementos{89} = VigaColumnaMasa2D('V213-214', nodos{123}, nodos{124}, Iv, Ev, Av, Rhoh);

% Piso 22
elementos{90} = VigaColumnaMasa2D('V221-222', nodos{125}, nodos{126}, Iv, Ev, Av, Rhoh);
elementos{91} = VigaColumnaMasa2D('V222-223', nodos{126}, nodos{127}, Iv, Ev, Av, Rhoh);
elementos{92} = VigaColumnaMasa2D('V223-224', nodos{127}, nodos{128}, Iv, Ev, Av, Rhoh);

% Piso 23
elementos{93} = VigaColumnaMasa2D('V231-232', nodos{129}, nodos{130}, Iv, Ev, Av, Rhoh);
elementos{94} = VigaColumnaMasa2D('V232-233', nodos{130}, nodos{131}, Iv, Ev, Av, Rhoh);
elementos{95} = VigaColumnaMasa2D('V233-234', nodos{131}, nodos{132}, Iv, Ev, Av, Rhoh);

% Piso 24
elementos{96} = VigaColumnaMasa2D('V241-242', nodos{133}, nodos{134}, Iv, Ev, Av, Rhoh);
elementos{97} = VigaColumnaMasa2D('V242-243', nodos{134}, nodos{135}, Iv, Ev, Av, Rhoh);
elementos{98} = VigaColumnaMasa2D('V243-244', nodos{135}, nodos{136}, Iv, Ev, Av, Rhoh);

% Piso 25
elementos{99} = VigaColumnaMasa2D('V251-252', nodos{137}, nodos{138}, Iv, Ev, Av, Rhoh);
elementos{100} = VigaColumnaMasa2D('V252-253', nodos{138}, nodos{139}, Iv, Ev, Av, Rhoh);
elementos{101} = VigaColumnaMasa2D('V253-254', nodos{139}, nodos{140}, Iv, Ev, Av, Rhoh);

% Piso 26
elementos{102} = VigaColumnaMasa2D('V261-262', nodos{141}, nodos{142}, Iv, Ev, Av, Rhoh);

% Piso 27
elementos{103} = VigaColumnaMasa2D('V271-272', nodos{143}, nodos{144}, Iv, Ev, Av, Rhoh);

%% COLUMNAS
% Piso 0-1
elementos{104} = VigaColumnaMasa2D('C01-11', nodos{1}, nodos{11}, Ic, Ec, Ac, Rhoh);
elementos{105} = VigaColumnaMasa2D('C02-12', nodos{2}, nodos{12}, Ic, Ec, Ac, Rhoh);
elementos{106} = VigaColumnaMasa2D('C03-13', nodos{3}, nodos{13}, Ic, Ec, Ac, Rhoh);
elementos{107} = VigaColumnaMasa2D('C04-14', nodos{4}, nodos{14}, Ic, Ec, Ac, Rhoh);
elementos{108} = VigaColumnaMasa2D('C05-15', nodos{5}, nodos{15}, Ic, Ec, Ac, Rhoh);
elementos{109} = VigaColumnaMasa2D('C06-16', nodos{6}, nodos{16}, Ic, Ec, Ac, Rhoh);
elementos{110} = VigaColumnaMasa2D('C07-17', nodos{7}, nodos{17}, Ic, Ec, Ac, Rhoh);
elementos{111} = VigaColumnaMasa2D('C08-18', nodos{8}, nodos{18}, Ic, Ec, Ac, Rhoh);
elementos{112} = VigaColumnaMasa2D('C09-19', nodos{9}, nodos{19}, Ic, Ec, Ac, Rhoh);
elementos{113} = VigaColumnaMasa2D('C010-110', nodos{10}, nodos{20}, Ic, Ec, Ac, Rhoh);

% Piso 1-2
elementos{114} = VigaColumnaMasa2D('C11-21', nodos{11}, nodos{21}, Ic, Ec, Ac, Rhoh);
elementos{115} = VigaColumnaMasa2D('C12-22', nodos{12}, nodos{22}, Ic, Ec, Ac, Rhoh);
elementos{116} = VigaColumnaMasa2D('C13-23', nodos{13}, nodos{23}, Ic, Ec, Ac, Rhoh);
elementos{117} = VigaColumnaMasa2D('C14-24', nodos{14}, nodos{24}, Ic, Ec, Ac, Rhoh);
elementos{118} = VigaColumnaMasa2D('C15-25', nodos{15}, nodos{25}, Ic, Ec, Ac, Rhoh);
elementos{119} = VigaColumnaMasa2D('C16-26', nodos{16}, nodos{26}, Ic, Ec, Ac, Rhoh);
elementos{120} = VigaColumnaMasa2D('C17-27', nodos{17}, nodos{27}, Ic, Ec, Ac, Rhoh);
elementos{121} = VigaColumnaMasa2D('C18-28', nodos{18}, nodos{28}, Ic, Ec, Ac, Rhoh);
elementos{122} = VigaColumnaMasa2D('C19-29', nodos{19}, nodos{29}, Ic, Ec, Ac, Rhoh);
elementos{123} = VigaColumnaMasa2D('C110-210', nodos{20}, nodos{30}, Ic, Ec, Ac, Rhoh);

% Piso 2-3
elementos{124} = VigaColumnaMasa2D('C21-31', nodos{21}, nodos{31}, Ic, Ec, Ac, Rhoh);
elementos{125} = VigaColumnaMasa2D('C22-32', nodos{22}, nodos{32}, Ic, Ec, Ac, Rhoh);
elementos{126} = VigaColumnaMasa2D('C23-33', nodos{23}, nodos{33}, Ic, Ec, Ac, Rhoh);
elementos{127} = VigaColumnaMasa2D('C24-34', nodos{24}, nodos{34}, Ic, Ec, Ac, Rhoh);
elementos{128} = VigaColumnaMasa2D('C25-35', nodos{25}, nodos{35}, Ic, Ec, Ac, Rhoh);
elementos{129} = VigaColumnaMasa2D('C26-36', nodos{26}, nodos{36}, Ic, Ec, Ac, Rhoh);
elementos{130} = VigaColumnaMasa2D('C27-37', nodos{27}, nodos{37}, Ic, Ec, Ac, Rhoh);
elementos{131} = VigaColumnaMasa2D('C28-38', nodos{28}, nodos{38}, Ic, Ec, Ac, Rhoh);
elementos{132} = VigaColumnaMasa2D('C29-39', nodos{29}, nodos{39}, Ic, Ec, Ac, Rhoh);
elementos{133} = VigaColumnaMasa2D('C210-310', nodos{30}, nodos{40}, Ic, Ec, Ac, Rhoh);

% Piso 3-4
elementos{134} = VigaColumnaMasa2D('C32-41', nodos{32}, nodos{41}, Ic, Ec, Ac, Rhoh);
elementos{135} = VigaColumnaMasa2D('C33-42', nodos{33}, nodos{42}, Ic, Ec, Ac, Rhoh);
elementos{136} = VigaColumnaMasa2D('C34-43', nodos{34}, nodos{43}, Ic, Ec, Ac, Rhoh);
elementos{137} = VigaColumnaMasa2D('C35-44', nodos{35}, nodos{44}, Ic, Ec, Ac, Rhoh);
elementos{138} = VigaColumnaMasa2D('C36-45', nodos{36}, nodos{45}, Ic, Ec, Ac, Rhoh);
elementos{139} = VigaColumnaMasa2D('C37-46', nodos{37}, nodos{46}, Ic, Ec, Ac, Rhoh);
elementos{140} = VigaColumnaMasa2D('C38-47', nodos{38}, nodos{47}, Ic, Ec, Ac, Rhoh);
elementos{141} = VigaColumnaMasa2D('C39-48', nodos{39}, nodos{48}, Ic, Ec, Ac, Rhoh);

% Piso 4-5
elementos{142} = VigaColumnaMasa2D('C41-51', nodos{41}, nodos{49}, Ic, Ec, Ac, Rhoh);
elementos{143} = VigaColumnaMasa2D('C42-52', nodos{42}, nodos{50}, Ic, Ec, Ac, Rhoh);
elementos{144} = VigaColumnaMasa2D('C43-53', nodos{43}, nodos{51}, Ic, Ec, Ac, Rhoh);
elementos{145} = VigaColumnaMasa2D('C44-54', nodos{44}, nodos{52}, Ic, Ec, Ac, Rhoh);
elementos{146} = VigaColumnaMasa2D('C45-55', nodos{45}, nodos{53}, Ic, Ec, Ac, Rhoh);
elementos{147} = VigaColumnaMasa2D('C46-56', nodos{46}, nodos{54}, Ic, Ec, Ac, Rhoh);
elementos{148} = VigaColumnaMasa2D('C47-57', nodos{47}, nodos{55}, Ic, Ec, Ac, Rhoh);
elementos{149} = VigaColumnaMasa2D('C48-58', nodos{48}, nodos{56}, Ic, Ec, Ac, Rhoh);

% Piso 5-6
elementos{150} = VigaColumnaMasa2D('C52-61', nodos{50}, nodos{57}, Ic, Ec, Ac, Rhoh);
elementos{151} = VigaColumnaMasa2D('C53-62', nodos{51}, nodos{58}, Ic, Ec, Ac, Rhoh);
elementos{152} = VigaColumnaMasa2D('C54-63', nodos{52}, nodos{59}, Ic, Ec, Ac, Rhoh);
elementos{153} = VigaColumnaMasa2D('C55-64', nodos{53}, nodos{60}, Ic, Ec, Ac, Rhoh);
elementos{154} = VigaColumnaMasa2D('C56-65', nodos{54}, nodos{61}, Ic, Ec, Ac, Rhoh);
elementos{155} = VigaColumnaMasa2D('C57-66', nodos{55}, nodos{62}, Ic, Ec, Ac, Rhoh);

% Piso 6-7
elementos{156} = VigaColumnaMasa2D('C61-71', nodos{57}, nodos{63}, Ic, Ec, Ac, Rhoh);
elementos{157} = VigaColumnaMasa2D('C62-72', nodos{58}, nodos{64}, Ic, Ec, Ac, Rhoh);
elementos{158} = VigaColumnaMasa2D('C63-73', nodos{59}, nodos{65}, Ic, Ec, Ac, Rhoh);
elementos{159} = VigaColumnaMasa2D('C64-74', nodos{60}, nodos{66}, Ic, Ec, Ac, Rhoh);
elementos{160} = VigaColumnaMasa2D('C65-75', nodos{61}, nodos{67}, Ic, Ec, Ac, Rhoh);
elementos{161} = VigaColumnaMasa2D('C66-76', nodos{62}, nodos{68}, Ic, Ec, Ac, Rhoh);

% Piso 7-8
elementos{162} = VigaColumnaMasa2D('C72-81', nodos{64}, nodos{69}, Ic, Ec, Ac, Rhoh);
elementos{163} = VigaColumnaMasa2D('C73-82', nodos{65}, nodos{70}, Ic, Ec, Ac, Rhoh);
elementos{164} = VigaColumnaMasa2D('C74-83', nodos{66}, nodos{71}, Ic, Ec, Ac, Rhoh);
elementos{165} = VigaColumnaMasa2D('C75-84', nodos{67}, nodos{72}, Ic, Ec, Ac, Rhoh);

% Piso 8-9
elementos{166} = VigaColumnaMasa2D('C81-91', nodos{69}, nodos{73}, Ic, Ec, Ac, Rhoh);
elementos{167} = VigaColumnaMasa2D('C82-92', nodos{70}, nodos{74}, Ic, Ec, Ac, Rhoh);
elementos{168} = VigaColumnaMasa2D('C83-93', nodos{71}, nodos{75}, Ic, Ec, Ac, Rhoh);
elementos{169} = VigaColumnaMasa2D('C84-94', nodos{72}, nodos{76}, Ic, Ec, Ac, Rhoh);

% Piso 9-10
elementos{170} = VigaColumnaMasa2D('C91-101', nodos{73}, nodos{77}, Ic, Ec, Ac, Rhoh);
elementos{171} = VigaColumnaMasa2D('C92-102', nodos{74}, nodos{78}, Ic, Ec, Ac, Rhoh);
elementos{172} = VigaColumnaMasa2D('C93-103', nodos{75}, nodos{79}, Ic, Ec, Ac, Rhoh);
elementos{173} = VigaColumnaMasa2D('C94-104', nodos{76}, nodos{80}, Ic, Ec, Ac, Rhoh);

% Piso 10-11
elementos{174} = VigaColumnaMasa2D('C101-111', nodos{77}, nodos{81}, Ic, Ec, Ac, Rhoh);
elementos{175} = VigaColumnaMasa2D('C102-112', nodos{78}, nodos{82}, Ic, Ec, Ac, Rhoh);
elementos{176} = VigaColumnaMasa2D('C103-113', nodos{79}, nodos{83}, Ic, Ec, Ac, Rhoh);
elementos{177} = VigaColumnaMasa2D('C104-114', nodos{80}, nodos{84}, Ic, Ec, Ac, Rhoh);

% Piso 11-12
elementos{178} = VigaColumnaMasa2D('C111-121', nodos{81}, nodos{85}, Ic, Ec, Ac, Rhoh);
elementos{179} = VigaColumnaMasa2D('C112-122', nodos{82}, nodos{86}, Ic, Ec, Ac, Rhoh);
elementos{180} = VigaColumnaMasa2D('C113-123', nodos{83}, nodos{87}, Ic, Ec, Ac, Rhoh);
elementos{181} = VigaColumnaMasa2D('C114-124', nodos{84}, nodos{88}, Ic, Ec, Ac, Rhoh);

% Piso 12-13
elementos{182} = VigaColumnaMasa2D('C121-131', nodos{85}, nodos{89}, Ic, Ec, Ac, Rhoh);
elementos{183} = VigaColumnaMasa2D('C122-132', nodos{86}, nodos{90}, Ic, Ec, Ac, Rhoh);
elementos{184} = VigaColumnaMasa2D('C123-133', nodos{87}, nodos{91}, Ic, Ec, Ac, Rhoh);
elementos{185} = VigaColumnaMasa2D('C124-134', nodos{88}, nodos{92}, Ic, Ec, Ac, Rhoh);

% Piso 13-14
elementos{186} = VigaColumnaMasa2D('C131-141', nodos{89}, nodos{93}, Ic, Ec, Ac, Rhoh);
elementos{187} = VigaColumnaMasa2D('C132-142', nodos{90}, nodos{94}, Ic, Ec, Ac, Rhoh);
elementos{188} = VigaColumnaMasa2D('C133-143', nodos{91}, nodos{95}, Ic, Ec, Ac, Rhoh);
elementos{189} = VigaColumnaMasa2D('C134-144', nodos{92}, nodos{96}, Ic, Ec, Ac, Rhoh);

% Piso 14-15
elementos{190} = VigaColumnaMasa2D('C141-151', nodos{93}, nodos{97}, Ic, Ec, Ac, Rhoh);
elementos{191} = VigaColumnaMasa2D('C142-152', nodos{94}, nodos{98}, Ic, Ec, Ac, Rhoh);
elementos{192} = VigaColumnaMasa2D('C143-153', nodos{95}, nodos{99}, Ic, Ec, Ac, Rhoh);
elementos{193} = VigaColumnaMasa2D('C144-154', nodos{96}, nodos{100}, Ic, Ec, Ac, Rhoh);

% Piso 15-16
elementos{194} = VigaColumnaMasa2D('C151-161', nodos{97}, nodos{101}, Ic, Ec, Ac, Rhoh);
elementos{195} = VigaColumnaMasa2D('C152-162', nodos{98}, nodos{102}, Ic, Ec, Ac, Rhoh);
elementos{196} = VigaColumnaMasa2D('C153-163', nodos{99}, nodos{103}, Ic, Ec, Ac, Rhoh);
elementos{197} = VigaColumnaMasa2D('C154-164', nodos{100}, nodos{104}, Ic, Ec, Ac, Rhoh);

% Piso 16-17
elementos{198} = VigaColumnaMasa2D('C161-171', nodos{101}, nodos{105}, Ic, Ec, Ac, Rhoh);
elementos{199} = VigaColumnaMasa2D('C162-172', nodos{102}, nodos{106}, Ic, Ec, Ac, Rhoh);
elementos{200} = VigaColumnaMasa2D('C163-173', nodos{103}, nodos{107}, Ic, Ec, Ac, Rhoh);
elementos{201} = VigaColumnaMasa2D('C164-174', nodos{104}, nodos{108}, Ic, Ec, Ac, Rhoh);

% Piso 17-18
elementos{202} = VigaColumnaMasa2D('C171-181', nodos{105}, nodos{109}, Ic, Ec, Ac, Rhoh);
elementos{203} = VigaColumnaMasa2D('C172-182', nodos{106}, nodos{110}, Ic, Ec, Ac, Rhoh);
elementos{204} = VigaColumnaMasa2D('C173-183', nodos{107}, nodos{111}, Ic, Ec, Ac, Rhoh);
elementos{205} = VigaColumnaMasa2D('C174-184', nodos{108}, nodos{112}, Ic, Ec, Ac, Rhoh);

% Piso 18-19
elementos{206} = VigaColumnaMasa2D('C181-191', nodos{109}, nodos{113}, Ic, Ec, Ac, Rhoh);
elementos{207} = VigaColumnaMasa2D('C182-192', nodos{110}, nodos{114}, Ic, Ec, Ac, Rhoh);
elementos{208} = VigaColumnaMasa2D('C183-193', nodos{111}, nodos{115}, Ic, Ec, Ac, Rhoh);
elementos{209} = VigaColumnaMasa2D('C184-194', nodos{112}, nodos{116}, Ic, Ec, Ac, Rhoh);

% Piso 19-20
elementos{210} = VigaColumnaMasa2D('C191-201', nodos{113}, nodos{117}, Ic, Ec, Ac, Rhoh);
elementos{211} = VigaColumnaMasa2D('C192-202', nodos{114}, nodos{118}, Ic, Ec, Ac, Rhoh);
elementos{212} = VigaColumnaMasa2D('C193-203', nodos{115}, nodos{119}, Ic, Ec, Ac, Rhoh);
elementos{213} = VigaColumnaMasa2D('C194-204', nodos{116}, nodos{120}, Ic, Ec, Ac, Rhoh);

% Piso 20-21
elementos{214} = VigaColumnaMasa2D('C201-211', nodos{117}, nodos{121}, Ic, Ec, Ac, Rhoh);
elementos{215} = VigaColumnaMasa2D('C202-212', nodos{118}, nodos{122}, Ic, Ec, Ac, Rhoh);
elementos{216} = VigaColumnaMasa2D('C203-213', nodos{119}, nodos{123}, Ic, Ec, Ac, Rhoh);
elementos{217} = VigaColumnaMasa2D('C204-214', nodos{120}, nodos{124}, Ic, Ec, Ac, Rhoh);

% Piso 21-22
elementos{218} = VigaColumnaMasa2D('C211-221', nodos{121}, nodos{125}, Ic, Ec, Ac, Rhoh);
elementos{219} = VigaColumnaMasa2D('C212-222', nodos{122}, nodos{126}, Ic, Ec, Ac, Rhoh);
elementos{220} = VigaColumnaMasa2D('C213-223', nodos{123}, nodos{127}, Ic, Ec, Ac, Rhoh);
elementos{221} = VigaColumnaMasa2D('C214-224', nodos{124}, nodos{128}, Ic, Ec, Ac, Rhoh);

% Piso 22-23
elementos{222} = VigaColumnaMasa2D('C221-231', nodos{125}, nodos{129}, Ic, Ec, Ac, Rhoh);
elementos{223} = VigaColumnaMasa2D('C222-232', nodos{126}, nodos{130}, Ic, Ec, Ac, Rhoh);
elementos{224} = VigaColumnaMasa2D('C223-233', nodos{127}, nodos{131}, Ic, Ec, Ac, Rhoh);
elementos{225} = VigaColumnaMasa2D('C224-234', nodos{128}, nodos{132}, Ic, Ec, Ac, Rhoh);

% Piso 23-24
elementos{226} = VigaColumnaMasa2D('C231-241', nodos{129}, nodos{133}, Ic, Ec, Ac, Rhoh);
elementos{227} = VigaColumnaMasa2D('C232-242', nodos{130}, nodos{134}, Ic, Ec, Ac, Rhoh);
elementos{228} = VigaColumnaMasa2D('C233-243', nodos{131}, nodos{135}, Ic, Ec, Ac, Rhoh);
elementos{229} = VigaColumnaMasa2D('C234-244', nodos{132}, nodos{136}, Ic, Ec, Ac, Rhoh);

% Piso 24-25
elementos{230} = VigaColumnaMasa2D('C241-251', nodos{133}, nodos{137}, Ic, Ec, Ac, Rhoh);
elementos{231} = VigaColumnaMasa2D('C242-252', nodos{134}, nodos{138}, Ic, Ec, Ac, Rhoh);
elementos{232} = VigaColumnaMasa2D('C243-253', nodos{135}, nodos{139}, Ic, Ec, Ac, Rhoh);
elementos{233} = VigaColumnaMasa2D('C244-254', nodos{136}, nodos{140}, Ic, Ec, Ac, Rhoh);

% Piso 25-26
elementos{234} = VigaColumnaMasa2D('C252-262', nodos{138}, nodos{141}, Ic, Ec, Ac, Rhoh);
elementos{235} = VigaColumnaMasa2D('C253-263', nodos{139}, nodos{142}, Ic, Ec, Ac, Rhoh);

% Piso 26-27
elementos{236} = VigaColumnaMasa2D('C262-272', nodos{141}, nodos{143}, Ic, Ec, Ac, Rhoh);
elementos{237} = VigaColumnaMasa2D('C263-273', nodos{142}, nodos{144}, Ic, Ec, Ac, Rhoh);