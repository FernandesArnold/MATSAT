function G_causal = SF_SCAP_I(G_connection,G_causal)
SE = 1;
SF = 2;

MSF = 14;
%% Actual assignment procedure

SF_nodes = [find(G_connection.Nodes.priority_id==SF);find(G_connection.Nodes.priority_id==MSF)];
for i=1:length(SF_nodes)
    SF_neighbor_node = neighbors(G_connection,SF_nodes(i)); %Single port SF implies there is only one neighbor node
    G_causal = addedge(G_causal,SF_neighbor_node,SF_nodes(i));
    G_causal = Constraint_check(G_connection,G_causal);
end
end
