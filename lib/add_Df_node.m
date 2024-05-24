function [H,new_node_id] = add_Df_node(G,node)

DF = 11;

DF_nodes = find(G.Nodes.priority_id==DF);
DF_num = extractAfter(G.Nodes.element_name(DF_nodes),'Df');%Find all Df node indices
DF_num = setdiff(DF_num,"");%Remove empty string ""

new_node_id = length(G.Nodes.id)+1; %Select the node id of the sensor

if (length(DF_nodes))==0  %If there are no Df nodes then the created node is named 'Df'
    str_new_element_name_id = {'Df'};
elseif ((length(DF_nodes))~=0) && length(DF_num)==0 %If there is a node named 'Df' 
    %then created node is named 'Df1'
    str_new_element_name_id = {append('Df',num2str(1))};
else
    Df_id = zeros(size(DF_num));
    for j=1:length(DF_num)
        Df_id(j,1) = str2num(DF_num(j,1));%else assign a number that has not already been assigned        
    end
    max_Df_id = max(Df_id);
    new_Df_id = max_Df_id + 1;
    str_new_element_name_id = {append('Df',num2str(new_Df_id))};
end
%Select the DF node name with properties (id |
%element_name | element_type | priority_id)
id=new_node_id;
element_name = str_new_element_name_id;
element_type = {'Df'};
priority_id = DF;
NodeProps = table(id,element_name,element_type,priority_id);
G = addnode(G, NodeProps);
%Add edges from the DF to node
H = addedge(G,new_node_id,node); 
end