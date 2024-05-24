function G_causal = DE_SCAP_I(G_connection,G_causal)
DE = 10;
DF = 11;
%% Actual assignment procedure

DE_nodes = find(G_connection.Nodes.priority_id==DE);
for i=1:length(DE_nodes)
    DE_neighbor_node = neighbors(G_connection,DE_nodes(i)); %Single port DE implies there is only one neighbor node
    G_causal = addedge(G_causal,DE_neighbor_node,DE_nodes(i));
    G_causal = Constraint_check(G_connection,G_causal);
end
end