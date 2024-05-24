function G_inverted_causal = DE_SCAP_D(G_connection,G_inverted_causal)
DE = 10;
DF = 11;
%% Actual assignment procedure

DE_nodes = find(G_connection.Nodes.priority_id==DE);
for i=1:length(DE_nodes)
    DE_neighbor_node = neighbors(G_connection,DE_nodes(i)); %Single port DE implies there is only one neighbor node
    if (edgecount(G_inverted_causal,DE_neighbor_node,DE_nodes(i))==0 && edgecount(G_inverted_causal,DE_nodes(i),DE_neighbor_node)==0)%Do not add edges if an edge already exists
    %G_inverted_causal = addedge(G_inverted_causal,DE_neighbor_node,DE_nodes(i)); %Add edges From a DE_neighbor node to a DE_node(bug)Add edges From a DE_node to a DE_neighbor node
    G_inverted_causal = addedge(G_inverted_causal,DE_nodes(i),DE_neighbor_node); %Add edges From a DE_node to a DE_neighbor node
    G_inverted_causal = Constraint_check(G_connection,G_inverted_causal); %Perform a causality constraint check     
    elseif (edgecount(G_inverted_causal,DE_neighbor_node,DE_nodes(i))~=0 && edgecount(G_inverted_causal,DE_nodes(i),DE_neighbor_node)~=0)
         error('DE Inverted Causality Conflict');
    end
    
end
end