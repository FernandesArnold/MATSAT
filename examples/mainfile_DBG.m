clc; clear all; close all;
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

% %% Extract connection information from 20sim XML files and assign it to a table
% %fid = fopen('../models/TwoTank355ProcessSupervision.emx');
% %fid = fopen('../models/causal_hoist_model.emx');
% fid = fopen('../models/ThreeTank712ProcessSupervision.emx');
% 
% G_connection = BG_20sim_parser(fid);
% fclose(fid);
load Two_tank.mat
G_connection = G_two_tank;
%% Finding sensor locations
G_sensor_locations = BG_sensor_locations(G_connection);

%% Performing SCAP
G_effort_causal = BG_SCAP_I(G_sensor_locations);
figure(1)
layouttype='force';
plot(G_effort_causal,'NodeLabel',G_effort_causal.Nodes.element_name,'LineWidth', 2,'Layout',layouttype)

sensor_nodes=[9,10];

%% Without adding extra sensors first generate a DBG
% Generating a BG in SCAP-I
%[G_temp_effort_causal_1,~] = add_sensor_node(G_effort_causal,cell2mat(dis_obs_set(1)));
[G_temp_effort_causal_1,~] = add_sensor_node(G_effort_causal,sensor_nodes);
figure(2)
layouttype='force';
plot(G_temp_effort_causal_1,'NodeLabel',G_temp_effort_causal_1.Nodes.element_name,'LineWidth', 2,'Layout',layouttype)
%Create connection graph object with sensor nodes
A_sensor_connection = adjacency(G_temp_effort_causal_1)+adjacency(G_temp_effort_causal_1)';
G_sensor_connection = graph(A_sensor_connection,G_temp_effort_causal_1.Nodes);


DF_nodes = find(G_temp_effort_causal_1.Nodes.priority_id==DF);
DE_nodes = find(G_temp_effort_causal_1.Nodes.priority_id==DE);

sensor_nodes = [DF_nodes;DE_nodes];


%%Generating a BG in SCAP-D
G_inverted_causal = BG_SCAP_D(G_sensor_connection);
figure(3)
layouttype='force';
plot(G_inverted_causal,'NodeLabel',G_inverted_causal.Nodes.element_name,'LineWidth', 2,'Layout',layouttype)
%What if we perform SCAP-D after creating the connections of the DBG?

%% Compare sensor inversions on SCAP-I and SCAP-D
% Final check for observability code has been repurposed
%1. Store edge information of sensor elements in SCAP-I getting preffered
%causality
%2. Store edge information of sensor elements in SCAP-D getiing preferred
%causality
% If element exists in both sets then the causality is inverted else it is
% non-inverted. Set flag to true for non-inverted elements non_inv_sensor_flag
int_sensor_nodes=sensor_nodes;
diff_sensor_nodes=[];
non_inv_sensor_flag=false(length(sensor_nodes),1);
% %1. Query edges of storage elements to find if they take integral causality in
% %the bond graph model with preferred integral causality
for i=1:length(sensor_nodes)
    if ismember(sensor_nodes(i),DF_nodes)
        DF_neighbor_node = neighbors(G_sensor_connection,sensor_nodes(i));
        %For bond graph with preferred derivative causality, If nodes are
        %of C type then check if there exists an edge ponting toward
        %the element. If the edge points away from the element do not add it to
        %the diff_storage_nodes set
        if (edgecount(G_inverted_causal,DF_neighbor_node,sensor_nodes(i))~=0)
            diff_sensor_nodes=[diff_sensor_nodes;sensor_nodes(i)];
        end
    elseif ismember(sensor_nodes(i),DE_nodes)
        DE_neighbor_node = neighbors(G_sensor_connection,sensor_nodes(i)); %Single port I implies there is only one neighbor node
        %For bond graph with preferred derivative causality, if nodes are
        %of I type then check if there exists an edge ponting away from
        %the element. If the edge points toward the element do not add it to
        %the diff_storage_nodes set
        if (edgecount(G_inverted_causal,sensor_nodes(i),DE_neighbor_node)~=0)
            diff_sensor_nodes=[diff_sensor_nodes;sensor_nodes(i)];
        end
    end
end
%Set non_inv_sensor_flag next
non_inv_sensor_flag=~ismember(int_sensor_nodes,diff_sensor_nodes);

%Adds appropriate residual structure to all sensors and provides the DBG
%alongside the newly added virtual sensors and the newly added modulated source nodes
G_residual_connection = add_residual_struct(G_sensor_connection,sensor_nodes,non_inv_sensor_flag);
figure(4)
layouttype='force';
plot(G_residual_connection,'NodeLabel',G_residual_connection.Nodes.element_name,'LineWidth', 2,'Layout',layouttype)

G_DBG = BG_SCAP_D_DBG(G_residual_connection);
figure(5)
layouttype='force';
plot(G_DBG,'NodeLabel',G_DBG.Nodes.element_name,'LineWidth', 2,'Layout',layouttype)

%Generate the FSM
[component_nodes, residual_nodes, FSM]=CaPS_SCAP_D(G_DBG);
%Get component names
components = G_DBG.Nodes.element_name(component_nodes);
%Check monitorability. Every non-zero component row is monitorable
monitorability = any(FSM')';
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
isolability = (similar_FSM < 2);
FSM=double(FSM)
Mb= double(monitorability);
Ib = double(isolability);
FSM_table = table(components, FSM, Mb, Ib)