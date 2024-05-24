clc; clear all; close all;

FROM = 1;
TO = 2;

SE = 1;
SF = 2;
C = 3;
I = 4;
R = 5;
ONE = 6;
ZERO = 7;
TF = 8;
GY = 9;

%Add library files to path
oldpath = path;
path('../lib',oldpath)

%% Extract connection information from 20sim XML files and assign it to a table
fid = fopen('../test_models/causal_hoist_model.emx');
%fid = fopen('../test_models/ONE_constraint_test_2.emx');
%fid = fopen('../test_models/ZERO_constraint_test.emx');
%fid = fopen('../test_models/TF_GY_constraint_test.emx');

G_connection = BG_20sim_parser(fid);
fclose(fid);

A_connection = adjacency(G_connection);
figure(1)
plot(G_connection,'NodeLabel',G_connection.Nodes.element_name)

G_power = digraph(id_nexus(:,FROM),id_nexus(:,TO)); %Digraph object created by using FROM and TO information
G_power.Nodes = tab; %Tabulated information for each element assigned to the digraph nodes
A_power = adjacency(G_power); %Adjacency matrix generated

G_causal = BG_SCAP_I(G_connection);
figure(2)
plot(G_causal,'NodeLabel',G_causal.Nodes.element_name)
