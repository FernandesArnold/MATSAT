function [H,new_node_id] = add_ONE_node(G,node1,node2)
ONE = 6;
ONE_nodes = find(G.Nodes.priority_id==ONE);
G = rmedge(G,node1,node2); %Remove the edge that connects node1 and node2
%Add a ONE junction node to the existing connection graph
new_node_id = length(G.Nodes.id)+1; %Select the ONE junction node id
ONE_num = extractAfter(G.Nodes.element_name(ONE_nodes),'ONE');%Find all ONE junction node indices
ONE_num = setdiff(ONE_num,"");%Remove empty string ""
if (length(ONE_nodes))==0  %If there are no ONE nodes then the created node is named 'OneJunction'
    str_new_element_name_id = {'ONE'};
elseif ((length(ONE_nodes))~=0) && length(ONE_num)==0 %If there is a node named 'OneJunction' 
    %then created node is named 'OneJunction1'
    str_new_element_name_id = {append('ONE',num2str(1))};
else
    ONE_id = zeros(size(ONE_num));
    for j=1:length(ONE_num)
        ONE_id(j,1) = str2num(ONE_num(j,1));%else assign a number that has not already been assigned        
    end
    max_ONE_id = max(ONE_id);
    new_ONE_id = max_ONE_id + 1;
    str_new_element_name_id = {append('ONE',num2str(new_ONE_id))};
end
%Select the ONE junction node name with properties (id |
%element_name | element_type | priority_id)
id=new_node_id;
element_name = str_new_element_name_id;
element_type = {'OneJunction'};
priority_id = ONE;
NodeProps = table(id,element_name,element_type,priority_id);
G = addnode(G, NodeProps);
%Add edges from the ONE node to node1 and from ONE node to node2 with edge
%weight 4
G = addedge(G,node1,new_node_id,1);
H = addedge(G,node2,new_node_id,1);
end