function [H,new_node_id] = add_MSe_node(G,node)

MSE = 13;

MSE_nodes = find(G.Nodes.priority_id==MSE);
MSE_num = extractAfter(G.Nodes.element_name(MSE_nodes),'MSe');%Find all MSe node indices
MSE_num = setdiff(MSE_num,"");%Remove empty string ""

new_node_id = length(G.Nodes.id)+1; %Select the node id of the sensor

if (length(MSE_nodes))==0  %If there are no MSe nodes then the created node is named 'MSe'
    str_new_element_name_id = {'MSe'};
elseif ((length(MSE_nodes))~=0) && length(MSE_num)==0 %If there is a node named 'MSe' 
    %then created node is named 'MSe1'
    str_new_element_name_id = {append('MSe',num2str(1))};
else
    MSE_id = zeros(size(MSE_num));
    for j=1:length(MSE_num)
        MSE_id(j,1) = str2num(MSE_num(j,1));%else assign a number that has not already been assigned        
    end
    max_MSE_id = max(MSE_id);
    new_MSE_id = max_MSE_id + 1;
    str_new_element_name_id = {append('MSe',num2str(new_MSE_id))};
end
%Select the MSe node name with properties (id |
%element_name | element_type | priority_id)
id=new_node_id;
element_name = str_new_element_name_id;
element_type = {'MSe'};
priority_id = MSE;
NodeProps = table(id,element_name,element_type,priority_id);
H = addnode(G, NodeProps);
%Add edges from the MSe to node
%H = addedge(G,new_node_id,node); %Commented out as edge will be added in
%by SE_SCAP_I
end