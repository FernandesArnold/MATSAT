function G_connection = BG_creator(id, nexus_id, type_data)
%A function file that creates a connection graph from the id, nexus_id, and
%element type data

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

FROM = 1;
TO = 2;

no_elements=length(type_data);%Number of elements in the BG
element_type = strings(no_elements,1)
element_name = string(type_data(:,1))
priority_id = cell2mat(type_data(:,2))
for i=1:length(element_type)
    if priority_id(i)==SE
        element_type(i)='Se';
    elseif priority_id(i)==SF
        element_type(i)='Sf';
    elseif priority_id(i)==C
        element_type(i)='C';
    elseif priority_id(i)==I
        element_type(i)='I';
    elseif priority_id(i)==R
        element_type(i)='R';
    elseif priority_id(i)==ONE
        element_type(i)='OneJunction';
    elseif priority_id(i)==ZERO
        element_type(i)='ZeroJunction';
    elseif priority_id(i)==TF
        element_type(i)='TF';
    elseif priority_id(i)==GY
        element_type(i)='GY';
    elseif priority_id(i)==DE
        element_type(i)='De';
    elseif priority_id(i)==DF
        element_type(i)='Df';
    elseif priority_id(i)==IC
        element_type(i)='IC';
    elseif priority_id(i)==MSE
        element_type(i)='MSe';
    elseif priority_id(i)==MSF
        element_type(i)='MSf';
    elseif priority_id(i)==MR
        element_type(i)='MR';
    elseif priority_id(i)==MTF
        element_type(i)='MTF';
    elseif priority_id(i)==MGY
        element_type(i)='MGY';
    elseif priority_id(i)==DS %Signal Detector
        element_type(i)='Ds';
    elseif priority_id(i)==SS %Signal Source
        element_type(i)='Ss';
    elseif priority_id(i)==DES %Virtual effort detector (residual)
        element_type(i)='De*';
    elseif priority_id(i)==DFS %Virtual flow detector (residual)
        element_type(i)='Df*';
    elseif priority_id(i)==DSS %Virtual signal detector (residual)
        element_type(i)='Ds*';
    else
        error("unknown priority_id");
    end
end
master_table = table(id, element_name, element_type, priority_id);

%% Assigning connection and table information to connection, power, and causal graph objects
G_connection = graph(nexus_id(:,FROM),nexus_id(:,TO)); %Graph object created by using FROM and TO information
G_connection.Nodes = master_table; %Tabulated information for each element assigned to the graph nodes
G_connection.Edges.Weight=1*ones(size(G_connection.Edges,1),1);