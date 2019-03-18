% Elementos Modelo

elementos = cell(179, 1);

%% VIGAS
% Piso 1
elementos{1} = VigaColumna2D('V11-12', nodos{11}, nodos{12}, Iv, Ev, Av);
elementos{2} = VigaColumna2D('V12-13', nodos{12}, nodos{13}, Iv, Ev, Av);
elementos{3} = VigaColumna2D('V13-14', nodos{13}, nodos{14}, Iv, Ev, Av);
elementos{4} = VigaColumna2D('V14-15', nodos{14}, nodos{15}, Iv, Ev, Av);
elementos{5} = VigaColumna2D('V15-16', nodos{15}, nodos{16}, Iv, Ev, Av);
elementos{6} = VigaColumna2D('V16-17', nodos{16}, nodos{17}, Iv, Ev, Av);
elementos{7} = VigaColumna2D('V17-18', nodos{17}, nodos{18}, Iv, Ev, Av);
elementos{8} = VigaColumna2D('V18-19', nodos{18}, nodos{19}, Iv, Ev, Av);
elementos{9} = VigaColumna2D('V19-110', nodos{19}, nodos{20}, Iv, Ev, Av);

% Piso 2
elementos{10} = VigaColumna2D('V21-22', nodos{21}, nodos{22}, Iv, Ev, Av);
elementos{11} = VigaColumna2D('V22-23', nodos{22}, nodos{23}, Iv, Ev, Av);
elementos{12} = VigaColumna2D('V23-24', nodos{23}, nodos{24}, Iv, Ev, Av);
elementos{13} = VigaColumna2D('V24-25', nodos{24}, nodos{25}, Iv, Ev, Av);
elementos{14} = VigaColumna2D('V25-26', nodos{25}, nodos{26}, Iv, Ev, Av);
elementos{15} = VigaColumna2D('V26-27', nodos{26}, nodos{27}, Iv, Ev, Av);
elementos{16} = VigaColumna2D('V27-28', nodos{27}, nodos{28}, Iv, Ev, Av);
elementos{17} = VigaColumna2D('V28-29', nodos{28}, nodos{29}, Iv, Ev, Av);
elementos{18} = VigaColumna2D('V29-210', nodos{29}, nodos{30}, Iv, Ev, Av);

% Piso 3
elementos{19} = VigaColumna2D('V31-32', nodos{31}, nodos{32}, Iv, Ev, Av);
elementos{20} = VigaColumna2D('V32-33', nodos{32}, nodos{33}, Iv, Ev, Av);
elementos{21} = VigaColumna2D('V33-34', nodos{33}, nodos{34}, Iv, Ev, Av);
elementos{22} = VigaColumna2D('V34-35', nodos{34}, nodos{35}, Iv, Ev, Av);
elementos{23} = VigaColumna2D('V35-36', nodos{35}, nodos{36}, Iv, Ev, Av);
elementos{24} = VigaColumna2D('V36-37', nodos{36}, nodos{37}, Iv, Ev, Av);
elementos{25} = VigaColumna2D('V37-38', nodos{37}, nodos{38}, Iv, Ev, Av);
elementos{26} = VigaColumna2D('V38-39', nodos{38}, nodos{39}, Iv, Ev, Av);
elementos{27} = VigaColumna2D('V39-310', nodos{39}, nodos{40}, Iv, Ev, Av);

% Piso 4
elementos{28} = VigaColumna2D('V41-42', nodos{41}, nodos{42}, Iv, Ev, Av);
elementos{29} = VigaColumna2D('V42-43', nodos{42}, nodos{43}, Iv, Ev, Av);
elementos{30} = VigaColumna2D('V43-44', nodos{43}, nodos{44}, Iv, Ev, Av);
elementos{31} = VigaColumna2D('V44-45', nodos{44}, nodos{45}, Iv, Ev, Av);
elementos{32} = VigaColumna2D('V45-46', nodos{45}, nodos{46}, Iv, Ev, Av);
elementos{33} = VigaColumna2D('V46-47', nodos{46}, nodos{47}, Iv, Ev, Av);
elementos{34} = VigaColumna2D('V47-48', nodos{47}, nodos{48}, Iv, Ev, Av);

% Piso 5
elementos{35} = VigaColumna2D('V51-52', nodos{49}, nodos{50}, Iv, Ev, Av);
elementos{36} = VigaColumna2D('V52-53', nodos{50}, nodos{51}, Iv, Ev, Av);
elementos{37} = VigaColumna2D('V53-54', nodos{51}, nodos{52}, Iv, Ev, Av);
elementos{38} = VigaColumna2D('V54-55', nodos{52}, nodos{53}, Iv, Ev, Av);
elementos{39} = VigaColumna2D('V55-56', nodos{53}, nodos{54}, Iv, Ev, Av);
elementos{40} = VigaColumna2D('V56-57', nodos{54}, nodos{55}, Iv, Ev, Av);
elementos{41} = VigaColumna2D('V57-58', nodos{55}, nodos{56}, Iv, Ev, Av);

% Piso 6
elementos{42} = VigaColumna2D('V61-62', nodos{57}, nodos{58}, Iv, Ev, Av);
elementos{43} = VigaColumna2D('V62-63', nodos{58}, nodos{59}, Iv, Ev, Av);
elementos{44} = VigaColumna2D('V63-64', nodos{59}, nodos{60}, Iv, Ev, Av);
elementos{45} = VigaColumna2D('V64-65', nodos{60}, nodos{61}, Iv, Ev, Av);
elementos{46} = VigaColumna2D('V65-66', nodos{61}, nodos{62}, Iv, Ev, Av);

% Piso 7
elementos{47} = VigaColumna2D('V71-72', nodos{63}, nodos{64}, Iv, Ev, Av);
elementos{48} = VigaColumna2D('V72-73', nodos{64}, nodos{65}, Iv, Ev, Av);
elementos{49} = VigaColumna2D('V73-74', nodos{65}, nodos{66}, Iv, Ev, Av);
elementos{50} = VigaColumna2D('V74-75', nodos{66}, nodos{67}, Iv, Ev, Av);
elementos{51} = VigaColumna2D('V75-76', nodos{67}, nodos{68}, Iv, Ev, Av);

% Piso 8
elementos{52} = VigaColumna2D('V81-82', nodos{69}, nodos{70}, Iv, Ev, Av);
elementos{53} = VigaColumna2D('V82-83', nodos{70}, nodos{71}, Iv, Ev, Av);
elementos{54} = VigaColumna2D('V83-84', nodos{71}, nodos{72}, Iv, Ev, Av);

% Piso 9
elementos{55} = VigaColumna2D('V91-92', nodos{73}, nodos{74}, Iv, Ev, Av);
elementos{56} = VigaColumna2D('V92-93', nodos{74}, nodos{75}, Iv, Ev, Av);
elementos{57} = VigaColumna2D('V93-94', nodos{75}, nodos{76}, Iv, Ev, Av);

% Piso 10
elementos{58} = VigaColumna2D('V101-102', nodos{77}, nodos{78}, Iv, Ev, Av);
elementos{59} = VigaColumna2D('V102-103', nodos{78}, nodos{79}, Iv, Ev, Av);
elementos{60} = VigaColumna2D('V103-104', nodos{79}, nodos{80}, Iv, Ev, Av);

% Piso 11
elementos{61} = VigaColumna2D('V111-112', nodos{81}, nodos{82}, Iv, Ev, Av);
elementos{62} = VigaColumna2D('V112-113', nodos{82}, nodos{83}, Iv, Ev, Av);
elementos{63} = VigaColumna2D('V113-114', nodos{83}, nodos{84}, Iv, Ev, Av);

% Piso 12
elementos{64} = VigaColumna2D('V121-122', nodos{85}, nodos{86}, Iv, Ev, Av);

elementos{65} = VigaColumna2D('V123-124', nodos{87}, nodos{88}, Iv, Ev, Av);

% Piso 13
elementos{66} = VigaColumna2D('V131-132', nodos{89}, nodos{90}, Iv, Ev, Av);

elementos{67} = VigaColumna2D('V133-134', nodos{91}, nodos{92}, Iv, Ev, Av);

% Piso 14
elementos{68} = VigaColumna2D('V141-142', nodos{93}, nodos{94}, Iv, Ev, Av);

elementos{69} = VigaColumna2D('V143-144', nodos{95}, nodos{96}, Iv, Ev, Av);

% Piso 15
elementos{70} = VigaColumna2D('V151-152', nodos{97}, nodos{98}, Iv, Ev, Av);
elementos{71} = VigaColumna2D('V152-153', nodos{98}, nodos{99}, Iv, Ev, Av);
elementos{72} = VigaColumna2D('V153-154', nodos{99}, nodos{100}, Iv, Ev, Av);

% Piso 16
elementos{73} = VigaColumna2D('V161-162', nodos{101}, nodos{102}, Iv, Ev, Av);
elementos{74} = VigaColumna2D('V162-163', nodos{102}, nodos{103}, Iv, Ev, Av);
elementos{75} = VigaColumna2D('V163-164', nodos{103}, nodos{104}, Iv, Ev, Av);

% Piso 17
elementos{76} = VigaColumna2D('V171-172', nodos{105}, nodos{106}, Iv, Ev, Av);
elementos{77} = VigaColumna2D('V172-173', nodos{106}, nodos{107}, Iv, Ev, Av);
elementos{78} = VigaColumna2D('V173-174', nodos{107}, nodos{108}, Iv, Ev, Av);

% Piso 18
elementos{79} = VigaColumna2D('V181-182', nodos{109}, nodos{110}, Iv, Ev, Av);
elementos{80} = VigaColumna2D('V182-183', nodos{110}, nodos{111}, Iv, Ev, Av);
elementos{81} = VigaColumna2D('V183-184', nodos{111}, nodos{112}, Iv, Ev, Av);

% Piso 19
elementos{82} = VigaColumna2D('V191-192', nodos{113}, nodos{114}, Iv, Ev, Av);

% Piso 20
elementos{83} = VigaColumna2D('V201-202', nodos{115}, nodos{116}, Iv, Ev, Av);


%% COLUMNAS
% Piso 0-1
elementos{84} = VigaColumna2D('C01-11', nodos{1}, nodos{11}, Ic, Ec, Ac);
elementos{85} = VigaColumna2D('C02-12', nodos{2}, nodos{12}, Ic, Ec, Ac);
elementos{86} = VigaColumna2D('C03-13', nodos{3}, nodos{13}, Ic, Ec, Ac);
elementos{87} = VigaColumna2D('C04-14', nodos{4}, nodos{14}, Ic, Ec, Ac);
elementos{88} = VigaColumna2D('C05-15', nodos{5}, nodos{15}, Ic, Ec, Ac);
elementos{89} = VigaColumna2D('C06-16', nodos{6}, nodos{16}, Ic, Ec, Ac);
elementos{90} = VigaColumna2D('C07-17', nodos{7}, nodos{17}, Ic, Ec, Ac);
elementos{91} = VigaColumna2D('C08-18', nodos{8}, nodos{18}, Ic, Ec, Ac);
elementos{92} = VigaColumna2D('C09-19', nodos{9}, nodos{19}, Ic, Ec, Ac);
elementos{93} = VigaColumna2D('C010-110', nodos{10}, nodos{20}, Ic, Ec, Ac);

% Piso 1-2
elementos{94} = VigaColumna2D('C11-21', nodos{11}, nodos{21}, Ic, Ec, Ac);
elementos{95} = VigaColumna2D('C12-22', nodos{12}, nodos{22}, Ic, Ec, Ac);
elementos{96} = VigaColumna2D('C13-23', nodos{13}, nodos{23}, Ic, Ec, Ac);
elementos{97} = VigaColumna2D('C14-24', nodos{14}, nodos{24}, Ic, Ec, Ac);
elementos{98} = VigaColumna2D('C15-25', nodos{15}, nodos{25}, Ic, Ec, Ac);
elementos{99} = VigaColumna2D('C16-26', nodos{16}, nodos{26}, Ic, Ec, Ac);
elementos{100} = VigaColumna2D('C17-27', nodos{17}, nodos{27}, Ic, Ec, Ac);
elementos{101} = VigaColumna2D('C18-28', nodos{18}, nodos{28}, Ic, Ec, Ac);
elementos{102} = VigaColumna2D('C19-29', nodos{19}, nodos{29}, Ic, Ec, Ac);
elementos{103} = VigaColumna2D('C110-210', nodos{20}, nodos{30}, Ic, Ec, Ac);

% Piso 2-3
elementos{104} = VigaColumna2D('C21-31', nodos{21}, nodos{31}, Ic, Ec, Ac);
elementos{105} = VigaColumna2D('C22-32', nodos{22}, nodos{32}, Ic, Ec, Ac);
elementos{106} = VigaColumna2D('C23-33', nodos{23}, nodos{33}, Ic, Ec, Ac);
elementos{107} = VigaColumna2D('C24-34', nodos{24}, nodos{34}, Ic, Ec, Ac);
elementos{108} = VigaColumna2D('C25-35', nodos{25}, nodos{35}, Ic, Ec, Ac);
elementos{109} = VigaColumna2D('C26-36', nodos{26}, nodos{36}, Ic, Ec, Ac);
elementos{110} = VigaColumna2D('C27-37', nodos{27}, nodos{37}, Ic, Ec, Ac);
elementos{111} = VigaColumna2D('C28-38', nodos{28}, nodos{38}, Ic, Ec, Ac);
elementos{112} = VigaColumna2D('C29-39', nodos{29}, nodos{39}, Ic, Ec, Ac);
elementos{113} = VigaColumna2D('C210-310', nodos{30}, nodos{40}, Ic, Ec, Ac);

% Piso 3-4
elementos{114} = VigaColumna2D('C32-41', nodos{31}, nodos{41}, Ic, Ec, Ac);
elementos{115} = VigaColumna2D('C33-42', nodos{32}, nodos{42}, Ic, Ec, Ac);
elementos{116} = VigaColumna2D('C34-43', nodos{33}, nodos{43}, Ic, Ec, Ac);
elementos{117} = VigaColumna2D('C35-44', nodos{34}, nodos{44}, Ic, Ec, Ac);
elementos{118} = VigaColumna2D('C36-45', nodos{35}, nodos{45}, Ic, Ec, Ac);
elementos{119} = VigaColumna2D('C37-46', nodos{36}, nodos{46}, Ic, Ec, Ac);
elementos{120} = VigaColumna2D('C38-47', nodos{37}, nodos{47}, Ic, Ec, Ac);
elementos{121} = VigaColumna2D('C39-48', nodos{38}, nodos{48}, Ic, Ec, Ac);

% Piso 4-5
elementos{122} = VigaColumna2D('C41-51', nodos{41}, nodos{49}, Ic, Ec, Ac);
elementos{123} = VigaColumna2D('C42-52', nodos{42}, nodos{50}, Ic, Ec, Ac);
elementos{124} = VigaColumna2D('C43-53', nodos{43}, nodos{51}, Ic, Ec, Ac);
elementos{125} = VigaColumna2D('C44-54', nodos{44}, nodos{52}, Ic, Ec, Ac);
elementos{126} = VigaColumna2D('C45-55', nodos{45}, nodos{53}, Ic, Ec, Ac);
elementos{127} = VigaColumna2D('C46-56', nodos{46}, nodos{54}, Ic, Ec, Ac);
elementos{128} = VigaColumna2D('C47-57', nodos{47}, nodos{55}, Ic, Ec, Ac);
elementos{129} = VigaColumna2D('C48-58', nodos{48}, nodos{56}, Ic, Ec, Ac);

% Piso 5-6
elementos{130} = VigaColumna2D('C52-61', nodos{50}, nodos{57}, Ic, Ec, Ac);
elementos{131} = VigaColumna2D('C53-62', nodos{51}, nodos{58}, Ic, Ec, Ac);
elementos{132} = VigaColumna2D('C54-63', nodos{52}, nodos{59}, Ic, Ec, Ac);
elementos{133} = VigaColumna2D('C55-64', nodos{53}, nodos{60}, Ic, Ec, Ac);
elementos{134} = VigaColumna2D('C56-65', nodos{54}, nodos{61}, Ic, Ec, Ac);
elementos{135} = VigaColumna2D('C57-66', nodos{55}, nodos{62}, Ic, Ec, Ac);

% Piso 6-7
elementos{136} = VigaColumna2D('C61-71', nodos{57}, nodos{63}, Ic, Ec, Ac);
elementos{137} = VigaColumna2D('C62-72', nodos{58}, nodos{64}, Ic, Ec, Ac);
elementos{138} = VigaColumna2D('C63-73', nodos{59}, nodos{65}, Ic, Ec, Ac);
elementos{139} = VigaColumna2D('C64-74', nodos{60}, nodos{66}, Ic, Ec, Ac);
elementos{140} = VigaColumna2D('C65-75', nodos{61}, nodos{67}, Ic, Ec, Ac);
elementos{141} = VigaColumna2D('C66-76', nodos{62}, nodos{68}, Ic, Ec, Ac);

% Piso 7-8
elementos{136} = VigaColumna2D('C72-81', nodos{64}, nodos{69}, Ic, Ec, Ac);
elementos{137} = VigaColumna2D('C73-82', nodos{65}, nodos{70}, Ic, Ec, Ac);
elementos{138} = VigaColumna2D('C74-83', nodos{66}, nodos{71}, Ic, Ec, Ac);
elementos{139} = VigaColumna2D('C75-84', nodos{67}, nodos{72}, Ic, Ec, Ac);

% Piso 8-9
elementos{140} = VigaColumna2D('C81-91', nodos{69}, nodos{73}, Ic, Ec, Ac);
elementos{141} = VigaColumna2D('C82-92', nodos{70}, nodos{74}, Ic, Ec, Ac);
elementos{142} = VigaColumna2D('C83-93', nodos{71}, nodos{75}, Ic, Ec, Ac);
elementos{143} = VigaColumna2D('C84-94', nodos{72}, nodos{76}, Ic, Ec, Ac);

% Piso 9-10
elementos{144} = VigaColumna2D('C91-101', nodos{73}, nodos{77}, Ic, Ec, Ac);
elementos{145} = VigaColumna2D('C92-102', nodos{74}, nodos{78}, Ic, Ec, Ac);
elementos{146} = VigaColumna2D('C93-103', nodos{75}, nodos{79}, Ic, Ec, Ac);
elementos{147} = VigaColumna2D('C94-104', nodos{76}, nodos{80}, Ic, Ec, Ac);

% Piso 10-11
elementos{148} = VigaColumna2D('C101-111', nodos{77}, nodos{81}, Ic, Ec, Ac);
elementos{149} = VigaColumna2D('C102-112', nodos{78}, nodos{82}, Ic, Ec, Ac);
elementos{150} = VigaColumna2D('C103-113', nodos{79}, nodos{83}, Ic, Ec, Ac);
elementos{151} = VigaColumna2D('C104-114', nodos{80}, nodos{84}, Ic, Ec, Ac);

% Piso 11-12
elementos{152} = VigaColumna2D('C111-121', nodos{81}, nodos{85}, Ic, Ec, Ac);
elementos{153} = VigaColumna2D('C112-122', nodos{82}, nodos{86}, Ic, Ec, Ac);
elementos{154} = VigaColumna2D('C113-123', nodos{83}, nodos{87}, Ic, Ec, Ac);
elementos{155} = VigaColumna2D('C114-124', nodos{84}, nodos{88}, Ic, Ec, Ac);

% Piso 12-13
elementos{156} = VigaColumna2D('C121-131', nodos{85}, nodos{89}, Ic, Ec, Ac);
elementos{157} = VigaColumna2D('C122-132', nodos{86}, nodos{90}, Ic, Ec, Ac);
elementos{158} = VigaColumna2D('C123-133', nodos{87}, nodos{91}, Ic, Ec, Ac);
elementos{159} = VigaColumna2D('C124-134', nodos{88}, nodos{92}, Ic, Ec, Ac);

% Piso 13-14
elementos{160} = VigaColumna2D('C131-141', nodos{89}, nodos{93}, Ic, Ec, Ac);
elementos{161} = VigaColumna2D('C132-142', nodos{90}, nodos{94}, Ic, Ec, Ac);
elementos{162} = VigaColumna2D('C133-143', nodos{91}, nodos{95}, Ic, Ec, Ac);
elementos{163} = VigaColumna2D('C134-144', nodos{92}, nodos{96}, Ic, Ec, Ac);

% Piso 14-15
elementos{164} = VigaColumna2D('C141-151', nodos{93}, nodos{97}, Ic, Ec, Ac);
elementos{165} = VigaColumna2D('C142-152', nodos{94}, nodos{98}, Ic, Ec, Ac);
elementos{166} = VigaColumna2D('C143-153', nodos{95}, nodos{99}, Ic, Ec, Ac);
elementos{167} = VigaColumna2D('C144-154', nodos{96}, nodos{100}, Ic, Ec, Ac);

% Piso 15-16
elementos{168} = VigaColumna2D('C151-161', nodos{97}, nodos{101}, Ic, Ec, Ac);
elementos{169} = VigaColumna2D('C152-162', nodos{98}, nodos{102}, Ic, Ec, Ac);
elementos{170} = VigaColumna2D('C153-163', nodos{99}, nodos{103}, Ic, Ec, Ac);
elementos{171} = VigaColumna2D('C154-164', nodos{100}, nodos{104}, Ic, Ec, Ac);

% Piso 16-17
elementos{172} = VigaColumna2D('C161-171', nodos{101}, nodos{105}, Ic, Ec, Ac);
elementos{173} = VigaColumna2D('C162-172', nodos{102}, nodos{106}, Ic, Ec, Ac);
elementos{174} = VigaColumna2D('C163-173', nodos{103}, nodos{107}, Ic, Ec, Ac);
elementos{175} = VigaColumna2D('C164-174', nodos{104}, nodos{108}, Ic, Ec, Ac);

% Piso 17-18
elementos{172} = VigaColumna2D('C171-181', nodos{105}, nodos{109}, Ic, Ec, Ac);
elementos{173} = VigaColumna2D('C172-182', nodos{106}, nodos{110}, Ic, Ec, Ac);
elementos{174} = VigaColumna2D('C173-183', nodos{107}, nodos{111}, Ic, Ec, Ac);
elementos{175} = VigaColumna2D('C174-184', nodos{108}, nodos{112}, Ic, Ec, Ac);

% Piso 18-19
elementos{176} = VigaColumna2D('C182-191', nodos{110}, nodos{113}, Ic, Ec, Ac);
elementos{177} = VigaColumna2D('C183-192', nodos{111}, nodos{114}, Ic, Ec, Ac);

% Piso 19-20
elementos{178} = VigaColumna2D('C191-201', nodos{113}, nodos{115}, Ic, Ec, Ac);
elementos{179} = VigaColumna2D('C192-202', nodos{114}, nodos{116}, Ic, Ec, Ac);