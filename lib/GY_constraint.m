function G_causal = GY_constraint(G_connection,G_causal)
SE = 1;
SF = 2;
C = 3;
I = 4;
R = 5;
ONE = 6;
ZERO = 7;
TF = 8;
GY = 9;
GY_nodes = find(G_connection.Nodes.priority_id==GY); %Find GY nodes

for i=1:length(GY_nodes)
    GY_neighbor_nodes = neighbors(G_connection,GY_nodes(i)); %Neighboring nodes of the GY element
    %Check for indegree. An indegree indicates number of effort in or
    %flow out causalities.
    GY_node_outdegree = outdegree(G_causal,GY_nodes(i));
    GY_node_indegree = indegree(G_causal,GY_nodes(i));
    if (GY_node_indegree==2 && GY_node_outdegree==0) || (GY_node_outdegree==2 && GY_node_indegree==0) 
        %Do nothing
    elseif GY_node_indegree==1 && GY_node_outdegree==0
        %Remove the predecessor node from the neighbor node list and make the
        %remaining node a predecessor as well.
        pred_node_1 = predecessors(G_causal,GY_nodes(i));
        pred_node_2 = setdiff(GY_neighbor_nodes,pred_node_1);
        G_causal = addedge(G_causal,pred_node_2,GY_nodes(i)); %Add edges From a predecessor node To a GY node
    elseif GY_node_outdegree==1 && GY_node_indegree==0
        %Remove the current successor node from the neighbor node list and make
        %the remaining node a succesor as well
        succ_node_1 = successors(G_causal,GY_nodes(i));
        succ_node_2 = setdiff(GY_neighbor_nodes,succ_node_1);
        G_causal = addedge(G_causal,GY_nodes(i),succ_node_2); %Add edges From a predecessor node To a ZERO node
    elseif GY_node_indegree>2 || GY_node_outdegree>2
        error('GY constraint Causality Conflict');
    else
        %Do nothing
    end
end
end