function [G_DBG,non_inv_sensor_flag,varargout] = DBG(Gcausal,sensor_combination)
DE = 10;
DF = 11;

sensor_nodes_in = sensor_combination;
[Gcausal_sensor,~] = add_sensor_node(Gcausal,sensor_nodes_in);
varargout{1} = Gcausal_sensor;
%Create connection graph object with sensor nodes
A_sensor_connection = adjacency(Gcausal_sensor)+adjacency(Gcausal_sensor)';
G_sensor_connection = graph(A_sensor_connection,Gcausal_sensor.Nodes);

DF_nodes = find(Gcausal_sensor.Nodes.priority_id==DF);
DE_nodes = find(Gcausal_sensor.Nodes.priority_id==DE);

sensor_nodes = [DF_nodes;DE_nodes];


%% Generating a BG in SCAP-D
G_inverted_causal = BG_CA(G_sensor_connection,'Procedure','SCAP-D');
varargout{2} = G_inverted_causal;

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
for i_sensor=1:length(sensor_nodes)
    if ismember(sensor_nodes(i_sensor),DF_nodes)
        DF_neighbor_node = neighbors(G_sensor_connection,sensor_nodes(i_sensor));
        %For bond graph with preferred derivative causality, If nodes are
        %of C type then check if there exists an edge ponting toward
        %the element. If the edge points away from the element do not add it to
        %the diff_storage_nodes set
        if (edgecount(G_inverted_causal,DF_neighbor_node,sensor_nodes(i_sensor))~=0)
            diff_sensor_nodes=[diff_sensor_nodes;sensor_nodes(i_sensor)];
        end
    elseif ismember(sensor_nodes(i_sensor),DE_nodes)
        DE_neighbor_node = neighbors(G_sensor_connection,sensor_nodes(i_sensor)); %Single port I implies there is only one neighbor node
        %For bond graph with preferred derivative causality, if nodes are
        %of I type then check if there exists an edge ponting away from
        %the element. If the edge points toward the element do not add it to
        %the diff_storage_nodes set
        if (edgecount(G_inverted_causal,sensor_nodes(i_sensor),DE_neighbor_node)~=0)
            diff_sensor_nodes=[diff_sensor_nodes;sensor_nodes(i_sensor)];
        end
    end
end
%Set non_inv_sensor_flag next
non_inv_sensor_flag=~ismember(int_sensor_nodes,diff_sensor_nodes);

%Adds appropriate residual structure to all sensors and provides the DBG
%alongside the newly added virtual sensors and the newly added modulated source nodes
G_residual_connection = add_residual_struct(G_sensor_connection,sensor_nodes,non_inv_sensor_flag);
varargout{3} = G_residual_connection;

G_DBG = BG_SCAP_D_DBG(G_residual_connection);
end