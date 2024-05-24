function [isStructObsv_flag, necessity_flag, sufficiency_flag]=isStructObsv(G_effort,plotBG,node_2_XData,node_2_YData)

global BrBG

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

C_nodes = find(G_effort.Nodes.priority_id==C);
I_nodes = find(G_effort.Nodes.priority_id==I);

storage_nodes = [C_nodes;I_nodes];

if plotBG==1
    Pic_Width_0=5;
    Pic_Height_0=5;
    f0=figure
    %plotData4 = plot(G_effort,'NodeLabel',G_effort.Nodes.element_name,'XData',[node_2_XData,2.8],'YData',[node_2_YData,12.4],'LineWidth', 2,'ArrowSize',15,'Arrowposition',1,'NodeColor',BrBG(1,:),'EdgeColor',BrBG(9,:))
    plotData4 = plot(G_effort,'NodeLabel',G_effort.Nodes.element_name,'XData',[node_2_XData,1],'YData',[node_2_YData,5],'LineWidth', 2,'ArrowSize',15,'Arrowposition',1,'NodeColor',BrBG(1,:),'EdgeColor',BrBG(9,:))
    node_4_XData = plotData4.XData;
    node_4_YData = plotData4.YData;
    node_4_LabelData = plotData4.NodeLabel;
    plotData4.NodeLabel = {};
    % node_LabelData = G_effort.Nodes.element_name;
    % Add new labels that are to the upper, right of the nodes(code suggestion
    % Adam Danz)https://www.mathworks.com/matlabcentral/answers/477770-is-it-possible-to-change-the-position-of-graph-plot-node-labels
    text4_label = text(node_4_XData-.1, node_4_YData+.01 ,strcat(num2str(G_effort.Nodes.id),{', '},node_4_LabelData'), ...
        'VerticalAlignment','Bottom',...
        'HorizontalAlignment', 'left',...
        'FontSize', 10,'FontWeight','Bold')
    set(text4_label,'Rotation',15)
    axis off;
    set(gca,'XColor', 'none','YColor','none')
    %% Plotting the results
    f0.Units='inches';
    f0.Position=[0 0 Pic_Width_0 Pic_Height_0];
    %f0.InnerPosition=[0 0 Pic_Width_0 Pic_Height_0];
    %f0.OuterPosition=[0 0 Pic_Width_0 Pic_Height_0];
    %set(gcf,'PaperUnits','inches','PaperPosition',[0 0 Pic_Width_0 Pic_Height_0]);
    %exportgraphics(f0, [pwd '\Figures\SensorEffortCausal.pdf']);
    %exportgraphics(f0, [pwd '\Figures\SensorEffortCausal.png']);
end

%Obtain a flow causal graph after flipping the edges


G_flow =  flipedge(G_effort);

if plotBG==1
    Pic_Width_1=5;
    Pic_Height_1=5;
    f1=figure
    plotData5 = plot(G_flow,'NodeLabel',G_flow.Nodes.element_name,'XData',node_4_XData,'YData',node_4_YData,'LineWidth', 2,'ArrowSize',15,'Arrowposition',1,'NodeColor',BrBG(1,:),'EdgeColor',BrBG(9,:))
    plotData5.NodeLabel = {};
    text5_label = text(node_4_XData-.1, node_4_YData+.01 ,strcat(num2str(G_flow.Nodes.id),{', '},node_4_LabelData'), ...
        'VerticalAlignment','Bottom',...
        'HorizontalAlignment', 'left',...
        'FontSize', 10,'FontWeight','Bold')
    set(text5_label,'Rotation',15)
    axis off;
    set(gca,'XColor', 'none','YColor','none')
    %% Plotting the results
    f1.Units='inches';
    f1.Position=[0 0 Pic_Width_1 Pic_Height_1];
    %f1.InnerPosition=[0 0 Pic_Width_1 Pic_Height_1];
    %f1.OuterPosition=[0 0 Pic_Width_1 Pic_Height_1];
    %set(gcf,'PaperUnits','inches','PaperPosition',[0 0 Pic_Width_1 Pic_Height_1]);
    %exportgraphics(f1, [pwd '\Figures\SensorFlowCausal.pdf']);
    %exportgraphics(f1, [pwd '\Figures\SensorFlowCausal.png']);
end
    
%Identify source and sensor node indices
necessity_flag = 0;
k=1;%Index used to prevent infinite while loop.
DE_nodes = find(G_effort.Nodes.priority_id==DE);%Effort sensor nodes
DF_nodes = find(G_effort.Nodes.priority_id==DF);%Flow sensor nodes
sensor_nodes = [DE_nodes;DF_nodes];%Sensor nodes
SE_nodes = find(G_effort.Nodes.priority_id==SE);%Effort source nodes
SF_nodes = find(G_effort.Nodes.priority_id==SF);%Flow source nodes
source_nodes = [SE_nodes;SF_nodes];%Source nodes
sensor_source_nodes = [sensor_nodes;source_nodes];%Sensor and source nodes

%% BG Necessary condition check
%Initialize the start nodes for the effort causal graph
T_start_nodes = DF_nodes;%Initialize start nodes as flow nodes
T_visited_nodes = T_start_nodes;%Terminal nodes visited
T_terminal_nodes = [];%Initialize terminal nodes
T_visited_terminal_nodes = T_terminal_nodes;%Initialize terminal nodes visited
T_discover_nodes = [];%Initialize nodes discovered
T_visited_discover_nodes = T_discover_nodes;%Initialize visited discover nodes
T_visited_terminal_storage_nodes=[];

%Initialize the start nodes for the flow causal graph
U_terminal_nodes = [];
U_visited_terminal_nodes = U_terminal_nodes;
U_visited_terminal_storage_nodes = [];
U_discover_nodes = [];
U_visited_discover_nodes = U_discover_nodes;

%while the storage_nodes are not a subset of the union of the
%T_visited_terminal_nodes and the U_visited_terminal_nodes & k<3 , keep
%checking for causal paths from the sensors to the storage elements
while (~all(ismember(storage_nodes,union(T_visited_terminal_nodes,U_visited_terminal_nodes)))) && (k<5) %k<3 gives incorrect results so k<5 is set
    %Perform a depth-first search from the flow sensors on the effort
    %causal graph if k==1, otherwise the terminal sensors of the flow causal graph are used as the start nodes
    for i=1:length(T_start_nodes)
        %Perform the depth-first search and generate a table of all events
        %'T'. Events include 'discovernode', 'finishnode', 'edgetonew',
        %etc.
        T = dfsearch(G_effort, T_start_nodes(i), 'allevents');
        %Store the node indices related the the 'discovernode' event
        T_discover_nodes = find(T.Event=='discovernode');
        %Add the new discovered nodes to the array of previously discovered
        %nodes
        T_visited_discover_nodes = unique([T_visited_discover_nodes; T.Node(T_discover_nodes)]);%Code corrected
        %Store the finish nodes
        T_finish_nodes = find(T.Event=='finishnode');
        %If after a 'discovernode' event, a 'finishnode' event occurs then
        %the corresonding node is a terminal node
        T_terminal_nodes=unique([T_terminal_nodes;T.Node(T_discover_nodes(ismember(T_discover_nodes+1,T_finish_nodes)))]);
    end
    %Add the newly discovered terminal nodes to the array of previously
    %discovered terminal nodes
    T_visited_terminal_nodes = unique([T_visited_terminal_nodes;T_terminal_nodes]);%union() could also be used here
    T_visited_terminal_storage_nodes = intersect(T_visited_terminal_nodes,storage_nodes);
    T_visited_nodes = unique([T_visited_nodes;T_start_nodes;T_visited_discover_nodes;T_visited_terminal_nodes]);
    % A discovernode event following with a finishnode event is a terminal storage element or could
    % be a GY. Ignore finishnodes that are sources?
    
    %Remove terminating source/sensor nodes before performing a causal path
    %search on the complementary graph.
    if k==1
        U_start_nodes = reshape(union(DE_nodes,setdiff(T_terminal_nodes,sensor_source_nodes)),[],1);%Reshape all vectors to column vectors
        U_visited_nodes = T_terminal_nodes;
    else
        U_start_nodes = setdiff(T_terminal_nodes,sensor_source_nodes);
    end
    
    for i=1:length(U_start_nodes)
        %Perform the depth-first search and generate a table of all events
        %'U'. Events include 'discovernode', 'finishnode', 'edgetonew',
        %etc.
        U = dfsearch(G_flow, U_start_nodes(i), 'allevents');
        %Store the node indices related the the 'discovernode' event
        U_discover_nodes = find(U.Event=='discovernode');
        %Add the new discovered nodes to the array of previously discovered
        %nodes
        U_visited_discover_nodes = unique([U_visited_discover_nodes; U.Node(U_discover_nodes)]);%Code corrected
        %Store the finish nodes
        U_finish_nodes = find(U.Event=='finishnode');
        %If after a 'discovernode' event, a 'finishnode' event occurs then
        %the corresonding node is a terminal node
        U_terminal_nodes=unique([U_terminal_nodes;U.Node(U_discover_nodes(ismember(U_discover_nodes+1,U_finish_nodes)))]);
    end
    %Add the newly discovered terminal nodes to the array of previously
    %discovered terminal nodes
    U_visited_terminal_nodes = unique([U_visited_terminal_nodes;U_terminal_nodes]);%union() could also be used here
    U_visited_terminal_storage_nodes = intersect(U_visited_terminal_nodes,storage_nodes);
    U_visited_nodes = unique([U_visited_nodes;U_start_nodes;U_visited_discover_nodes;U_visited_terminal_nodes]);
    
    T_start_nodes = setdiff(U_terminal_nodes,sensor_source_nodes);
    k=k+1;
end
visited_terminal_nodes = reshape(union(T_visited_terminal_nodes,U_visited_terminal_nodes),[],1);
visited_terminal_storage_nodes = reshape(union(T_visited_terminal_storage_nodes,U_visited_terminal_storage_nodes),[],1);


%% BG sufficiency check
%Create connection graph object with sensor nodes
A_sensor_connection = adjacency(G_effort)+adjacency(G_effort)';
G_sensor_connection = graph(A_sensor_connection,G_effort.Nodes);

if plotBG==1
    Pic_Width_2=5;
    Pic_Height_2=5;
    f2=figure
    plotData6 = plot(G_sensor_connection,'NodeLabel',G_sensor_connection.Nodes.element_name,'XData',node_4_XData,'YData',node_4_YData,'LineWidth', 2,'NodeColor',BrBG(1,:),'EdgeColor',BrBG(9,:))
    node_6_XData = plotData6.XData;
    node_6_YData = plotData6.YData;
    node_6_LabelData = plotData6.NodeLabel;
    plotData6.NodeLabel = {};
    % node_LabelData = G_effort.Nodes.element_name;
    % Add new labels that are to the upper, right of the nodes(code suggestion
    % Adam Danz)https://www.mathworks.com/matlabcentral/answers/477770-is-it-possible-to-change-the-position-of-graph-plot-node-labels
    text6_label = text(node_6_XData-.1, node_6_YData+.01 ,strcat(num2str(G_sensor_connection.Nodes.id),{', '},node_6_LabelData'), ...
        'VerticalAlignment','Bottom',...
        'HorizontalAlignment', 'left',...
        'FontSize', 10,'FontWeight','Bold')
    set(text6_label,'Rotation',15)
    axis off;
    set(gca,'XColor', 'none','YColor','none')
    %% Plotting the results
    f2.Units='inches';
    f2.Position=[0 0 Pic_Width_2 Pic_Height_2];
    %f2.InnerPosition=[0 0 Pic_Width_2 Pic_Height_2];
    %f2.OuterPosition=[0 0 Pic_Width_2 Pic_Height_2];
    %set(gcf,'PaperUnits','inches','PaperPosition',[0 0 Pic_Width_2 Pic_Height_2]);
    %exportgraphics(f2, [pwd '\Figures\SensorConnection.pdf']);
    %exportgraphics(f2, [pwd '\Figures\SensorConnection.png']);
end

G_inverted_causal = BG_SCAP_D(G_sensor_connection);

if plotBG==1
    Pic_Width_3=5;
    Pic_Height_3=5;
    f3=figure
    plotData7 = plot(G_inverted_causal,'NodeLabel',G_inverted_causal.Nodes.element_name,'XData',node_6_XData,'YData',node_6_YData,'LineWidth', 2,'ArrowSize',15,'Arrowposition',1,'NodeColor',BrBG(1,:),'EdgeColor',BrBG(9,:))
    node_7_XData = plotData7.XData;
    node_7_YData = plotData7.YData;
    node_7_LabelData = plotData7.NodeLabel;
    plotData7.NodeLabel = {};
    text7_label = text(node_7_XData-.1, node_7_YData+.01 ,strcat(num2str(G_inverted_causal.Nodes.id),{', '},node_7_LabelData'), ...
        'VerticalAlignment','Bottom',...
        'HorizontalAlignment', 'left',...
        'FontSize', 10,'FontWeight','Bold')
    set(text7_label,'Rotation',15)
    axis off;
    set(gca,'XColor', 'none','YColor','none')
    %% Plotting the results
    f3.Units='inches';
    f3.Position=[0 0 Pic_Width_3 Pic_Height_3];
    %f3.InnerPosition=[0 0 Pic_Width_3 Pic_Height_3];
    %f3.OuterPosition=[0 0 Pic_Width_3 Pic_Height_3];
    %set(gcf,'PaperUnits','inches','PaperPosition',[0 0 Pic_Width_3 Pic_Height_3]);
    %exportgraphics(f3, [pwd '\Figures\SensorSCAP_D.pdf']);
    %exportgraphics(f3, [pwd '\Figures\SensorSCAP_D.png']);
end

%% Final check for observability
%1. Query edges of storage elements to find if they take integral causality in
%the bond graph model with preferred integral causality
%2. Query edges of storage elements to find if they take derivative causality in
%the bond graph model with preferred differential causality
%If int_storage_nodes==diff_storage_nodes then the provided sensor
%placement makes the system observable.
int_storage_nodes=[];
diff_storage_nodes=[];
%1. Query edges of storage elements to find if they take integral causality in
%the bond graph model with preferred integral causality
for i=1:length(storage_nodes)
    if ismember(storage_nodes(i),C_nodes)
        %For bond graph with preferred integral causality, if nodes are of C type then check if there exists an edge ponting away from
        %the element. If the edge points toward the element do not add it to
        %the int_storage_nodes set
        C_neighbor_node = neighbors(G_sensor_connection,storage_nodes(i));
        if (edgecount(G_effort,storage_nodes(i),C_neighbor_node)~=0)
            int_storage_nodes=[int_storage_nodes;storage_nodes(i)];
        end
        %For bond graph with preferred derivative causality, If nodes are
        %of C type then check if there exists an edge ponting toward
        %the element. If the edge points away from the element do not add it to
        %the diff_storage_nodes set
        if (edgecount(G_inverted_causal,C_neighbor_node,storage_nodes(i))~=0)
            diff_storage_nodes=[diff_storage_nodes;storage_nodes(i)];
        end
    elseif ismember(storage_nodes(i),I_nodes)
        %For bond graph with preferred integral causality, if nodes are of I type then check if there exists an edge ponting
        %toward the element. If the edge points away from the element do not add it to
        %the int_storage_nodes set
        I_neighbor_node = neighbors(G_sensor_connection,storage_nodes(i)); %Single port I implies there is only one neighbor node
        if (edgecount(G_effort,I_neighbor_node,storage_nodes(i))~=0)
            int_storage_nodes=[int_storage_nodes;storage_nodes(i)];
        end
        %For bond graph with preferred derivative causality, if nodes are
        %of I type then check if there exists an edge ponting away from
        %the element. If the edge points toward the element do not add it to
        %the diff_storage_nodes set
        if (edgecount(G_inverted_causal,storage_nodes(i),I_neighbor_node)~=0)
            diff_storage_nodes=[diff_storage_nodes;storage_nodes(i)];
        end
    end
end

%If the int_storage_nodes set and the diff_storage_nodes set are identical
%and causal paths from sensors to storage elements in integral causality
%exist, then the system is structurally observable

%Check if int_storage_nodes is subset of intersection(int_storage_nodes,
%visited_terminal_storage_nodes)
necessity_flag = all(ismember(int_storage_nodes,intersect(int_storage_nodes,visited_terminal_storage_nodes)));
sufficiency_flag = isempty(setdiff(int_storage_nodes,diff_storage_nodes));
if (sufficiency_flag)&&(necessity_flag)
    %disp('System is SO!')
    isStructObsv_flag=1;
else
    %disp('System is not SO!')
    isStructObsv_flag=0;
end
end