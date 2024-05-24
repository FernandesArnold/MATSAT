function [H,new_node_id] = add_Dfs_node(G,node)
%add_Df_node base code utilized for adding Df* nodes
DFS = 21; %Df*

DFS_nodes = find(G.Nodes.priority_id==DFS);
DFS_num = extractAfter(G.Nodes.element_name(DFS_nodes),'Df*');%Find all Df* node indices
DFS_num = setdiff(DFS_num,"");%Remove empty string ""

new_node_id = length(G.Nodes.id)+1; %Select the node id of the sensor

if (length(DFS_nodes))==0  %If there are no Dfs nodes then the created node is named 'Dfs'
    str_new_element_name_id = {'Df*'};
elseif ((length(DFS_nodes))~=0) && length(DFS_num)==0 %If there is a node named 'Dfs' 
    %then created node is named 'Dfs1'
    str_new_element_name_id = {append('Df*',num2str(1))};
else
    Dfs_id = zeros(size(DFS_num));
    for j=1:length(DFS_num)
        Dfs_id(j,1) = str2num(DFS_num(j,1));%else assign a number that has not already been assigned        
    end
    max_Dfs_id = max(Dfs_id);
    new_Dfs_id = max_Dfs_id + 1;
    str_new_element_name_id = {append('Df*',num2str(new_Dfs_id))};
end
%Select the DF node name with properties (id |
%element_name | element_type | priority_id)
id=new_node_id;
element_name = str_new_element_name_id;
element_type = {'Df*'};
priority_id = DFS;
NodeProps = table(id,element_name,element_type,priority_id);
H = addnode(G, NodeProps);
%Add edges from the Df* to node
%H = addedge(G,new_node_id,node); %Commented out as edge will be added in
%by Dfs_SCAP_I
end