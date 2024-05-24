function [H,new_node_id] = add_ZERO_node(G,node1,node2)
ZERO = 7;
ZERO_nodes = find(G.Nodes.priority_id==ZERO);
G = rmedge(G,node1,node2); %Remove the edge that connects node1 and node2
%Add a ZERO junction node to the existing connection graph
new_node_id = length(G.Nodes.id)+1; %Select the ZERO junction node id
ZERO_num = extractAfter(G.Nodes.element_name(ZERO_nodes),'ZERO');%Find all zero junction node indices
ZERO_num = setdiff(ZERO_num,"");%Remove empty string ""
if (length(ZERO_nodes))==0  %If there are no zero nodes then the created node is named 'ZeroJunction'
    str_new_element_name_id = {'ZERO'};
elseif ((length(ZERO_nodes))~=0) && length(ZERO_num)==0 %If there is a node named 'ZeroJunction' 
    %then created node is named 'ZeroJunction1'
    str_new_element_name_id = {append('ZERO',num2str(1))};
else
    ZERO_id = zeros(size(ZERO_num));
    for j=1:length(ZERO_num)
        ZERO_id(j,1) = str2num(ZERO_num(j,1));%else assign a number that has not already been assigned        
    end  
    max_ZERO_id = max(ZERO_id);
    new_ZERO_id = max_ZERO_id + 1;
    str_new_element_name_id = {append('ZERO',num2str(new_ZERO_id))};
end
%Select the ZERO junction node name with properties (id |
%element_name | element_type | priority_id)
id=new_node_id;
element_name = str_new_element_name_id;
element_type = {'ZeroJunction'};
priority_id = ZERO;
NodeProps = table(id,element_name,element_type,priority_id);
G = addnode(G, NodeProps);
%Add edges from the ZERO node to node and from ZERO node to node2 with
%edge weight 4
G = addedge(G,node1,new_node_id,1);
H = addedge(G,node2,new_node_id,1);
end