function G_inverted_causal = DF_SCAP_D(G_connection,G_inverted_causal)
DE = 10;
DF = 11;

%% Actual assignment procedure
DF_nodes = find(G_connection.Nodes.priority_id==DF); %Find DF nodes
for i=1:length(DF_nodes)
    DF_neighbor_node = neighbors(G_connection,DF_nodes(i)); %Single port DE implies there is only one neighbor node
    if (edgecount(G_inverted_causal,DF_neighbor_node,DF_nodes(i))==0 && edgecount(G_inverted_causal,DF_nodes(i),DF_neighbor_node)==0)%Do not add edges if an edge edge already exists
    %G_inverted_causal = addedge(G_inverted_causal,DF_nodes(i),DF_neighbor_node); %Add edges From a DF node to a DF_neighbor_node(bug)Add edges From a DF_neighbor node to a DF_node
    G_inverted_causal = addedge(G_inverted_causal,DF_neighbor_node,DF_nodes(i)); %Add edges From a DF_neighbor node to a DF_node
    G_inverted_causal = Constraint_check(G_connection,G_inverted_causal); %Perform a causality constraint check    
    elseif (edgecount(G_inverted_causal,DF_neighbor_node,DF_nodes(i))~=0 && edgecount(G_inverted_causal,DF_nodes(i),DF_neighbor_node)~=0)
         error('DF Inverted Causality Conflict');
    end
end

end