%A script file containing the connection data and element type data needed
%to create a BG of the hoist system

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
%connection_data = [From_element To_element]
connection_data = ["Celast" "ZERO";
                    "Ddrum" "ZERO";
                    "Ddrum" "ONE1";
                    "J"     "ONE1";
                    "K"     "ONE";
                    "ONE"   "L";
                    "ONE"   "Rel";
                    "ONE"   "Usource";
                    "ONE1"  "Rbear";
                    "ONE2"  "m";
                    "ONE2"  "mg";
                    "ZERO"  "ONE2";
                    "ONE1"  "K"];
%% Code to obtain element names to place in first column of type_data
[unique_connection_data,~,ided_connections] = unique(connection_data)
[~,~,id] = unique(unique_connection_data)
%Generate element_name
%[element_name,~,id] = unique(unique_connection_data)
nexus_id = reshape(ided_connections, size(connection_data));% From and To information in the form of unique id's
%type_data = [element_name priority_id]
type_data = [ {"Celast",  C};
              {"Ddrum" ,  TF};
              {"J",       I};
              {"K" ,      GY};
              {"L"  ,     I};
              {"ONE" ,    ONE};
              {"ONE1" ,   ONE};
              {"ONE2" ,   ONE};
              {"Rbear",   R};
              {"Rel",     R};
              {"Usource", SE};
              {"ZERO",    ZERO};
              {"m",       I};
              {"mg",      SE}];
