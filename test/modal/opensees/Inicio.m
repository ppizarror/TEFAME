clear all; %#ok<*CLALL>
clc;
close all;
tic
system(['OpenSees.exe<', '00.Start.tcl']);
toc

%% Cosas utiles: Resumenes, Lugares de Estudio, relacion de archivos txt respecto a NodeID Posicion de los Disipadores
tic
CaseOfStudy = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Caso de Estudio de Disipadores %%%%%%%%%%%%%%%%%% Ver Figura %%%%%%%%%%%%%%%%%%
%0: Sin nada
%1,2,3,4,5

Lugar_Tex = {'Angol', 'Concepci\''on', 'Constituci\''on', 'Curic\''o', 'Matanzas', 'Mirador', 'Vi\~na del Mar'};
Lugar = {'Angol', 'Concepcion', 'Constitucion', 'Curico', 'Matanzas', 'Mirador', 'Vina'};
Folder = {'Data\Angol', 'Data\Concepcion', 'Data\Constitucion', 'Data\Curico', 'Data\Matanzas', 'Data\Mirador', 'Data\Vina'};

QMaxSummary = zeros(length(Lugar), 1); % filas registros: Angol Concepcion Constitucion Curico Matanzas Mirador Vina,
CMaxSummary = zeros(length(Lugar), 1); % columnas pisos: Base CP1 CP2 CP3 CP4 CP5
AcelAbsSummary = zeros(length(Lugar), 6);
DMaxAbsSummary = zeros(length(Lugar), 6);
DriftTransSummary = zeros(length(Lugar), 5);
DriftPermSummary = zeros(length(Lugar), 5);

NBay = 9;
NStory = 5;
N_Nodes = (NBay + 1) * 2 * (NStory + 1);
Relation_Nodes = zeros(length(N_Nodes), 2); % Crear relacion entre el nodo y su columna en archivos.out
ContNode = 0;
for i_piso = 1:NStory + 1
    for j_vano = 1:2 * (NBay + 1)
        ContNode = ContNode + 1; % Contador de numero de nodos
        Node = i_piso * 100 + j_vano;
        if Node <= 199
            Relation_Nodes(ContNode, :) = [Node, 0]; % Nodo Columna en el txt, 0 si no existe  %registros de velocidades parten desde el nodo 201
        else
            Relation_Nodes(ContNode, :) = [Node(i_piso-2) * 20 + j_vano + 1]; %#ok<*NBRAK>
        end
    end
end

%% Disipadores
if CaseOfStudy ~= 0
    if CaseOfStudy == 1
        NodeDisi(1, :) = [104, 305]; % Columna1 NodoInicial Columna2 NodoFinal
        NodeDisi(2, :) = [304, 505];
        NodeDisi(3, :) = [107, 306];
        NodeDisi(4, :) = [307, 506];
    elseif CaseOfStudy == 2
        NodeDisi(1, :) = [104, 205];
        NodeDisi(2, :) = [204, 305];
        NodeDisi(3, :) = [304, 405];
        NodeDisi(4, :) = [404, 505];
        NodeDisi(5, :) = [504, 605];
        NodeDisi(6, :) = [107, 206];
        NodeDisi(7, :) = [207, 306];
        NodeDisi(8, :) = [307, 406];
        NodeDisi(9, :) = [407, 506];
        NodeDisi(10, :) = [507, 606];
    elseif CaseOfStudy == 3
        NodeDisi(1, :) = [104, 305];
        NodeDisi(2, :) = [304, 605];
        NodeDisi(3, :) = [107, 306];
        NodeDisi(4, :) = [307, 606];
    elseif CaseOfStudy == 4
        NodeDisi(1, :) = [102, 301];
        NodeDisi(2, :) = [302, 501];
        NodeDisi(3, :) = [109, 310];
        NodeDisi(4, :) = [309, 510];
    elseif CaseOfStudy == 5
        NodeDisi(1, :) = [104, 205];
        NodeDisi(2, :) = [204, 405];
        NodeDisi(3, :) = [404, 605];
        NodeDisi(4, :) = [107, 206];
        NodeDisi(5, :) = [207, 406];
        NodeDisi(6, :) = [407, 606];
    end
    N_Disi = size(NodeDisi, 1); % Numero de disipadores
    ForceDisiSummary = zeros(length(Lugar), N_Disi);
    VeloDisiSummary = zeros(length(Lugar), N_Disi);
    DispDisiSummary = zeros(length(Lugar), N_Disi);
    EngVisSummary = zeros(length(Lugar), 1);
    tSummary = zeros(length(Lugar), 1);
    
    ColHingeAbove = zeros(length(Lugar), ((NBay + 1) * NStory));
    BeamHingeRight = zeros(length(Lugar), ((NBay) * NStory));
    ColHingeBelow = zeros(length(Lugar), ((NBay + 1) * NStory));
    BeamHingeLeft = zeros(length(Lugar), ((NBay) * NStory));
    
    PerfColHingeAbove = cell(size(ColHingeAbove));
    PerfBeamHingeRight = cell(size(BeamHingeRight));
    PerfColHingeBelow = cell(size(ColHingeBelow));
    PerfBeamHingeLeft = cell(size(BeamHingeLeft));
end

%% Import Data
for j = 3 %length(Lugar)
    Data = Folder{3};
    FS = 200; % Frecuencia de muestreo
    R_Spr_i = importdata(fullfile(Data, 'R_Spr_i.out'));
    R_Spr_j = importdata(fullfile(Data, 'R_Spr_j.out'));
    M_Spr_i = importdata(fullfile(Data, 'M_Spr_i.out'));
    M_Spr_j = importdata(fullfile(Data, 'M_Spr_j.out'));
    NodesAbsAcel = importdata(fullfile(Data, 'Nodes_AbsAcel.out'));
    NodesRelAcel = importdata(fullfile(Data, 'Nodes_RelAcel.out'));
    NodesDisp = importdata(fullfile(Data, 'Nodes_Disp.out'));
    NodesVelo = importdata(fullfile(Data, 'Nodes_Velo.out'));
    NodesDForce = importdata(fullfile(Data, 'Nodes_Damp.out'));
    NodesBaseAcel = importdata(fullfile(Data, 'Nodes_BaseAcel.out'));
    
    Drift01 = importdata(fullfile(Data, 'Drift01.out'));
    Drift12 = importdata(fullfile(Data, 'Drift12.out'));
    Drift23 = importdata(fullfile(Data, 'Drift23.out'));
    Drift34 = importdata(fullfile(Data, 'Drift34.out'));
    Drift45 = importdata(fullfile(Data, 'Drift45.out'));
    BaseReac = importdata(fullfile(Data, 'Elem_Forces.out'));
    if CaseOfStudy ~= 0
        DisiForces = importdata(fullfile(Data, 'ViscDampforce.out')); %%%%%%%%%%%VISC DAMPER FORCES
        DisiDef = importdata(fullfile(Data, 'ViscDef.out')); %%%%%%%%%%%VISC DAMPER DISP. ViscDef.out
    end
    
    R_Spr = [R_Spr_i, R_Spr_j(:, 2:end)];
    M_Spr = [M_Spr_i, M_Spr_j(:, 2:end)];
    
    %% Evaluacion de desempeno
    R_SprMax_i = max(abs(R_Spr_i));
    R_SprMax_j = max(abs(R_Spr_j));
    for i = 1:NStory
        ColHingeAbove(j, (i + (i - 1) * (NBay)):(i * (NBay + 1))) = R_SprMax_i((2 + (i - 1) * (NBay + 1) * 2):(NBay * (2 * i - 1) + 2 * i));
        BeamHingeRight(j, (i + (i - 1) * (NBay - 1)):(i * NBay)) = R_SprMax_i((2 * (NBay + 1) * NStory + 2 + (i - 1) * 2 * NBay):(2 * (NBay + 1) * NStory + 2 + (i - 1) * 2 * NBay + (NBay - 1)));
        ColHingeBelow(j, (i + (i - 1) * (NBay)):(i * (NBay + 1))) = R_SprMax_j((2 + (i - 1) * (NBay + 1) * 2):(NBay * (2 * i - 1) + 2 * i));
        BeamHingeLeft(j, (i + (i - 1) * (NBay - 1)):(i * NBay)) = R_SprMax_j((2 * (NBay + 1) * NStory + 2 + (i - 1) * 2 * NBay):(2 * (NBay + 1) * NStory + 2 + (i - 1) * 2 * NBay + (NBay - 1)));
        
    end
    
    for i = 1:(NBay + 1) * NStory
        if ColHingeAbove(j, i) < 0.0045
            PerfColHingeAbove{j, i} = 'IO';
        elseif ColHingeAbove(j, i) > 0.0045 && ColHingeAbove(j, i) <= 0.0065
            PerfColHingeAbove{j, i} = 'LS';
        elseif ColHingeAbove(j, i) > 0.0065
            PerfColHingeAbove{j, i} = 'CP';
        end
        
        if ColHingeBelow(j, i) <= 0.0045
            PerfColHingeBelow{j, i} = 'IO';
        elseif ColHingeBelow(j, i) > 0.0045 && ColHingeBelow(j, i) <= 0.0065
            PerfColHingeBelow{j, i} = 'LS';
        else % >0.0065
            PerfColHingeBelow{j, i} = 'CP';
        end
    end
    
    for i = 1:(NBay) * NStory
        if BeamHingeRight(j, i) <= 0.0045
            PerfBeamHingeRight{j, i} = 'IO';
        elseif BeamHingeRight(j, i) > 0.0045 && BeamHingeRight(j, i) <= 0.0065
            PerfBeamHingeRight{j, i} = 'LS';
        elseif BeamHingeRight(j, i) > 0.0065
            PerfBeamHingeRight{j, i} = 'CP';
        end
        
        if BeamHingeLeft(j, i) <= 0.0045
            PerfBeamHingeLeft{j, i} = 'IO';
        elseif BeamHingeLeft(j, i) > 0.0045 && BeamHingeLeft(j, i) <= 0.0065
            PerfBeamHingeLeft{j, i} = 'LS';
        else % >0.0065
            PerfBeamHingeLeft{j, i} = 'CP';
        end
    end
    
    %% Histeresis - Incursion Inelastica
    pt = figure();
    hold on
    plot(R_Spr(:, 2:end), M_Spr(:, 2:end)./100000);
    
    IOp = plot([0.0025, 0.0025], [-450, 450], 'g--');
    LSp = plot([0.0045, 0.0045], [-450, 450], 'y--');
    CPp = plot([0.0065, 0.0065], [-450, 450], 'r--');
    IOn = plot([-0.0025, -0.0025], [-450, 450], 'g--');
    LSn = plot([-0.0045, -0.0045], [-450, 450], 'y--');
    CPn = plot([-0.0065, -0.0065], [-450, 450], 'r--');
    hold off
    set(legend([IOp, LSp, CPp], {'I.O.', 'L.S.', 'C.P.'}), 'Interpreter', 'LaTex');
    grid on
    title(['Incursi\''on Inel\''astica. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    ylabel('M [tonf-m]', 'Interpreter', 'LaTex')
    xlabel('$\theta$ [rad]', 'Interpreter', 'LaTex')
    saveas(pt, fullfile(Data, [Lugar{j}, ' Incursion Inelastica']))
    
    %% Aceleraciones Absolutas
    t = NodesAbsAcel(:, 1);
    AcelAbsP2 = NodesAbsAcel(:, 2);
    AcelAbsP3 = NodesAbsAcel(:, 22);
    AcelAbsP4 = NodesAbsAcel(:, 42);
    AcelAbsP5 = NodesAbsAcel(:, 62);
    AcelAbsP6 = NodesAbsAcel(:, 82);
    
    H = zeros(1, 6);
    for i = 1:5
        if i == 1
            H(i+1) = 5.5;
        else
            H(i+1) = H(i) + 4;
        end
    end
    
    pt = figure();
    subplot(3, 1, 1)
    plot(t, AcelAbsP2./981)
    grid on
    title(['Aceleraciones 2$^\circ$ Piso. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    ylabel('Aceleraci\''on [g]', 'Interpreter', 'LaTex')
    xlabel('Tiempo [s]', 'Interpreter', 'LaTex')
    
    subplot(3, 1, 2)
    plot(t, AcelAbsP3./981)
    grid on
    title(['Aceleraciones 3$^r$ Piso. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    ylabel('Aceleraci\''on [g]', 'Interpreter', 'LaTex')
    xlabel('Tiempo [s]', 'Interpreter', 'LaTex')
    
    subplot(3, 1, 3)
    plot(t, AcelAbsP4./981)
    grid on
    title(['Aceleraciones 4$^\circ$ Piso. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    ylabel('Aceleraci\''on [g]', 'Interpreter', 'LaTex')
    xlabel('Tiempo [s]', 'Interpreter', 'LaTex')
    saveas(pt, fullfile(Data, [Lugar{j}, ' Aceleraciones Piso parte 1']))
    pt = figure();
    
    subplot(3, 1, 1)
    plot(t, AcelAbsP5./981)
    grid on
    title(['Aceleraciones 5$^\circ$ Piso. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    ylabel('Aceleraci\''on [g]', 'Interpreter', 'LaTex')
    xlabel('Tiempo [s]', 'Interpreter', 'LaTex')
    
    subplot(3, 1, 2)
    plot(t, AcelAbsP6./981)
    grid on
    title(['Aceleraciones de Techo. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    ylabel('Aceleraci\''on [g]', 'Interpreter', 'LaTex')
    xlabel('Tiempo [s]', 'Interpreter', 'LaTex')
    
    saveas(pt, fullfile(Data, [Lugar{j}, ' Aceleraciones Piso parte 2']))
    
    pt = figure();
    A = [max(abs(NodesBaseAcel(:, 2))); max(abs(AcelAbsP2)); max(abs(AcelAbsP3)); max(abs(AcelAbsP4)); max(abs(AcelAbsP5)); max(abs(AcelAbsP6))] ./ 981;
    plot(A, H, 'k-*')
    
    grid on
    title(['Aceleraciones Absolutas M\''aximas. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    ylabel('Altura [m]', 'Interpreter', 'LaTex')
    xlabel('Aceleraci\''on [g]', 'Interpreter', 'LaTex')
    
    saveas(pt, fullfile(Data, [Lugar{j}, ' Aceleraciones Absolutas Maximas']))
    
    AcelAbsSummary(j, :) = A'; % Guardado para Resumen unidades en g
    
    %% Cortes Basales
    load MASA;
    Peso = sum(MASA) * 981;
    t = BaseReac(:, 1);
    CorteBasal = sum(BaseReac(:, 2:end), 2);
    pt = figure();
    plot(t, CorteBasal./1000)
    grid on
    title(['Historia de Corte Basal. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    ylabel('Cortante Basal [tonf]', 'Interpreter', 'LaTex')
    xlabel('Tiempo [s]', 'Interpreter', 'LaTex')
    
    saveas(pt, fullfile(Data, [Lugar{j}, ' Historia de Corte Basal']))
    QMaxSummary(j) = max(abs(CorteBasal./1000)); % Guardado para Resumen en tonf
    
    pt = figure();
    plot(t, CorteBasal./Peso)
    grid on
    title(['Tiempo-Historia de Coef. S\''ismico. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    ylabel('Coef.S\''smico.', 'Interpreter', 'LaTex')
    xlabel('Tiempo [s]', 'Interpreter', 'LaTex')
    
    saveas(pt, fullfile(Data, [Lugar{j}, ' Tiempo Historia de CS']))
    CMaxSummary(j) = max(abs(CorteBasal./Peso)); % Guardado para Resumen sin unidades.
    
    %% Desplazamientos
    DispP2 = NodesDisp(:, 2);
    DispP3 = NodesDisp(:, 22);
    DispP4 = NodesDisp(:, 42);
    DispP5 = NodesDisp(:, 62);
    DispP6 = NodesDisp(:, 82);
    
    pt = figure();
    D = [0; max(abs(DispP2)); max(abs(DispP3)); max(abs(DispP4)); max(abs(DispP5)); max(abs(DispP6))];
    plot(D, H, 'k-*')
    
    grid on
    title(['Desplazamientos M\''aximos. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    ylabel('Altura [m]', 'Interpreter', 'LaTex')
    xlabel('Desplazamiento [cm]', 'Interpreter', 'LaTex')
    
    saveas(pt, fullfile(Data, [Lugar{j}, ' Desplazamientos Maximos']))
    DMaxAbsSummary(j, :) = D'; % Guardado para Resumen unidades en cm
    
    %% Drifts (Transientes y Remanentes)
    DMAX01 = max(abs(Drift01(:, 2)));
    DMAX12 = max(abs(Drift12(:, 2)));
    DMAX23 = max(abs(Drift23(:, 2)));
    DMAX34 = max(abs(Drift34(:, 2)));
    DMAX45 = max(abs(Drift45(:, 2)));
    DPERM01 = abs(Drift01(size(Drift01, 1), 2));
    DPERM12 = abs(Drift12(size(Drift12, 1), 2));
    DPERM23 = abs(Drift23(size(Drift23, 1), 2));
    DPERM34 = abs(Drift34(size(Drift34, 1), 2));
    DPERM45 = abs(Drift45(size(Drift45, 1), 2));
    
    H_der = zeros(1, 2*length(H)-1);
    for i = 1:length(H)
        if i == 1
            H_der(i) = H(i);
        else
            H_der(2*i-2) = H(i);
            H_der(2*i-1) = H(i);
        end
    end
    
    DMAX = [DMAX01; DMAX01; DMAX12; DMAX12; DMAX23; DMAX23; DMAX34; DMAX34; DMAX45; DMAX45; 0] .* 1000;
    DPERM = [DPERM01; DPERM01; DPERM12; DPERM12; DPERM23; DPERM23; DPERM34; DPERM34; DPERM45; DPERM45; 0] .* 1000;
    pt = figure();
    plot(DMAX, H_der, 'k-*')
    
    grid on
    title(['Drifts M\''aximos. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    ylabel('Altura [m]', 'Interpreter', 'LaTex')
    xlabel('Drift [\%$_{0}$]', 'Interpreter', 'LaTex')
    
    saveas(pt, fullfile(Data, [Lugar{j}, ' Drifts Maximos']))
    pt = figure();
    plot(DPERM, H_der, 'k-*')
    
    grid on
    title(['Drifts Permanentes. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    ylabel('Altura [m]', 'Interpreter', 'LaTex')
    xlabel('Drift [\%$_{0}$]', 'Interpreter', 'LaTex')
    
    saveas(pt, fullfile(Data, [Lugar{j}, ' Drifts Permanentes']))
    DriftTransSummary(j, :) = [DMAX01, DMAX12, DMAX23, DMAX34, DMAX45] .* 1000; % Guardado para Resumen unidades \permil
    DriftPermSummary(j, :) = [DPERM01, DPERM12, DPERM23, DPERM34, DPERM45] .* 1000; % Guardado para Resumen unidades \permil
    
    %% Velocidades y desplazamiento de los disipadores
    if CaseOfStudy ~= 0 % Casos segun la configuracion de los disipadores
        t = NodesVelo(:, 1);
        DisiVelo = zeros(length(t), N_Disi);
        DisiDisp = zeros(length(t), N_Disi);
        
        for k = 1:N_Disi
            NodeDisi_i = NodeDisi(k, 1);
            NodeDisi_j = NodeDisi(k, 2);
            i_RN = find(NodeDisi_i == Relation_Nodes(:, 1));
            j_RN = find(NodeDisi_j == Relation_Nodes(:, 1));
            i_txt = Relation_Nodes(i_RN, 2);
            j_txt = Relation_Nodes(j_RN, 2);
            
            if NodeDisi_i <= 199
                DisiVelo(:, k) = NodesVelo(:, j_txt);
                DisiDisp(:, k) = NodesDisp(:, j_txt);
            else
                DisiVelo(:, k) = NodesVelo(:, j_txt) - NodesVelo(:, i_txt);
                DisiDisp(:, k) = NodesDisp(:, j_txt) - NodesDisp(:, i_txt);
            end
            
            VeloDisiSummary(j, k) = max(abs(DisiVelo(:, k))); % Guardado para Resumen unidades cm/s
            DispDisiSummary(j, k) = max(abs(DisiDisp(:, k))); % Guardado para Resumen unidades cm
            ForceDisiSummary(j, k) = max(abs(DisiForces(:, k+1))) / 1000; % Corre en una columna (k+1) debido al tiempo en la primera
            tSummary(j) = t(length(t));
        end % Guardado para Resumen unidades tonf
        
        pt = figure();
        plot(t, DisiVelo)
        grid on
        title(['Velocidad Relativa de los Disipadores. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
        ylabel('Velocidad [cm/s]', 'Interpreter', 'LaTex')
        xlabel('Tiempo [s]', 'Interpreter', 'LaTex')
        
        saveas(pt, fullfile(Data, [Lugar{j}, ' Velocidad de los Disipadores']))
        
        pt = figure();
        grid on
        hold on
        for k = 1:N_Disi
            plot(DisiVelo(:, k), DisiForces(:, k+1)./1000)
        end
        title(['Fuerza versus velocidad de los Disipadores. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
        xlabel('Velocidad [cm/s]', 'Interpreter', 'LaTex')
        ylabel('Fuerza [tonf]', 'Interpreter', 'LaTex')
        saveas(pt, fullfile(Data, [Lugar{j}, ' Fuerza-Velocidad']))
        
        pt = figure();
        grid on
        hold on
        for k = 1:N_Disi
            plot(DisiDisp(:, k), DisiForces(:, k+1)./1000)
        end
        title(['Fuerza versus desplazamiento de los Disipadores. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
        xlabel('Desplazamiento [cm]', 'Interpreter', 'LaTex')
        ylabel('Fuerza [tonf]', 'Interpreter', 'LaTex')
        saveas(pt, fullfile(Data, [Lugar{j}, ' Fuerza-Desplazamiento']))
    end
    
    %% Cuantificaci�n de Energia
    
    t = NodesDisp(:, 1);
    n = size(t, 1);
    
    %% Energia Histeretica
    M = M_Spr(:, 2:end);
    R = R_Spr(:, 2:end);
    N = size(M, 2);
    Ea = zeros(n, N);
    for i = 2:n
        Ea(i, :) = (Ea(i-1, :)) + (R(i, :) - R(i-1, :)) .* ((M(i, :) + M(i-1, :)) ./ 2);
    end
    Ea = sum(Ea')'; %#ok<*UDIM>
    
    %% Energ�a Kinetica Ek
    Ek = zeros(n, 1);
    for i = 2:n
        Ek(i) = 0.5 .* sum((NodesVelo(i, 2:end).^2).*MASA');
    end
    
    %% Energia Ingresada al Sistema Eeq y Energia Disipada Ed (Rayleigh)
    Eeq = zeros(n, 1);
    Ed = zeros(n, 1);
    Evda = zeros(n, 1);
    
    xg = NodesBaseAcel(:, 2);
    
    for i = 2:n
        Eeq(i) = Eeq(i-1) - sum((NodesDisp(i, 2:end) - NodesDisp(i-1, 2:end)).*(0.5 * MASA' .* (xg(i-1) + xg(i))));
        Ed(i) = Ed(i-1) + ((NodesDisp(i, 2:end) - NodesDisp(i-1, 2:end)) * NodesDForce(i, 2:end)');
        Evda(i) = Evda(i-1) + ((DisiDef(i, 2:end) - DisiDef(i-1, 2:end)) * DisiForces(i, 2:end)');
    end
    Eeq = abs(Eeq);
    EngVisSummary(j) = Evda(length(Evda)) ./ 100000; % Guardado para resumen Unidades [Tonf*m]
    
    %%
    pt = figure();
    hold on
    plot(t, Eeq./100000, 'k')
    plot(t, Ek./100000, 'b')
    plot(t, Ed./100000, 'y')
    plot(t, Ea./100000, 'r')
    plot(t, Evda./100000, 'g')
    plot(t, abs(-Ek-Ed-Ea-Evda)./100000, 'k:')
    title(['Balance de Energ\''ia. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    xlabel('Tiempo [s]', 'Interpreter', 'LaTex')
    ylabel('Energ\''ia [Tonf-m]', 'Interpreter', 'LaTex')
    set(legend('E Input', 'Ek', 'Edv', 'Ea', 'Evda', 'Ek+Edv+Ea+Evda', 'Location', 'northwest'), 'Interpreter', 'LaTex')
    % set(legend('E Input','Ek','Ev','Ea','Edv','Ek+Ev+Ea+Edv','Location','northwest'),'Interpreter','LaTex')
    grid on
    hold off
    
    saveas(pt, fullfile(Data, [Lugar{j}, ' Balance de Energia']))
    
    %%
    pt = figure();
    hold on
    plot(t, 100*abs(Eeq-Ek-Ed-Ea-Evda)./abs(Eeq), 'k')
    plot([0, max(t)], [5, 5], 'r--')
    title(['Balance Error. Registro ', Lugar_Tex{j}, '.'], 'Interpreter', 'LaTex')
    ylabel('E.B.E. [\%]', 'Interpreter', 'LaTex')
    xlabel('Tiempo [s]', 'Interpreter', 'LaTex')
    hold off
    axis([0, max(t) + 5, 0, 50])
    grid on
    
    saveas(pt, fullfile(Data, [Lugar{j}, ' Balance Error']))
    
    close all;
end

%% Performance promedio
AveColHingeAbove = mean(ColHingeAbove);
AveBeamHingeRight = mean(BeamHingeRight);
AveColHingeBelow = mean(ColHingeBelow);
AveBeamHingeLeft = mean(BeamHingeLeft);

AvePerfColHingeAbove = cell(size(AveColHingeAbove));
AvePerfBeamHingeRight = cell(size(AveBeamHingeRight));
AvePerfColHingeBelow = cell(size(AveColHingeBelow));
AvePerfBeamHingeLeft = cell(size(AveBeamHingeLeft));

for i = 1:(NBay + 1) * NStory
    if AveColHingeAbove(i) < 0.0045
        AvePerfColHingeAbove{i} = 'IO';
    elseif AveColHingeAbove(i) > 0.0045 && AveColHingeAbove(i) <= 0.0065
        AvePerfColHingeAbove{i} = 'LS';
    elseif AveColHingeAbove(i) > 0.0065
        AvePerfColHingeAbove{i} = 'CP';
    end
    
    if AveColHingeBelow(i) <= 0.0045
        AvePerfColHingeBelow{i} = 'IO';
    elseif AveColHingeBelow(i) > 0.0045 && AveColHingeBelow(i) <= 0.0065
        AvePerfColHingeBelow{i} = 'LS';
    else % >0.0065;
        AvePerfColHingeBelow{i} = 'CP';
    end
end

for i = 1:(NBay) * NStory
    if BeamHingeRight(i) <= 0.0045
        AvePerfBeamHingeRight{i} = 'IO';
    elseif BeamHingeRight(i) > 0.0045 && BeamHingeRight(i) <= 0.0065
        AvePerfBeamHingeRight{i} = 'LS';
    elseif BeamHingeRight(i) > 0.0065
        AvePerfBeamHingeRight{i} = 'CP';
    end
    
    if BeamHingeLeft(i) <= 0.0045
        AvePerfBeamHingeLeft{i} = 'IO';
    elseif BeamHingeLeft(i) > 0.0045 && BeamHingeLeft(i) <= 0.0065
        AvePerfBeamHingeLeft{i} = 'LS';
    else % >0.0065
        AvePerfBeamHingeLeft{i} = 'CP';
    end
end

%% Guardado de Summary
if CaseOfStudy == 0
    save('Data\Summary.mat', 'QMaxSummary', 'CMaxSummary', 'AcelAbsSummary', 'DMaxAbsSummary', 'DriftTransSummary', 'DriftPermSummary', 'tSummary', 'PerfColHingeAbove', 'PerfBeamHingeRight', 'PerfColHingeBelow', 'PerfBeamHingeLeft', 'AvePerfColHingeAbove', 'AvePerfBeamHingeRight', 'AvePerfColHingeBelow', 'AvePerfBeamHingeLeft')
else
    save('Data\Summary.mat', 'QMaxSummary', 'CMaxSummary', 'AcelAbsSummary', 'DMaxAbsSummary', 'DriftTransSummary', 'DriftPermSummary', 'ForceDisiSummary', 'VeloDisiSummary', 'DispDisiSummary', 'EngVisSummary', 'tSummary', 'PerfColHingeAbove', 'PerfBeamHingeRight', 'PerfColHingeBelow', 'PerfBeamHingeLeft', 'AvePerfColHingeAbove', 'AvePerfBeamHingeRight', 'AvePerfColHingeBelow', 'AvePerfBeamHingeLeft');
end
toc;