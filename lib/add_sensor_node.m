function [H,new_node_id] = add_sensor_node(G,nodes)
ONE = 6;
ZERO = 7;
nonzero_nodes=nodes(nodes~=0);
nodes_count = length(nonzero_nodes);
new_node_id = zeros(nodes_count);

nodes_type = G.Nodes.priority_id(nonzero_nodes);
H=G;
for i=1:nodes_count
    if nodes_type(i)==ONE
        [H,new_node_id(i)] = add_Df_node(H,nonzero_nodes(i));
    elseif nodes_type(i)==ZERO
        [H,new_node_id(i)] = add_DE_node(H,nonzero_nodes(i));
    end
end
end