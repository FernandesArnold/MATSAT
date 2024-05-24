function [H,new_node_id] = add_MSf_node(G,node)
%add_De_node base code modified to create add_Msf_node
MSF = 14;

MSF_nodes = find(G.Nodes.priority_id==MSF);
MSF_num = extractAfter(G.Nodes.element_name(MSF_nodes),'MSf');%Find all MSF node indices
MSF_num = setdiff(MSF_num,"");%Remove empty string ""

new_node_id = length(G.Nodes.id)+1; %Select the node id of the sensor

if (length(MSF_nodes))==0  %If there are no MSF nodes then the created node is named 'MSf'
    str_new_element_name_id = {'MSf'};
elseif ((length(MSF_nodes))~=0) && length(MSF_num)==0 %If there is a node named 'MSf' 
    %then created node is named 'MSf1'
    str_new_element_name_id = {append('MSf',num2str(1))};
else
    MSF_id = zeros(size(MSF_num));
    for j=1:length(MSF_num)
        MSF_id(j,1) = str2num(MSF_num(j,1));%else assign a number that has not already been assigned        
    end
    max_MSF_id = max(MSF_id);
    new_MSF_id = max_MSF_id + 1;
    str_new_element_name_id = {append('MSf',num2str(new_MSF_id))};
end
%Select the MSf node name with properties (id |
%element_name | element_type | priority_id)
id=new_node_id;
element_name = str_new_element_name_id;
element_type = {'MSf'};
priority_id = MSF;
NodeProps = table(id,element_name,element_type,priority_id);
H = addnode(G, NodeProps);
%Add edges from node to MSf node
%H = addedge(G,node,new_node_id); %Commented out as edge will be added in
%by SF_SCAP_I
end