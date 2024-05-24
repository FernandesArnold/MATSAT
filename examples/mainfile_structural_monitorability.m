clc; clear all; close all;
global BrBG
BrBG = [84	48	5
    140	81	10
    191	129	45
    223	194	125
    246	232	195
    245	245	245
    199	234	229
    128	205	193
    53	151	143
    1	102	94
    0	60	48]/255; % 11-color brown-bluegreen Brewer diverging map
global PiYG
PiYG = [142	1	82;
    197	27	125;
    222	119	174;
    241	182	218;
    253	224	239;
    247	247	247;
    230	245	208;
    184	225	134;
    127	188	65;
    77	146	33;
    39	100	25]/255; % 11-color pink-yellow-green Brewer diverging map
global PRGn
PRGn = [64	0	75;
    118	42	131;
    153	112	171;
    194	165	207;
    231	212	232;
    247	247	247;
    217	240	211;
    166	219	160;
    90	174	97;
    27	120	55;
    0	68	27]/255; % 11-color purple-green Brewer diverging map
global YlGnBu
YlGnBu = [255	255	217;
    237	248	177;
    199	233	180;
    127	205	187;
    65	182	196;
    29	145	192;
    34	94	168;
    37	52	148;
    8	29	88]/255; % 9-color yellow-green-blue Brewer sequential map
global Wong
Wong = [0 0 0;
    35,70,90;
    0,60,50;
    95,90,25;
    0,45,70;
    80,40,0]/100; % 6-color palette adapted from http://mkweb.bcgsc.ca/colorblind/img/colorblindness.palettes.trivial.png

set(groot,'DefaultFigureColormap',BrBG);
set(groot,'DefaultAxesColorOrder',Wong);
set(groot,'DefaultPolarAxesColorOrder',Wong);

SE = 1;
SF = 2;
C = 3;
I = 4;
R = 5;
ONE = 6;
ZERO = 7;
TF = 8;
GY = 9;
DE = 10;
DF = 11;

%Add library files to path
oldpath = path;
path('../lib',oldpath)

%% Extract connection information from 20sim XML files and create a connection graph
%fid = fopen('../models/TwoTank355ProcessSupervision.emx');
%fid = fopen('../models/causal_hoist_model.emx');
%fid = fopen('../models/ThreeTank712ProcessSupervision.emx');
%fid = fopen('../models/delta_subnetwork.emx');
%fid = fopen('../models/charge_amplifier.emx');

%G_connection = BG_20sim_parser(fid);
%fclose(fid);
%load Two_tank.mat
%G_connection = G_two_tank;

% %% Extract connection information from a .m file and create a connection graph
 run("../models/hoist_model.m")
 G_connection = BG_creator(id, nexus_id, type_data);
%% Finding sensor locations
%G_sensor_locations = BG_sensor_locations_all(G_connection);
G_sensor_locations = G_connection;%Not adding extra sensor locations
Pic_Width_conn = 7;
Pic_Height_conn = 7;
graph_layout_conn = 'layered';
%graph_layout_conn = 'force';
text_rotation_conn = 20;
text_Xshift_conn = -0.1;
text_Yshift_conn = 0.1;
%graph_plot name-value pairs 'Layout',graph_layout,'textRotation',text_rotation,'textXshift',text_Xshift,'textYshift', text_Yshift,'XData', Xdata_in,'YData', Ydata_in
%[f_conn, Xdata_conn, Ydata_conn]= graph_plot(G_sensor_locations,'Layout',graph_layout_conn,'textRotation',text_rotation_conn,'textXshift',text_Xshift_conn,'textYshift' ,text_Yshift_conn);
f_conn= graph_plot(G_sensor_locations,'Layout',graph_layout_conn,'textRotation',text_rotation_conn,'textXshift',text_Xshift_conn,'textYshift' ,text_Yshift_conn,'CamRotation',-45);
f_conn.Name='Connection Graph';
%% Plotting the results
f_conn.Units='inches';
f_conn.Position=[0 0 Pic_Width_conn Pic_Height_conn];
%f2.InnerPosition=[0 0 Pic_Width Pic_Height];
%f2.OuterPosition=[0 0 Pic_Width Pic_Height];
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 Pic_Width_conn Pic_Height_conn]);
% exportgraphics(f_conn, '..\figures\Journal\ThreeTank_connection_graph.pdf');
% exportgraphics(f_conn, '..\figures\Journal\ThreeTank_connection_graph.png');
% exportgraphics(f_conn, '..\figures\Journal\Hoist_connection_graph.pdf');
% exportgraphics(f_conn, '..\figures\Journal\Hoist_connection_graph.png');
% exportgraphics(f_conn, '..\figures\Journal\ChargeAmplifier_connection_graph.pdf');
% exportgraphics(f_conn, '..\figures\Journal\ChargeAmplifier_connection_graph.png');
%exportgraphics(f_conn, '..\figures\Journal\TwoTank_connection_graph.pdf');
%exportgraphics(f_conn, '..\figures\Journal\TwoTank_connection_graph.png');
%% Performing SCAP to check correctness of model
G_effort_causal = BG_SCAP_I(G_sensor_locations);

%%Sensor combination code from mainfile_structural_observability.m
% Find all ONE and ZERO nodes as sensors will be attached at those nodes
ONE_nodes = find(G_effort_causal.Nodes.priority_id==ONE);
ZERO_nodes = find(G_effort_causal.Nodes.priority_id==ZERO);
C_nodes = find(G_effort_causal.Nodes.priority_id==C);
I_nodes = find(G_effort_causal.Nodes.priority_id==I);
R_nodes = find(G_effort_causal.Nodes.priority_id==R);
storage_nodes = [C_nodes;I_nodes];
passive_nodes = [storage_nodes;R_nodes];
% Sensors can be attached at either ONE or ZERO nodes
sensor_attachment_nodes = [ONE_nodes; ZERO_nodes];
%sensor_attachment_nodes = sensor_nodes_temp;
sensor_locations = length(sensor_attachment_nodes);


%All sensor combinations can be added with the code below
sensor_combinations=[];
sensor_combinations_str=[];
for i=1:sensor_locations
    %Compute combinations with i sensors selected
    i_sensor_combinations = nchoosek(sensor_attachment_nodes,i);
    i_sensor_combinations_str = string(i_sensor_combinations);%saving sensors as a string for printing
    %Concatenating sensor numbers for printing
    i_sensor_combinations_str_temp = i_sensor_combinations_str(:,1);
    for j=2:i
        i_sensor_combinations_str_temp = i_sensor_combinations_str_temp + ', ' + i_sensor_combinations_str(:,j);
    end
    %Find number of combinations
    i_sensor_combinations_count = size(i_sensor_combinations,1);
    sensor_combinations_temp = zeros(i_sensor_combinations_count,sensor_locations);
    sensor_combinations_temp(:,1:i) = i_sensor_combinations;
    sensor_combinations=[sensor_combinations;sensor_combinations_temp];
    sensor_combinations_str=[sensor_combinations_str;i_sensor_combinations_str_temp];
end
sensor_combinations_count = size(sensor_combinations,1)

%% Generate a DBG
for i_combo=1:length(sensor_combinations)
    %[G_temp_effort_causal_1,~] = add_sensor_node(G_effort_causal,cell2mat(dis_obs_set(1)));
    [G_DBG,non_inv_sensor_flag,G_effort_causal_sensor,G_inverted_causal,G_residual_connection] = DBG(G_effort_causal,sensor_combinations(i_combo,:));

    DF_nodes = find(G_effort_causal_sensor.Nodes.priority_id==DF);
    DE_nodes = find(G_effort_causal_sensor.Nodes.priority_id==DE);

    sensor_nodes = [DF_nodes;DE_nodes];

    if 0 %Enable/disable printing
    %if i_combo==4 %Sensor combination for the Three Tank System
        % if i_combo==141 %Sensor combination for the charge amplifier
        layout_type_SCAPI='layered';
        %layout_type_SCAPI='force';
        text_rotation_SCAPI = 20;
        text_Xshift_SCAPI = -0.1;
        text_Yshift_SCAPI = 0.1;
        %[f_SCAPD, Xdata_SCAPD, Ydata_SCAPD]= causal_graph_plot(G_inverted_causal,layout_type,text_rotation,text_Xshift, text_Yshift)
        [f_SCAPI, Xdata_SCAPI, Ydata_SCAPI]= graph_plot(G_effort_causal_sensor,'Layout',layout_type_SCAPI,'textRotation',text_rotation_SCAPI,'textXshift',text_Xshift_SCAPI,'textYshift' ,text_Yshift_SCAPI,'CamRotation',0);
        Pic_Width_SCAPI = 7;
        Pic_Height_SCAPI = 7;
        f_SCAPI.Name='Integral Causality after sensor placement';
        % %% Plotting the results
        f_SCAPI.Units='inches';
        f_SCAPI.Position=[0 0 Pic_Width_SCAPI Pic_Height_SCAPI];
        % % f_SCAPI.InnerPosition=[0 0 Pic_Width Pic_Height];
        % %f_SCAPI.OuterPosition=[0 0 Pic_Width Pic_Height];
        set(gcf,'PaperUnits','inches','PaperPosition',[0 0 Pic_Width_SCAPI Pic_Height_SCAPI]);
        str_new_element_name_id = {};%??
        % exportgraphics(f_SCAPI, ['..\figures\Journal\ThreeTankSensorSCAPI_combo_' num2str(i_combo) '.pdf']);
        % exportgraphics(f_SCAPI, ['..\figures\Journal\ThreeTankSensorSCAPI_combo_' num2str(i_combo) '.png']);
        % exportgraphics(f_SCAPI, ['..\figures\Journal\HoistSensorSCAPI_combo_' num2str(i_combo) '.pdf']);
        % exportgraphics(f_SCAPI, ['..\figures\Journal\HoistSensorSCAPI_combo_' num2str(i_combo) '.png']);
        % exportgraphics(f_SCAPI, ['..\figures\Journal\ChargeAmplifierSensorSCAPI_combo_' num2str(i_combo) '.pdf']);
        % exportgraphics(f_SCAPI, ['..\figures\Journal\ChargeAmplifierSensorSCAPI_combo_' num2str(i_combo) '.png']);
        exportgraphics(f_SCAPI, ['..\figures\Journal\TwoTankSensorSCAPI_combo_' num2str(i_combo) '.pdf']);
        exportgraphics(f_SCAPI, ['..\figures\Journal\TwoTankSensorSCAPI_combo_' num2str(i_combo) '.png']);
        close(f_SCAPI);%Supress output if saving multiple figures

        layout_type_SCAPD='layered';
        %layout_type_SCAPD='force';
        text_rotation_SCAPD = 20;
        text_Xshift_SCAPD = -0.1;
        text_Yshift_SCAPD = 0.1;
        %[f_SCAPD, Xdata_SCAPD, Ydata_SCAPD]= causal_graph_plot(G_inverted_causal,layout_type,text_rotation,text_Xshift, text_Yshift)
        [f_SCAPD, Xdata_SCAPD, Ydata_SCAPD]= graph_plot(G_inverted_causal,'Layout',layout_type_SCAPD,'textRotation',text_rotation_SCAPD,'textXshift',text_Xshift_SCAPD,'textYshift' ,text_Yshift_SCAPD,'CamRotation',0);
        Pic_Width_SCAPD = 7;
        Pic_Height_SCAPD = 7;
        f_SCAPD.Name='Derivative Causality after sensor placement';
        % %% Plotting the results
        f_SCAPD.Units='inches';
        f_SCAPD.Position=[0 0 Pic_Width_SCAPD Pic_Height_SCAPD];
        % % f_SCAPD.InnerPosition=[0 0 Pic_Width Pic_Height];
        % %f_SCAPD.OuterPosition=[0 0 Pic_Width Pic_Height];
        set(gcf,'PaperUnits','inches','PaperPosition',[0 0 Pic_Width_SCAPD Pic_Height_SCAPD]);
        % exportgraphics(f_SCAPD, ['..\figures\Journal\ThreeTankSensorSCAPD_combo_' num2str(i_combo) '.pdf']);
        % exportgraphics(f_SCAPD, ['..\figures\Journal\ThreeTankSensorSCAPD_combo_' num2str(i_combo) '.png']);
        % exportgraphics(f_SCAPD, ['..\figures\Journal\HoistSensorSCAPD_combo_' num2str(i_combo) '.pdf']);
        % exportgraphics(f_SCAPD, ['..\figures\Journal\HoistSensorSCAPD_combo_' num2str(i_combo) '.png']);
        % exportgraphics(f_SCAPD, ['..\figures\Journal\ChargeAmplifierSensorSCAPD_combo_' num2str(i_combo) '.pdf']);
        % exportgraphics(f_SCAPD, ['..\figures\Journal\ChargeAmplifierSensorSCAPD_combo_' num2str(i_combo) '.png']);
        exportgraphics(f_SCAPD, ['..\figures\Journal\TwoTankSensorSCAPD_combo_' num2str(i_combo) '.pdf']);
        exportgraphics(f_SCAPD, ['..\figures\Journal\TwoTankSensorSCAPD_combo_' num2str(i_combo) '.png']);
        close(f_SCAPD);
    
        layout_type_res='layered';
        %layout_type_res='force';
        %Add randomness
        text_Xshift_res = 0.05*(2*rand(1,length(G_residual_connection.Nodes.id))-4);
        text_Yshift_res = 0.05*(2*rand(1,length(G_residual_connection.Nodes.id))+1);
        text_rotation_res = 20;
        cam_rotation_res = -20;
        %[f_res, Xdata, Ydata]= conn_graph_plot(G_residual_connection,layout_type,text_rotation,text_Xshift, text_Yshift)
        [f_res, Xdata_res, Ydata_res]= graph_plot(G_residual_connection,'Layout',layout_type_res,'textRotation',text_rotation_res,'textXshift',text_Xshift_res,'textYshift' ,text_Yshift_res,'CamRotation',cam_rotation_res);
        f_res.Name='Residual Connection Graph';
        %% Plotting the results
        Pic_Width_res = 7;
        Pic_Height_res = 7;
        f_res.Units='inches';
        f_res.Position=[0 0 Pic_Width_res Pic_Height_res];
        set(gcf,'PaperUnits','inches','PaperPosition',[0 0 Pic_Width_res Pic_Height_res]);
        % exportgraphics(f_res, ['..\figures\Journal\ThreeTankSensorRCG_combo_' num2str(i_combo) '.pdf']);%Literature verification example
        % exportgraphics(f_res, ['..\figures\Journal\ThreeTankSensorRCG_combo_' num2str(i_combo) '.png']);
        % exportgraphics(f_res, ['..\figures\Journal\HoistSensorRCG_combo_' num2str(i_combo) '.pdf']);
        % exportgraphics(f_res, ['..\figures\Journal\HoistSensorRCG_combo_' num2str(i_combo) '.png']);
        % exportgraphics(f_res, ['..\figures\Journal\ChargeAmplifierSensorRCG_combo_' num2str(i_combo) '.pdf']);
        % exportgraphics(f_res, ['..\figures\Journal\ChargeAmplifierSensorRCG_combo_' num2str(i_combo) '.png']);
        exportgraphics(f_res, ['..\figures\Journal\TwoTankSensorRCG_combo_' num2str(i_combo) '.pdf']);
        exportgraphics(f_res, ['..\figures\Journal\TwoTankSensorRCG_combo_' num2str(i_combo) '.png']);
        close(f_res);

        layout_type_DBG = 'layered';
        %layout_type_DBG = 'force';
        Pic_Width_DBG=7;
        Pic_Height_DBG=7;
        [f_DBG, Xdata_DBG, Ydata_DBG]= graph_plot(G_DBG,'Layout',layout_type_DBG,'textRotation',text_rotation_res,'textXshift',text_Xshift_res,'textYshift' ,text_Yshift_res,'CamRotation',0);
        f_DBG.Name='Diagnostic Bond Graph = SCAPD on DBG';
        %% Plotting the results
        f_DBG.Units='inches';
        f_DBG.Position=[0 0 Pic_Width_DBG Pic_Height_DBG];
        %f_DBG.InnerPosition=[0 0 Pic_Width Pic_Height];
        %f_DBG.OuterPosition=[0 0 Pic_Width Pic_Height];
        set(gcf,'PaperUnits','inches','PaperPosition',[0 0 Pic_Width_DBG Pic_Height_DBG]);
        % exportgraphics(f_DBG, ['..\figures\Journal\ThreeTankCausalSensorDBG_combo_' num2str(i_combo) '.pdf']);
        % exportgraphics(f_DBG, ['..\figures\Journal\ThreeTankCausalSensorDBG_combo_' num2str(i_combo) '.png']);
        % exportgraphics(f_DBG, ['..\figures\Journal\HoistSensorDBG_combo_' num2str(i_combo) '.pdf']);
        % exportgraphics(f_DBG, ['..\figures\Journal\HoistSensorDBG_combo_' num2str(i_combo) '.png']);
        % exportgraphics(f_DBG, ['..\figures\Journal\ChargeAmplifierSensorDBG_combo_' num2str(i_combo) '.pdf']);
        % exportgraphics(f_DBG, ['..\figures\Journal\ChargeAmplifierSensorDBG_combo_' num2str(i_combo) '.png']);
        exportgraphics(f_DBG, ['..\figures\Journal\TwoTankSensorDBG_combo_' num2str(i_combo) '.pdf']);
        exportgraphics(f_DBG, ['..\figures\Journal\TwoTankSensorDBG_combo_' num2str(i_combo) '.png']);

       close(f_DBG);
    %end
    end

    %Generate the FSM
    [component_nodes, residual_nodes, FSM]=CaPS_SCAP_D(G_DBG);
    %Get component names
    components = G_DBG.Nodes.element_name(component_nodes);
    residuals = G_DBG.Nodes.element_name(residual_nodes);
    %Check monitorability. Every non-zero component row is monitorable
    monitorability = any(FSM,2);
    % %Next find isolability. Find the unique rows in FSM, if the unique rows are
    % %not repeated, the fault is isolable.
    [rows_FSM,cols_FSM] = size(FSM);
    dec_FSM = zeros(rows_FSM,1);
    for j=1:cols_FSM
        dec_FSM = dec_FSM + FSM(:,j).*2^(cols_FSM-j);
    end
    similar_FSM=2*ones(length(dec_FSM),1);
    %Crude way of finding repeated signatures
    for k=1:length(dec_FSM)
        similar_FSM(k,1) = nnz(find(dec_FSM==dec_FSM(k)));
    end
    isolability = (similar_FSM < 2).*monitorability;%If fault is not monitorable it shouldn't be isolable
    FSM=double(FSM);
    Mb= double(monitorability);
    Ib = double(isolability);
    FSM_table = table(components, FSM, Mb, Ib);
    monitorability_ratio = nnz(Mb)/rows_FSM;
    isolability_ratio = nnz(Ib)/rows_FSM;
    redundant_sensor_count = nnz(non_inv_sensor_flag);
    redundant_sensors = sensor_nodes(find(non_inv_sensor_flag));
    sensor_count = length(sensor_nodes);
    [observsability, necessary, sufficiency]=isStructObsv(G_effort_causal_sensor,0,0,0);
    %Struct_Properties(i_combo,:) = {FSM_table, sensor_count, observsability, necessary, sufficiency, monitorability_ratio, isolability_ratio, redundant_sensors};
    Struct_Properties(i_combo,:) = {FSM_table, residuals, sensor_count, observsability, necessary, sufficiency, monitorability_ratio, isolability_ratio, redundant_sensor_count,redundant_sensors};
end
sensor_combinations_cell=cell(length(sensor_combinations_str),1);

for i=1:length(sensor_combinations_str)
    %Extract numbers from a string https://www.mathworks.com/matlabcentral/answers/317177-extracting-number-from-a-string
    sensor_combinations_cell(i)={str2double(extract(sensor_combinations_str(i,1),digitsPattern))'};
end

%Sensor combinations as cell
observable_combinations = sensor_combinations_cell(cell2mat(Struct_Properties(:,4))==1);
monitorable_combinations = sensor_combinations_cell(cell2mat(Struct_Properties(:,5))==1);
isolable_combinations = sensor_combinations_cell(cell2mat(Struct_Properties(:,8))==1);
redundancy_count = cell2mat(Struct_Properties(:,9));
nonredundant_combinations = sensor_combinations_cell(cell2mat(Struct_Properties(:,9))==0);

%String equivalent of sensor combinations
observable_combinations_str = sensor_combinations_str(cell2mat(Struct_Properties(:,4))==1);
monitorable_combinations_str = sensor_combinations_str(cell2mat(Struct_Properties(:,5))==1);
isolable_combinations_str = sensor_combinations_str(cell2mat(Struct_Properties(:,8))==1);
partial_isolable_combinations_str = sensor_combinations_str(cell2mat(Struct_Properties(:,8))~=0);
redundant_combination_str = sensor_combinations_str(cell2mat(Struct_Properties(:,9))~=0);
non_redundant_combination_str = sensor_combinations_str(cell2mat(Struct_Properties(:,9))==0);

intersect_obsv_mon_str = intersect(observable_combinations_str,monitorable_combinations_str);
isequal(intersect_obsv_mon_str,sort(monitorable_combinations_str))
intersect_iso_nonredundant = intersect(non_redundant_combination_str,isolable_combinations_str);
sensor_combinations_count
[count_observable_combinations,~] = size(observable_combinations)
[count_monitorable_combinations,~] = size(monitorable_combinations)
[count_intersect_obsv_mon_str,~] = size(intersect_obsv_mon_str)
[count_isolable_combinations,~] = size(isolable_combinations)
[count_partial_isolable_combinations,~] = size(partial_isolable_combinations_str)
[freq_redundancy, redundancy_count_group] = groupcounts(redundancy_count)