function G_inverted_causal = C_SCAP_D(G_connection,G_inverted_causal)
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
C_nodes = find(G_connection.Nodes.priority_id==C); %Find C nodes
for i=1:length(C_nodes)
    C_neighbor_node = neighbors(G_connection,C_nodes(i)); %Single port C implies there is only one neighbor node
    if ((edgecount(G_inverted_causal,C_neighbor_node,C_nodes(i))==0) && (edgecount(G_inverted_causal,C_nodes(i),C_neighbor_node)==0))%Do not add edges if an edge edge already exists
    G_inverted_causal = addedge(G_inverted_causal,C_neighbor_node,C_nodes(i)); %Add edges From a C_neighbor node to a C_node
    G_inverted_causal = Constraint_check(G_connection,G_inverted_causal); %Perform a causality constraint check     
    end
end

end
