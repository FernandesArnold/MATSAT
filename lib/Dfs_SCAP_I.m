function G_causal = Dfs_SCAP_I(G_connection,G_causal)
%DF_SCAP_I base code modified to obtain Dfs_SCAP_I
DFS = 21; %Df*

%% Actual assignment procedure
DFS_nodes = find(G_connection.Nodes.priority_id==DFS); %Find DFS nodes
for i=1:length(DFS_nodes)
    DFS_neighbor_node = neighbors(G_connection,DFS_nodes(i)); %Single port DFS implies there is only one neighbor node
    if (edgecount(G_causal,DFS_neighbor_node,DFS_nodes(i))==0 && edgecount(G_causal,DFS_nodes(i),DFS_neighbor_node)==0)%Do not add edges if an edge edge already exists
    G_causal = addedge(G_causal,DFS_nodes(i),DFS_neighbor_node); %Add edges From a DFS node To the neighboring node
    G_causal = Constraint_check(G_connection,G_causal);
    elseif (edgecount(G_causal,DFS_neighbor_node,DFS_nodes(i))~=0 && edgecount(G_causal,DFS_nodes(i),DFS_neighbor_node)~=0)
         error('Dfs Causality Conflict');
    end
end

end
