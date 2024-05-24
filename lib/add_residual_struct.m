function G = add_residual_struct(G,sensor_nodes,non_inv_sensor_flag)
%add_sensor_node basecode modified to add residual structure
SE = 1;
SF = 2;
C = 3;
I = 4;
R = 5;
ONE = 6;
ZERO = 7;
TF = 8;
GY = 9;
DE = 10;
DF = 11;
MSE = 13;
MSF = 14;
DES = 20; %De*
DFS = 21; %Df*

nonzero_nodes=sensor_nodes(sensor_nodes~=0);
nodes_count = length(nonzero_nodes);
new_virt_node_id = zeros(nodes_count);%Virtual sensor nodes
new_modsource_node_id = zeros(nodes_count);

nodes_type = G.Nodes.priority_id(nonzero_nodes);

for i=1:nodes_count
    if nodes_type(i)== DE
        
        DE_neighbor_node = neighbors(G, nonzero_nodes(i));
        [G,ONE_node_id] = add_ONE_node(G, DE_neighbor_node, nonzero_nodes(i));
        [G,new_modsource_node_id(i)] = add_MSe_node(G,ONE_node_id);
        G = addedge(G,ONE_node_id,new_modsource_node_id(i),1);
      
        if non_inv_sensor_flag(i)==1
            %Add De* node
            [G,new_virt_node_id(i)] = add_Des_node(G,ONE_node_id);
            G = addedge(G,ONE_node_id,new_virt_node_id(i),1);
        else
            %Add Df* node
            [G,new_virt_node_id(i)] = add_Dfs_node(G,ONE_node_id);
            G = addedge(G,ONE_node_id,new_virt_node_id(i),1);
        end
    elseif nodes_type(i)==DF

        DF_neighbor_node = neighbors(G, nonzero_nodes(i));
        [G,ZERO_node_id] = add_ZERO_node(G, DF_neighbor_node, nonzero_nodes(i));
        [G,new_modsource_node_id(i)] = add_MSf_node(G,ZERO_node_id);
        G = addedge(G,ZERO_node_id,new_modsource_node_id(i),1);

       if non_inv_sensor_flag(i)==1
           %Add Df* node
            [G,new_virt_node_id(i)] = add_Dfs_node(G,ZERO_node_id);
            G = addedge(G,ZERO_node_id,new_virt_node_id(i),1);
       else
           %Add De* node
            [G,new_virt_node_id(i)] = add_Des_node(G,ZERO_node_id);
            G = addedge(G,ZERO_node_id,new_virt_node_id(i),1);
        end
    end
end

G = rmnode(G,nonzero_nodes);


end
