function [H,new_node_id] = add_DE_node(G,node)

DE = 10;

DE_nodes = find(G.Nodes.priority_id==DE);
DE_num = extractAfter(G.Nodes.element_name(DE_nodes),'De');%Find all DE node indices
DE_num = setdiff(DE_num,"");%Remove empty string ""

new_node_id = length(G.Nodes.id)+1; %Select the node id of the sensor

if (length(DE_nodes))==0  %If there are no DE nodes then the created node is named 'De'
    str_new_element_name_id = {'De'};
elseif ((length(DE_nodes))~=0) && length(DE_num)==0 %If there is a node named 'De' 
    %then created node is named 'De1'
    str_new_element_name_id = {append('De',num2str(1))};
else
    DE_id = zeros(size(DE_num));
    for j=1:length(DE_num)
        DE_id(j,1) = str2num(DE_num(j,1));%else assign a number that has not already been assigned        
    end
    max_DE_id = max(DE_id);
    new_DE_id = max_DE_id + 1;
    str_new_element_name_id = {append('De',num2str(new_DE_id))};
end
%Select the DE node name with properties (id |
%element_name | element_type | priority_id)
id=new_node_id;
element_name = str_new_element_name_id;
element_type = {'De'};
priority_id = DE;
NodeProps = table(id,element_name,element_type,priority_id);
G = addnode(G, NodeProps);
%Add edges from node to DE node
H = addedge(G,node,new_node_id); 
end