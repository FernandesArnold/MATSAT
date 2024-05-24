function G_causal = TF_constraint(G_connection,G_causal)
SE = 1;
SF = 2;
C = 3;
I = 4;
R = 5;
ONE = 6;
ZERO = 7;
TF = 8;
GY = 9;
TF_nodes = find(G_connection.Nodes.priority_id==TF); %Find TF nodes

for i=1:length(TF_nodes)
    TF_neighbor_nodes = neighbors(G_connection,TF_nodes(i)); %Neighboring nodes of the TF element
    %Check for indegree. An indegree indicates number of effort in or
    %flow out causalities.
    TF_node_outdegree = outdegree(G_causal,TF_nodes(i));
    TF_node_indegree = indegree(G_causal,TF_nodes(i));
    if TF_node_indegree==1 && TF_node_outdegree==1
        %Do nothing
    elseif TF_node_indegree==1
        %Remove the predecessor node from the neighbor node list and make the
        %remaining nodes a successor.
        pred_node = predecessors(G_causal,TF_nodes(i));
        succ_node = setdiff(TF_neighbor_nodes,pred_node);
        G_causal = addedge(G_causal,TF_nodes(i),succ_node); %Add edges From a TF node to To a successor node
    elseif TF_node_indegree>1 || TF_node_outdegree>1
        error('TF constraint Causality Conflict');
    elseif TF_node_outdegree==1
        %Remove the successor node from the neighbor node list and make
        %the remaining node a predecessor
        succ_node = successors(G_causal,TF_nodes(i));
        pred_node = setdiff(TF_neighbor_nodes,succ_node);
        G_causal = addedge(G_causal,pred_node,TF_nodes(i)); %Add edges From a predecessor node To a GY node
    else
        %Do nothing as there isn't enough information
    end
end

end