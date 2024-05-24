function G_causal = SE_SCAP_I(G_connection,G_causal)
SE = 1;
SF = 2;

MSE = 13;
%% Actual assignment procedure
SE_nodes = [find(G_connection.Nodes.priority_id==SE); find(G_connection.Nodes.priority_id==MSE)];%Find SE nodes
for i=1:length(SE_nodes)
    SE_neighbor_node = neighbors(G_connection,SE_nodes(i)); %Single port SE implies there is only one neighbor node
    G_causal = addedge(G_causal,SE_nodes(i),SE_neighbor_node); %Add edges From an SE node To a the neighboring node
    G_causal = Constraint_check(G_connection,G_causal);
end

end
