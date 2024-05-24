%Sensor placement without expansion
clc; clear all; close all;
global BrBG
BrBG = [84	48	5
    140	81	10
    191	129	45
    223	194	125
    246	232	195
    245	245	245
    199	234	229
    128	205	193
    53	151	143
    1	102	94
    0	60	48]/255; % 11-color brown-bluegreen Brewer diverging map
global PiYG
PiYG = [142	1	82;
    197	27	125;
    222	119	174;
    241	182	218;
    253	224	239;
    247	247	247;
    230	245	208;
    184	225	134;
    127	188	65;
    77	146	33;
    39	100	25]/255; % 11-color pink-yellow-green Brewer diverging map
global PRGn
PRGn = [64	0	75;
    118	42	131;
    153	112	171;
    194	165	207;
    231	212	232;
    247	247	247;
    217	240	211;
    166	219	160;
    90	174	97;
    27	120	55;
    0	68	27]/255; % 11-color purple-green Brewer diverging map
global YlGnBu 
YlGnBu = [255	255	217;
    237	248	177;
    199	233	180;
    127	205	187;
    65	182	196;
    29	145	192;
    34	94	168;
    37	52	148;
    8	29	88]/255; % 9-color yellow-green-blue Brewer sequential map
global Wong 
Wong = [0 0 0;
    35,70,90;
    0,60,50;
    95,90,25;
    0,45,70;
    80,40,0]/100; % 6-color palette adapted from http://mkweb.bcgsc.ca/colorblind/img/colorblindness.palettes.trivial.png

set(groot,'DefaultFigureColormap',BrBG);
set(groot,'DefaultAxesColorOrder',Wong);
set(groot,'DefaultPolarAxesColorOrder',Wong);

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
DE = 10;
DF = 11;

%Add library files to path
oldpath = path;
path('../lib',oldpath)

%% Extract connection information from 20sim XML files and assign it to a table
%fid = fopen('../models/TwoTank355ProcessSupervision.emx');
fid = fopen('../models/causal_hoist_model.emx');


G_connection = BG_20sim_parser(fid);
fclose(fid);

layouttype='layered';
Pic_Width_1 = 5;
Pic_Height_1 = 5;
f1=figure(1)
plotData1 = plot(G_connection,'NodeLabel',G_connection.Nodes.element_name,'LineWidth', 2,'Layout',layouttype,'NodeColor',BrBG(1,:),'EdgeColor',BrBG(9,:));
node_1_XData = plotData1.XData;
node_1_YData = plotData1.YData;
node_1_LabelData = plotData1.NodeLabel;
plotData1.NodeLabel = {};

text1_label = text(node_1_XData, node_1_YData ,strcat(num2str(G_connection.Nodes.id),{', '},node_1_LabelData'), ...
    'VerticalAlignment','Bottom',...
    'HorizontalAlignment', 'left',...
    'FontSize', 8,'FontWeight','Bold');
set(text1_label,'Rotation',15)
axis off;
set(gca,'XColor', 'none','YColor','none')

%% Plotting the results
f1.Units='inches';
f1.Position=[0 0 Pic_Width_1 Pic_Height_1];
%f1.InnerPosition=[0 0 Pic_Width Pic_Height];
%f1.OuterPosition=[0 0 Pic_Width Pic_Height];
%set(gcf,'PaperUnits','inches','PaperPosition',[0 0 Pic_Width Pic_Height]);
%exportgraphics(f1, ['..\figures\20SimParser.pdf']);


%% Finding sensor locations
G_connection_temp = G_connection; %Creating a copy of the graph object
% G_connection_temp = BG_sensor_locations(G_connection_temp);
Pic_Width_2 = 5;
Pic_Height_2 = 5;
f2=figure(2)
plotData2 = plot(G_connection_temp,'NodeLabel',G_connection_temp.Nodes.element_name,'LineWidth', 2,'Layout',layouttype,'NodeColor',BrBG(1,:),'EdgeColor',BrBG(9,:))
node_2_XData = plotData2.XData;
node_2_YData = plotData2.YData;
node_2_LabelData = plotData2.NodeLabel;
plotData2.NodeLabel = {};
text2_label = text(node_2_XData-.1, node_2_YData+.01 ,strcat(num2str(G_connection_temp.Nodes.id),{', '},node_2_LabelData'), ...
    'VerticalAlignment','Bottom',...
    'HorizontalAlignment', 'left',...
    'FontSize', 8,'FontWeight','Bold');
set(text2_label,'Rotation',15)
axis off;
set(gca,'XColor', 'none','YColor','none')

%% Plotting the results
f2.Units='inches';
f2.Position=[0 0 Pic_Width_2 Pic_Height_2];
%f2.InnerPosition=[0 0 Pic_Width Pic_Height];
%f2.OuterPosition=[0 0 Pic_Width Pic_Height];
%set(gcf,'PaperUnits','inches','PaperPosition',[0 0 Pic_Width Pic_Height]);
exportgraphics(f2, ['..\figures\SensorLocations.pdf']);

%% Performing SCAP
G_effort_causal = BG_SCAP_I(G_connection_temp);
% Pic_Width_3 = 2;
% Pic_Height_3 = 1.5;
Pic_Width_3=5;
Pic_Height_3=5;
f3=figure(3)
plotData3 = plot(G_effort_causal,'NodeLabel',G_effort_causal.Nodes.element_name,'XData',node_2_XData,'YData',node_2_YData,'LineWidth', 2,'ArrowSize',15,'Arrowposition',1,'NodeColor',BrBG(1,:),'EdgeColor',BrBG(9,:))
node_3_XData = plotData3.XData;
node_3_YData = plotData3.YData;
node_3_LabelData = plotData3.NodeLabel;
plotData3.NodeLabel = {};
%Use plotData2 locations
text3_label = text(node_2_XData-.1, node_2_YData+.01 ,strcat(num2str(G_effort_causal.Nodes.id),{', '},node_3_LabelData'), ...
    'VerticalAlignment','Bottom',...
    'HorizontalAlignment', 'left',...
    'FontSize', 8,'FontWeight','bold');
set(text3_label,'Rotation',15)
axis off;
set(gca,'XColor', 'none','YColor','none')
%set(gca,'view',[90 90])
%% Plotting the results
f3.Units='inches';
f3.Position=[0 0 Pic_Width_3 Pic_Height_3];
%f3.InnerPosition=[0 0 Pic_Width Pic_Height];
%f3.OuterPosition=[0 0 Pic_Width Pic_Height];
%set(gcf,'PaperUnits','inches','PaperPosition',[0 0 Pic_Width Pic_Height]);
exportgraphics(f3, ['..\figures\SCAP.pdf']);
exportgraphics(f3, ['..\figures\SCAP.png']);

% Find all ONE and ZERO nodes as sensors will be attached at those nodes
ONE_nodes = find(G_effort_causal.Nodes.priority_id==ONE);
ZERO_nodes = find(G_effort_causal.Nodes.priority_id==ZERO);
C_nodes = find(G_effort_causal.Nodes.priority_id==C);
I_nodes = find(G_effort_causal.Nodes.priority_id==I);
R_nodes = find(G_effort_causal.Nodes.priority_id==R);
storage_nodes = [C_nodes;I_nodes];
passive_nodes = [storage_nodes;R_nodes];
% Sensors can be attached at either ONE or ZERO nodes
sensor_attachment_nodes = [ONE_nodes; ZERO_nodes];
sensor_locations = length(sensor_attachment_nodes);

%% Add sensor nodes
isStructObsv_flag=zeros(sensor_locations,1);
necessity_flag=zeros(sensor_locations,1);
sufficiency_flag=zeros(sensor_locations,1);


SO_table=[];
%Set plotBG to 1 if plots are needed along with analysis else supress the
%plots by setting plotBG to 0
plotBG = zeros(sensor_locations,1);
%Plot for below case
plotBG(2,1) = 1;
%Two sensors can be added with the setup below
for i=1:sensor_locations
    %Temporary effort causal graph obtained after adding sensor node to the original
    %causal graph
    [G_temp_effort_causal_1,new_node_id_1] = add_sensor_node(G_effort_causal,sensor_attachment_nodes(i));

        %Perform structural observability test
        [isStructObsv_flag(i), necessity_flag(i), sufficiency_flag(i)]=isStructObsv(G_temp_effort_causal_1, plotBG(i),node_2_XData,node_2_YData);

end
SO_table = table(sensor_attachment_nodes,sufficiency_flag,necessity_flag,isStructObsv_flag);
