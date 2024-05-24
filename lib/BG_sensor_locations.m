function G = BG_sensor_locations(G)
%Add ZERO and ONE junctions at all locations, excluding sources
SE = 1;
SF = 2;
C = 3;
I = 4;
R = 5;
ONE = 6;
ZERO = 7;
TF = 8;
GY = 9;

C_nodes = find(G.Nodes.priority_id==C);
I_nodes = find(G.Nodes.priority_id==I);
R_nodes = find(G.Nodes.priority_id==R);
TF_nodes = find(G.Nodes.priority_id==TF);
GY_nodes = find(G.Nodes.priority_id==GY);
ONE_nodes_original = find(G.Nodes.priority_id==ONE);
ZERO_nodes_original = find(G.Nodes.priority_id==ZERO);
single_port_nodes = [C_nodes;I_nodes;R_nodes];
two_port_nodes = [TF_nodes;GY_nodes];

% for i=1:length(single_port_nodes)
%     single_port_node_neighbor = neighbors(G,single_port_nodes(i));%Each node will have only one neighbor as it is a single port storage
%     if G.Nodes.priority_id(single_port_node_neighbor)==ONE %Check if the neighbor is a ONE junction
%         [G,~] = add_ZERO_node(G,single_port_nodes(i),single_port_node_neighbor);
%     elseif G.Nodes.priority_id(single_port_node_neighbor)==TF %Check if the neighbor is a TF node
%         [G,new_ONE_node_id] = add_ONE_node(G,single_port_nodes(i),single_port_node_neighbor);
%         [G,~] = add_ZERO_node(G,single_port_nodes(i),new_ONE_node_id);
%     elseif G.Nodes.priority_id(single_port_node_neighbor)==GY %Check if the neighbor is a GY node
%         [G,new_ONE_node_id] = add_ONE_node(G,single_port_nodes(i),single_port_node_neighbor);
%         [G,~] = add_ZERO_node(G,single_port_nodes(i),new_ONE_node_id);
%     end
% end

for i=1:length(ONE_nodes_original)
    ONE_node_neighbor = neighbors(G,ONE_nodes_original(i));%Each node may have multiple neighbors
    %If a ONE node has 3 or more neighbors, on all the edges that are not
    %connected to a ZERO junction, insert a ZERO junction
    %Edited: Add ZERO junction only if neighbors are passive elements 
    if length(ONE_node_neighbor)>=3
        for j=1:length(ONE_node_neighbor)
            if (G.Nodes.priority_id(ONE_node_neighbor(j))~=ZERO && any(ismember(ONE_node_neighbor(j),single_port_nodes)))
                [G,~] = add_ZERO_node(G,ONE_nodes_original(i),ONE_node_neighbor(j));
            end
        end
        %If a ONE node has 2 neighbors, check if one of the neighbors is a ZERO
        %junction. If so, do nothing. Else, insert a ZERO junction
    elseif length(ONE_node_neighbor)==2
        if ((G.Nodes.priority_id(ONE_node_neighbor(1))~=ZERO)&&(G.Nodes.priority_id(ONE_node_neighbor(2))~=ZERO) && any(ismember(ONE_node_neighbor,single_port_nodes)))
            [G,~] = add_ZERO_node(G,ONE_nodes_original(i),ONE_node_neighbor(1));
        end
    else
        %Do nothing
    end
end

for i=1:length(ZERO_nodes_original)
    ZERO_node_neighbor = neighbors(G,ZERO_nodes_original(i));%Each node may have multiple neighbors
    %If a ONE node has 3 or more neighbors, on all the edges that are not
    %connected to a ZERO junction, insert a ZERO junction
    %Edited: Add ONE junction only if neighbors are passive elements
    if length(ZERO_node_neighbor)>=3
        for j=1:length(ZERO_node_neighbor)
            if (G.Nodes.priority_id(ZERO_node_neighbor(j))~=ONE && any(ismember(ZERO_node_neighbor(j),single_port_nodes)))
                [G,~] = add_ONE_node(G,ZERO_nodes_original(i),ZERO_node_neighbor(j));
            end
        end
        %If a ONE node has 2 neighbors, check if one of the neighbors is a ZERO
        %junction. If so, do nothing. Else, insert a ZERO junction
    elseif length(ZERO_node_neighbor)==2
        if ((G.Nodes.priority_id(ZERO_node_neighbor(1))~=ONE)&&(G.Nodes.priority_id(ZERO_node_neighbor(2))~=ONE) && any(ismember(ZERO_node_neighbor,single_port_nodes)))
            [G,~] = add_ONE_node(G,ZERO_nodes_original(i),ZERO_node_neighbor(1));
        end
    else
        %Do nothing
    end
end

for i=1:length(two_port_nodes)
    two_port_nodes_neighbors = neighbors(G,two_port_nodes(i));
    %Look at the neighbors at each port
    for j=1:length(two_port_nodes_neighbors)
        %If a neighbor is a single port element or a two port element, then
        %add a ONE junction and a ZERO junction else do nothing
        if (G.Nodes.priority_id(two_port_nodes_neighbors(j))==C)||(G.Nodes.priority_id(two_port_nodes_neighbors(j))==R)||(G.Nodes.priority_id(two_port_nodes_neighbors(j))==I)||(G.Nodes.priority_id(two_port_nodes_neighbors(j))==TF)||(G.Nodes.priority_id(two_port_nodes_neighbors(j))==GY)
            [G,new_ONE_node_id] = add_ONE_node(G,two_port_nodes(i),two_port_nodes_neighbors(j));
            [G,~] = add_ZERO_node(G,two_port_nodes(i),new_ONE_node_id);
        end
    end
end
end