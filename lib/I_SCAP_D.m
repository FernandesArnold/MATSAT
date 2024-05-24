function G_causal = I_SCAP_D(G_connection,G_causal)
SE = 1;
SF = 2;
C = 3;
I = 4;
R = 5;
ONE = 6;
ZERO = 7;
TF = 8;
GY = 9;
%% Actual assignment procedure
I_nodes = find(G_connection.Nodes.priority_id==I);
for i=1:length(I_nodes)
    I_neighbor_node = neighbors(G_connection,I_nodes(i)); %Single port I implies there is only one neighbor node
    if ((edgecount(G_causal,I_nodes(i),I_neighbor_node)==0)&&(edgecount(G_causal,I_neighbor_node,I_nodes(i))==0))%Do not add edges if an edge edge already exists
        G_causal = addedge(G_causal,I_nodes(i),I_neighbor_node);%Add edges from a I_node to an I_neighbor_node
        G_causal = Constraint_check(G_connection,G_causal); %Perform a causality constraint check
    end
end
end
