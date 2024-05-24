function G_causal = Des_SCAP_I(G_connection,G_causal)
%DE_SCAP_I base code modified to obtain Des_SCAP_I
DES = 20;%De*

%% Actual assignment procedure

DES_nodes = find(G_connection.Nodes.priority_id==DES);
for i=1:length(DES_nodes)
    DES_neighbor_node = neighbors(G_connection,DES_nodes(i)); %Single port DES implies there is only one neighbor node
    if (edgecount(G_causal,DES_neighbor_node,DES_nodes(i))==0 && edgecount(G_causal,DES_nodes(i),DES_neighbor_node)==0)%Do not add edges if an edge already exists
    G_causal = addedge(G_causal,DES_neighbor_node,DES_nodes(i));
    G_causal = Constraint_check(G_connection,G_causal);
    elseif (edgecount(G_causal,DES_neighbor_node,DES_nodes(i))~=0 && edgecount(G_causal,DES_nodes(i),DES_neighbor_node)~=0)
         error('Des Causality Conflict');
    end
end
end