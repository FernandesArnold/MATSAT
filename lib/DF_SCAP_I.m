function G_causal = DF_SCAP_I(G_connection,G_causal)
DE = 10;
DF = 11;

%% Actual assignment procedure
DF_nodes = find(G_connection.Nodes.priority_id==DF); %Find DF nodes
for i=1:length(DF_nodes)
    DF_neighbor_node = neighbors(G_connection,DF_nodes(i)); %Single port DE implies there is only one neighbor node
    G_causal = addedge(G_causal,DF_nodes(i),DF_neighbor_node); %Add edges From a DE node To the neighboring node
    G_causal = Constraint_check(G_connection,G_causal);
end

end