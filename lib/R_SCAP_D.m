function G_inverted_causal = R_SCAP_D(G_connection,G_inverted_causal)
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
R_nodes = find(G_connection.Nodes.priority_id==R); %Find C nodes
for i=1:length(R_nodes)
    R_neighbor_node = neighbors(G_connection,R_nodes(i)); %Single port R implies there is only one neighbor node
    %(R_neighbor_node -> R_nodes(i)) or( R_nodes(i) -> R_neighbor_node) DO
    %                  0                           0                    1
    %                  0                           1                    0
    %                  1                           0                    0
    %                  1                           1                  error
    if (edgecount(G_inverted_causal,R_neighbor_node,R_nodes(i))==0 && edgecount(G_inverted_causal,R_nodes(i),R_neighbor_node)==0)%Do not add edges if an edge edge already exists
    G_inverted_causal = addedge(G_inverted_causal,R_neighbor_node,R_nodes(i)); %Add edges From a R_neighbor node to a R_node
    G_inverted_causal = Constraint_check(G_connection,G_inverted_causal); %Perform a causality constraint check     
    elseif (edgecount(G_inverted_causal,R_neighbor_node,R_nodes(i))~=0 && edgecount(G_inverted_causal,R_nodes(i),R_neighbor_node)~=0)
         error('R Causality Conflict');
    end
end

end