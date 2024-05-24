function G_connection = BG_20sim_parser(fid)
%% Extract location where connection information is present
% Read all lines & collect in cell array
txt = textscan(fid,'%s','delimiter','\n');
cellsize = size(txt{1});
lines = cellsize(1);

IndexC = strfind(txt{1},'connections');% Find the line containing the word 'connections'
Index_conn = find(not(cellfun('isempty',IndexC)));% Extract the index of the line
IndexE = strfind(txt{1},'end;');% Find the line containing the word 'end'
Index_end_temp = find(not(cellfun('isempty',IndexE))); % Extract the indices of the line containing 'end'
Index_end = Index_end_temp(find( Index_end_temp > Index_conn, 1 ));% Extract the first occurence after 'connections'
line_start = Index_conn+1;% First line of connections
line_end = Index_end-1;%Last line of connections

%% Power bond parser
connection_data = strings(line_end-line_start+1,2);
k=1;
for i = line_start:line_end
    mainstring =  txt{1}{i};
    if ~isempty(strfind(mainstring,'=>'))
        %     extact from node
        connection_data{k,1} = extractBefore(mainstring,'\');
        %     extract to node
        connection_data{k,2} = extractBefore( extractAfter(mainstring,'=> '), '\');

    elseif ~isempty(strfind(mainstring,'<='))
        %     extact from node
        connection_data{k,2} = extractBefore(mainstring,'\');
        %     extract to node
        connection_data{k,1} = extractBefore( extractAfter(mainstring,'<= '), '\');

    elseif ~isempty(strfind(mainstring,'->'))
        %     extact from node
        connection_data{k,1} = extractBefore(mainstring,'\');
        %     extract to node
        connection_data{k,2} = extractBefore( extractAfter(mainstring,'-> '), '\');

    elseif ~isempty(strfind(mainstring,'<-'))
        %     extact from node
        connection_data{k,2} = extractBefore(mainstring,'\');
        %     extract to node
        connection_data{k,1} = extractBefore( extractAfter(mainstring,'<- '), '\');
    end

    k=k+1;
end

%% Type assignments
[unique_connection_data,~,ided_connections] = unique(connection_data);
[element_name,~,id] = unique(unique_connection_data); % Extract unique strings and id them
nexus_id = reshape(ided_connections, size(connection_data));% From and To information in the form of unique id's
no_elements=length(element_name);%Number of elements in the BG

Index_type_temp = strfind(txt{1},'type');% Find the line containing 'type'
type_hits = find(not(cellfun('isempty',Index_type_temp)));% Extract the indices of all occurences of 'type'

Index_knot_temp = strfind(txt{1},'knot');% Find the line containing 'knot'
knot_hits = find(not(cellfun('isempty',Index_knot_temp)));% Extract the indices of all occurences of 'knot'


element_type = strings(no_elements,1);

for i=1:no_elements
    search_str = append(element_name(i),' ');
    %IndexBGE_temp = strfind(txt{1},C(i));% Find the line containing the element C(i)
    IndexBGE_temp = strfind(txt{1},search_str);% Find the line containing the element C(i)
    Index_BGE = find(not(cellfun('isempty',IndexBGE_temp)),1);% Extract the index of the first occurence of element

    % assign if elemnet is 'type'
    type_hit_val = type_hits(find(type_hits>Index_BGE,1));
    knot_hit_val = knot_hits(find(knot_hits>Index_BGE,1));
    if isempty(type_hit_val)
        type_hit_val = lines; % give a large number so it wont interfere
    elseif isempty(knot_hit_val)
        knot_hit_val = lines; % give a large number so it wont interfere
    end

    if type_hit_val < knot_hit_val
        % fprintf('%s is type\n',C(i))
        temp_line_index = type_hits(find(type_hits>Index_BGE,1));
        temp_string =  txt{1}{temp_line_index};
        element_type(i) = extractAfter(temp_string,'type ');
    elseif knot_hit_val < type_hit_val
        % fprintf('%s is knot\n',C(i))
        temp_line_index = knot_hits(find(knot_hits>Index_BGE,1));
        temp_string =  txt{1}{temp_line_index};
        element_type(i) = extractAfter(temp_string,'knot ');
    end

end
%% Priority ID assignment
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
IC = 12;
MSE = 13;
MSF = 14;
MR = 15;
MTF = 16;
MGY = 17;
DS = 18;
SS = 19;
DES = 20;
DFS = 21;
DSS = 22;

priority_id = zeros(length(element_type),1);
for i=1:length(element_type)
    if strcmp(element_type(i),'Se')
        priority_id(i)=SE;
    elseif strcmp(element_type(i),'Sf')
        priority_id(i)=SF;
    elseif strcmp(element_type(i),'C')
        priority_id(i)=C;
    elseif strcmp(element_type(i),'I')
        priority_id(i)=I;
    elseif strcmp(element_type(i),'R')
        priority_id(i)=R;
    elseif strcmp(element_type(i),'OneJunction')
        priority_id(i)=ONE;
    elseif strcmp(element_type(i),'ZeroJunction')
        priority_id(i)=ZERO;
    elseif strcmp(element_type(i),'TF')
        priority_id(i)=TF;
    elseif strcmp(element_type(i),'GY')
        priority_id(i)=GY;
    elseif strcmp(element_type(i),'De')
        priority_id(i)=DE;
    elseif strcmp(element_type(i),'Df')
        priority_id(i)=DF;
    elseif strcmp(element_type(i),'IC')
        priority_id(i)=IC;
    elseif strcmp(element_type(i),'MSe')
        priority_id(i)=MSE;
    elseif strcmp(element_type(i),'MSf')
        priority_id(i)=MSF;
    elseif strcmp(element_type(i),'MR')
        priority_id(i)=MR;
    elseif strcmp(element_type(i),'MTF')
        priority_id(i)=MTF;
    elseif strcmp(element_type(i),'MGY')
        priority_id(i)=MGY;
    elseif strcmp(element_type(i),'Ds') %Signal Detector
        priority_id(i)=DS;
    elseif strcmp(element_type(i),'Ss') %Signal Source
        priority_id(i)=SS;
    elseif strcmp(element_type(i),'De*') %Virtual effort detector (residual)
        priority_id(i)=DES;
    elseif strcmp(element_type(i),'Df*') %Virtual flow detector (residual)
        priority_id(i)=DFS;
    elseif strcmp(element_type(i),'Ds*') %Virtual signal detector (residual)
        priority_id(i)=DSS;
    else
        priority_id(i)=0;
    end
end

%Ignore elements with priority_id 0. Work later. For now do not add
%element type not catalogued

master_table = table(id, element_name ,element_type,priority_id);

FROM = 1;
TO = 2;

%% Assigning connection and table information to connection, power, and causal graph objects
G_connection = graph(nexus_id(:,FROM),nexus_id(:,TO)); %Graph object created by using FROM and TO information
G_connection.Nodes = master_table; %Tabulated information for each element assigned to the graph nodes
G_connection.Edges.Weight=1*ones(size(G_connection.Edges,1),1);
end