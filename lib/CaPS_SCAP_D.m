function [component_nodes, residual_nodes, FSM]=CaPS_SCAP_D(G_effort)
%Causal Path Search code built from isStructObsv.m code


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
MSE = 13;
MSF = 14;
DES = 20;
DFS = 21;

DES_nodes = find(G_effort.Nodes.priority_id==DES);
DFS_nodes = find(G_effort.Nodes.priority_id==DFS);
residual_nodes = [DES_nodes;DFS_nodes];%Sensor nodes

%Find component nodes that are neither one or zero junctions
NOT_ZERO_nodes = find(G_effort.Nodes.priority_id~=ZERO);
NOT_ONE_nodes = find(G_effort.Nodes.priority_id~=ONE);
NOT_DES_nodes = find(G_effort.Nodes.priority_id~=DES);
NOT_DFS_nodes = find(G_effort.Nodes.priority_id~=DFS);
component_nodes = intersect(NOT_ZERO_nodes,NOT_ONE_nodes);
component_nodes = intersect(component_nodes,NOT_DES_nodes);
component_nodes = intersect(component_nodes,NOT_DFS_nodes);


FSM = false(length(component_nodes),length(residual_nodes));

%Obtain a flow causal graph after flipping the edges


G_flow =  flipedge(G_effort);

%Identify source and sensor node indices. No U-turns at these nodes if they
%are terminal nodes
SE_nodes = find(G_effort.Nodes.priority_id==SE);%Effort source nodes
SF_nodes = find(G_effort.Nodes.priority_id==SF);%Flow source nodes
MSE_nodes = find(G_effort.Nodes.priority_id==MSE);%Effort source nodes
MSF_nodes = find(G_effort.Nodes.priority_id==MSF);%Flow source nodes
source_nodes = [SE_nodes;MSE_nodes;SF_nodes;MSF_nodes];%Source nodes
sensor_source_nodes = [residual_nodes;source_nodes];%Sensor and source nodes

%%Begin a causal serach from the residual sensors
for i=1:length(residual_nodes)
    %If residual node is DFS then start search on effort causal graph else
    %start search on flow causal graph
    if ismember(residual_nodes(i),DFS_nodes)
        G1 = G_effort;
        G2 = G_flow;
    elseif ismember(residual_nodes(i),DES_nodes)
        G1 = G_flow;
        G2= G_effort;
    end
    
        T_start_node = residual_nodes(i);%Initialize start nodes as flow nodes
        T_visited_nodes = T_start_node;%Terminal nodes visited
        T_terminal_nodes = [];%Initialize terminal nodes
        T_visited_terminal_nodes = T_terminal_nodes;%Initialize terminal nodes visited
        T_discover_nodes = [];%Initialize nodes discovered
        T_visited_discover_nodes = T_discover_nodes;%Initialize visited discover nodes
        
        %Initialize the start nodes for the flow causal graph
        U_terminal_nodes = [];
        U_visited_terminal_nodes = U_terminal_nodes;
        U_discover_nodes = [];
        U_visited_discover_nodes = U_discover_nodes;
        U_visited_nodes = [];
        k=1;%Index used to prevent infinite while loop.
    while k<3
        for j=1:length(T_start_node)
            %Perform the depth-first search and generate a table of all events
            %'T'. Events include 'discovernode', 'finishnode', 'edgetonew',
            %etc.
            T = dfsearch(G1, T_start_node(j), 'allevents');
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
        T_visited_nodes = unique([T_visited_nodes;T_start_node;T_visited_discover_nodes;T_visited_terminal_nodes]);
        % A discovernode event following with a finishnode event is a terminal storage element or could
        % be a GY. Ignore finishnodes that are sources?

        %Remove terminating source/sensor nodes before performing a causal path
        %search on the complementary graph.

        U_start_nodes = setdiff(T_terminal_nodes,sensor_source_nodes);
        U_visited_nodes = [];
        for j=1:length(U_start_nodes)
            %Perform the depth-first search and generate a table of all events
            %'U'. Events include 'discovernode', 'finishnode', 'edgetonew',
            %etc.
            U = dfsearch(G2, U_start_nodes(j), 'allevents');
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
        U_visited_nodes = unique([U_visited_nodes;U_start_nodes;U_visited_discover_nodes;U_visited_terminal_nodes]);

        T_start_node = setdiff(U_terminal_nodes,sensor_source_nodes);
        k=k+1;
    end
    visited_terminal_nodes = reshape(union(T_visited_terminal_nodes,U_visited_terminal_nodes),[],1);
    visited_nodes = reshape(union(T_visited_nodes,U_visited_nodes),[],1);
    FSM(:,i) = ismember(component_nodes,visited_nodes);%If component node number is found in visited nodes then the residual is sensitive to that component 
end


end