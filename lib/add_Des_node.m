function [H,new_node_id] = add_Des_node(G,node)

DES = 20;

DES_nodes = find(G.Nodes.priority_id==DES);
DES_num = extractAfter(G.Nodes.element_name(DES_nodes),'De*');%Find all Des node indices
DES_num = setdiff(DES_num,"");%Remove empty string ""

new_node_id = length(G.Nodes.id)+1; %Select the node id of the sensor

if (length(DES_nodes))==0  %If there are no Des nodes then the created node is named 'Des'
    str_new_element_name_id = {'De*'};
elseif ((length(DES_nodes))~=0) && length(DES_num)==0 %If there is a node named 'Des' 
    %then created node is named 'Des1'
    str_new_element_name_id = {append('De*',num2str(1))};
else
    DES_id = zeros(size(DES_num));
    for j=1:length(DES_num)
        DES_id(j,1) = str2num(DES_num(j,1));%else assign a number that has not already been assigned        
    end
    max_DES_id = max(DES_id);
    new_DES_id = max_DES_id + 1;
    str_new_element_name_id = {append('De*',num2str(new_DES_id))};
end
%Select the Des node name with properties (id |
%element_name | element_type | priority_id)
id=new_node_id;
element_name = str_new_element_name_id;
element_type = {'De*'};
priority_id = DES;
NodeProps = table(id,element_name,element_type,priority_id);
H = addnode(G, NodeProps);
%Add edges from node to Des node
%H = addedge(G,node,new_node_id); %Commented out as edge will be added in
%by Des_SCAP_I
end