function [SO_table, sensor_attachment_nodes] = BG_SO_noplot(G_effort_causal)

FROM = 1;
TO = 2;
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
sensor_combinations_count = size(sensor_combinations,1);

%% Sensor combination properties
isStructObsv_flag=zeros(sensor_combinations_count,1);
necessity_flag=zeros(sensor_combinations_count,1);
sufficiency_flag=zeros(sensor_combinations_count,1);

SO_table=[];

plotBG = zeros(sensor_combinations_count,1);
%Plot for below case
%plotBG(6,1) = 1;
node_2_XData = [];
node_2_YData = [];
for i=1:length(sensor_combinations)
    %Temporary effort causal graph obtained after adding sensor node to the original
    %causal graph
    [G_temp_effort_causal_1,~] = add_sensor_node(G_effort_causal,sensor_combinations(i,:));

    [isStructObsv_flag(i), necessity_flag(i), sufficiency_flag(i)]=isStructObsv(G_temp_effort_causal_1, plotBG(i),node_2_XData,node_2_YData);

end
sensor_combinations_cell=cell(length(sensor_combinations_str),1);

for i=1:length(sensor_combinations_str)
    %Extract numbers from a string https://www.mathworks.com/matlabcentral/answers/317177-extracting-number-from-a-string
    sensor_combinations_cell(i)={str2double(extract(sensor_combinations_str(i,1),digitsPattern))'};
end
SO_table = table(sensor_combinations_cell,sufficiency_flag,necessity_flag,isStructObsv_flag);

end