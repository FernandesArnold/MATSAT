function G_causal = C_SCAP_I(G_connection,G_causal)
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
C_nodes = find(G_connection.Nodes.priority_id==C); %Find SE nodes
for i=1:length(C_nodes)
    %Incorporating preffered causality
     %(C_neighbor_node -> C_nodes(i)) or( C_nodes(i) -> C_neighbor_node) DO
    %                  0                           0                    1
    %                  0                           1                    0
    %                  1                           0                    0
    %                  1                           1                  error
    C_neighbor_node = neighbors(G_connection,C_nodes(i)); %Single port C implies there is only one neighbor node
    if ((edgecount(G_causal,C_nodes(i),C_neighbor_node)==0) && (edgecount(G_causal,C_neighbor_node,C_nodes(i))==0))%Do not add edges if an edge edge already exists
    G_causal = addedge(G_causal,C_nodes(i),C_neighbor_node); %Add edges From a C node To the neighboring node
    G_causal = Constraint_check(G_connection,G_causal); %Perform a causality constraint check     
    end
end

end
