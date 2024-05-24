function G_causal = ONE_constraint(G_connection,G_causal)
SE = 1;
SF = 2;
C = 3;
I = 4;
R = 5;
ONE = 6;
ZERO = 7;
TF = 8;
GY = 9;
ONE_nodes = find(G_connection.Nodes.priority_id==ONE); %Find ONE nodes
for i=1:length(ONE_nodes)
    ONE_neighbor_nodes = neighbors(G_connection,ONE_nodes(i)); %Neighboring nodes of the One element
    N=degree(G_connection,ONE_nodes(i)); %Number of connections of the node
    %Check for outdegree. An outdegree indicates number of effort out or
    %flow in causalities.
    ONE_node_outdegree = outdegree(G_causal,ONE_nodes(i));
    ONE_node_indegree = indegree(G_causal,ONE_nodes(i));
    if ONE_node_outdegree==1 && ONE_node_indegree==N-1
        %Do nothing
    elseif ONE_node_outdegree==1
        %Remove the succesor node from the neighbor node list and make the
        %remaining nodes as predecessors. There might already be few
        %predecessor nodes. Remove them as well
        succ_node = successors(G_causal,ONE_nodes(i));
        prev_pred_nodes = predecessors(G_causal,ONE_nodes(i));
        pred_nodes = setdiff(ONE_neighbor_nodes,[succ_node;prev_pred_nodes]);
        for j=1:length(pred_nodes)
            G_causal = addedge(G_causal,pred_nodes(j),ONE_nodes(i)); %Add edges From a predecessor node To a ONE node
        end
    elseif ONE_node_outdegree>1 || ONE_node_indegree==N
        error('ONE constraint Causality Conflict');
    elseif ONE_node_indegree==N-1
        %Remove the predecessor nodes from the neighbor node list and make
        %the remaining node a successor
        pred_nodes = predecessors(G_causal,ONE_nodes(i));
        succ_node = setdiff(ONE_neighbor_nodes,pred_nodes);
        G_causal = addedge(G_causal,ONE_nodes(i),succ_node); %Add edges From a successor node To a ONE node
    else
        %Do nothing as there isn't enough information
    end
end
end
