function G_causal = ZERO_constraint(G_connection,G_causal)
SE = 1;
SF = 2;
C = 3;
I = 4;
R = 5;
ONE = 6;
ZERO = 7;
TF = 8;
GY = 9;
ZERO_nodes = find(G_connection.Nodes.priority_id==ZERO); %Find ZERO nodes
for i=1:length(ZERO_nodes)
    ZERO_neighbor_nodes = neighbors(G_connection,ZERO_nodes(i)); %Neighboring nodes of the One element
    N=degree(G_connection,ZERO_nodes(i)); %Number of connections of the node. Degree works on graph while in/out degree work on digraph
    %Check for indegree. An indegree indicates number of effort in or
    %flow out causalities.
    ZERO_node_outdegree = outdegree(G_causal,ZERO_nodes(i));
    ZERO_node_indegree = indegree(G_causal,ZERO_nodes(i));
    if ZERO_node_indegree==1 && ZERO_node_outdegree==N-1
        %Do nothing
    elseif ZERO_node_indegree==1
        %Remove the predecessor node from the neighbor node list and make the
        %remaining nodes as successors. There might already be few
        %successor nodes. Remove them as well.
        pred_node = predecessors(G_causal,ZERO_nodes(i));
        prev_succ_nodes = successors(G_causal,ZERO_nodes(i));
        succ_nodes = setdiff(ZERO_neighbor_nodes,[pred_node;prev_succ_nodes]);
        for j=1:length(succ_nodes)
            G_causal = addedge(G_causal,ZERO_nodes(i),succ_nodes(j)); %Add edges From a ZERO node to To a successor node
        end
    elseif ZERO_node_indegree>1 || ZERO_node_outdegree==N
        error('ZERO constraint Causality Conflict');
    elseif ZERO_node_outdegree==N-1
        %Remove the successor nodes from the neighbor node list and make
        %the remaining node a predecessor
        succ_nodes = successors(G_causal,ZERO_nodes(i));
        pred_node = setdiff(ZERO_neighbor_nodes,succ_nodes);
        G_causal = addedge(G_causal,pred_node,ZERO_nodes(i)); %Add edges From a predecessor node To a ZERO node
    else
        %Do nothing as there isn't enough information
    end
end
end
