function G_causal = BG_OCA(G,varargin)
%To do: Add a DBG option as well. Add sensors to objective function but
%increase cost on storage
%Default causality is integral causality
integral_causality=1;
var_arguments=varargin;
l_varargin = length(varargin);
for i_varargin = 1:2:l_varargin
    if strcmpi('Causality',var_arguments{i_varargin}) && strcmpi('Integral',var_arguments{i_varargin+1})
        integral_causality=1;
    elseif strcmpi('Causality',var_arguments{i_varargin}) && strcmpi('Derivative',var_arguments{i_varargin+1})
        integral_causality=-1;
    else
        error('Incorrect arguments')
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

FROM = 1;
TO = 2;

G_causal = digraph; %Create a causal digraph with only node information and no edge information
G_causal = addnode(G_causal,G.Nodes);

%Get the edges of the graph
G_edges = G.Edges.EndNodes;
Number_Edges = size(G_edges,1);
%% Creating the optimization problem
% Associate a binary variable with each edge. Causal stroke towards FROM node will result in the variable becoming 1 while causal stroke towards TO
%node will result in the variable being 0.
intcon = Number_Edges;
%Declare lower and upper bounds to make it a binary programming problem.
lb=zeros(intcon,1);
ub=ones(intcon,1);

%Initialize the linear objective function
f_min_objective=zeros(intcon,1);

%Check the FROM elements
FROM_elements_id = G_edges(:,FROM);
TO_elements_id = G_edges(:,TO);
FROM_priority_id = G.Nodes.priority_id(FROM_elements_id);
TO_priority_id = G.Nodes.priority_id(TO_elements_id);
%Searching for loops within the BG
super_node_constraint_count=0;
G_non_mesh_edges_indices_cell{1}=[];
G_non_mesh_edges_cell{1}=[];
non_mesh_edges_indices=[];
FROM_non_mesh_elements_id_cell{1}=[];
TO_non_mesh_elements_id_cell{1}=[];
%If a graph has cycles, save the cycles
if hascycles(G)
    [cycles_Node, cycles_Edge] = allcycles(G);
    %make the code generic later. Assume we have only one loop for now
    for cycles_index=1:length(cycles_Node)
        cycles_ordered_nodes=cell2mat(cycles_Node(cycles_index))
        cycles_ordered_priority_list=G.Nodes.priority_id(cycles_ordered_nodes);
        %Find if a cycle is a simple mesh, i.e. -1-0-1-0- loop
        %Create pattern of 0's and 1's based on the size of
        %cycles_ordered_priority_list
        for pattern_index=1:length(cycles_ordered_priority_list)
            if mod(pattern_index,2)==0%Even number
                pattern_A(pattern_index,1)=ONE;
                pattern_B(pattern_index,1)=ZERO;
            elseif mod(pattern_index,2)==1%Odd number
                pattern_A(pattern_index,1)=ZERO;
                pattern_B(pattern_index,1)=ONE;
            end
        end
        if all(cycles_ordered_priority_list==pattern_A) || all(cycles_ordered_priority_list==pattern_B)
            disp('It is a simple mesh')
            cycles_ordered_node_list=G.Nodes.id(cycles_ordered_nodes);
            %Find the zero node ids in the list
            Super_node_elements=cycles_ordered_node_list(cycles_ordered_priority_list==ZERO)
            %Find Edges that do not belong to the cycles_Edge list and retain the
            %indices. Do this for all cycles
            G_non_mesh_edges_indices=setdiff(1:Number_Edges, cell2mat(cycles_Edge(cycles_index)))
            non_mesh_edges_indices = unique([G_non_mesh_edges_indices non_mesh_edges_indices]);
            G_non_mesh_edges_indices_cell(cycles_index)={G_non_mesh_edges_indices}
            G_non_mesh_edges=G_edges(G_non_mesh_edges_indices,:)
            %To create SZERO, replace all Super node ZERO elements with the
            %smallest element id in G_non_mesh_edges.
            Super_node_small=min(Super_node_elements)
            for snode_index=1:length(G_non_mesh_edges)
                if ismember(G_non_mesh_edges(snode_index,1),Super_node_elements)
                    G_non_mesh_edges(snode_index,1)=Super_node_small;
                end
                if ismember(G_non_mesh_edges(snode_index,2),Super_node_elements)
                    G_non_mesh_edges(snode_index,2)=Super_node_small;
                end
            end
            %Save the edges in a cell
            G_non_mesh_edges_cell{cycles_index}={G_non_mesh_edges}
            super_node_constraint_count=super_node_constraint_count + 1;
            Super_nodes(cycles_index)=Super_node_small;
            %Generating FROM and TO elements_id and priority_id for querying
            %purposes
            FROM_non_mesh_elements_id_cell(cycles_index)={G_non_mesh_edges(:,FROM)}
            TO_non_mesh_elements_id_cell(cycles_index)={G_non_mesh_edges(:,TO)}
        end
    end
end

%% Change f_min_objective as follows
%If FROM elements are storage elements then change the f_min_objective for
%integral causality as follows.
%For I-type storage elements, f_max_objective(x_I) =1 =
%f_min_objective(comp(x_I)) OR f_min_objective(x_I) = -1
%Similarly, f_min_objective(x_C) = 1
for binary_index = 1:intcon
    if (FROM_priority_id(binary_index) == I || TO_priority_id(binary_index) == I)

        if FROM_priority_id(binary_index) == I
            f_min_objective(binary_index) = -1*integral_causality;
        elseif TO_priority_id(binary_index) == I
            f_min_objective(binary_index) = 1*integral_causality;
        end
    end
    if (FROM_priority_id(binary_index) == C || TO_priority_id(binary_index) == C)

        if FROM_priority_id(binary_index) == C
            f_min_objective(binary_index) = 1*integral_causality;
        elseif TO_priority_id(binary_index) == C
            f_min_objective(binary_index) = -1*integral_causality;
        end

    end
end

%% Add equality constraints as follows
%Add an equation for each junction, transducer, and source.
%Find the Nodes for junctions, transducers and sources.
ONE_nodes = find(G.Nodes.priority_id==ONE)
ZERO_nodes = find(G.Nodes.priority_id==ZERO)
GY_nodes = find(G.Nodes.priority_id==GY)
TF_nodes = find(G.Nodes.priority_id==TF)
SE_nodes = find(G.Nodes.priority_id==SE)
SF_nodes = find(G.Nodes.priority_id==SF)
MSE_nodes = find(G.Nodes.priority_id==MSE)
MSF_nodes = find(G.Nodes.priority_id==MSF)
Total_constraints = length([ONE_nodes;ZERO_nodes;GY_nodes;TF_nodes;SE_nodes;SF_nodes;MSE_nodes;MSF_nodes])+super_node_constraint_count;
Aeq = zeros(Total_constraints,intcon);
beq = zeros(Total_constraints,1);

%Ensure multiport nodes are not considered multiple times as they show up
%in multiple locations in FROM or To Edge lists.
TF_nodes_considered=[];
GY_nodes_considered=[];
ONE_nodes_considered=[];
ZERO_nodes_considered=[];
Super_nodes_considered=[];
%% Adding Constraints
%Create an index to update constraint number.
constraint_index = 1;
for binary_index=1:intcon
    %SE constraints
    if (FROM_priority_id(binary_index) == SE || TO_priority_id(binary_index) == SE)
        %Check if SE_node is in the FROM or TO list. If in FROM list then y_i=0
        %i.e. set Aeq(constraint_index,y_i)=1 and beq=0. If in TO list then
        %bar(y_i)=0 i.e.y_i=1 so set Aeq(constraint_index,y_i)=1 and beq=1.
        %Finally update constraint index.
        if FROM_priority_id(binary_index) == SE
            Aeq(constraint_index,binary_index)=1;
            beq(constraint_index)=0;
            constraint_index = constraint_index + 1;
        elseif TO_priority_id(binary_index) == SE
            Aeq(constraint_index,binary_index)=1;
            beq(constraint_index)=1;
            constraint_index = constraint_index + 1;
        end
    end
    %SF constraints
    if (FROM_priority_id(binary_index) == SF || TO_priority_id(binary_index) == SF)
        %Check if SF_node is in the FROM or TO list. If in FROM list then y_i=1
        %i.e. set Aeq(constraint_index,y_i)=1 and beq=1. If in TO list then
        %bar(y_i)=1 i.e.y_i=0 so set Aeq(constraint_index,y_i)=1 and beq=0.
        %Finally update constraint index.
        if FROM_priority_id(binary_index) == SF
            Aeq(constraint_index,binary_index)=1;
            beq(constraint_index)=1;
            constraint_index = constraint_index + 1;
        elseif TO_priority_id(binary_index) == SF
            Aeq(constraint_index,binary_index)=1;
            beq(constraint_index)=0;
            constraint_index = constraint_index + 1;
        end
    end
    %TF constraints. TF is connected to two nodes. One node could be in FROM edge list and another could
    %be in TO edge list. Ensure TF node has not been considered before
    %There are FOUR cases:
    %1) FROM FROM
    %2) FROM TO
    %3) TO FROM
    %4) TO TO
    %The third case can be ignored as it will be considered within the
    %second case.
    %Case 1) and 2) If one if the indices is in the FROM_elements_id
    %Check if TF node has not been considerd before
    if (FROM_priority_id(binary_index) == TF && not(ismember(FROM_elements_id(binary_index),TF_nodes_considered)))
        %Find all instances of the TF node in the FROM or TO edge list.
        %Store the indices in two separate variables.
        %If there are more than two instances throw an error.
        node_1_index = binary_index;
        TF_node=FROM_elements_id(binary_index);
        %Check other instance of TF_node in FROM_elements_id
        TF_node_instances=find(FROM_elements_id==TF_node);
        if length(TF_node_instances)>2
            error('TF multiport ill-defined')
        end
        %Case 1)
        if length(TF_node_instances)==2
            node_2_index=setdiff(TF_node_instances,node_1_index);
            %Since both variables are in FROM list, y_i+y_j=1
            Aeq(constraint_index,node_1_index)=1;
            Aeq(constraint_index,node_2_index)=1;
            beq(constraint_index)=1;
            constraint_index = constraint_index + 1;
            %Case 2)
        elseif length(TF_node_instances)==1
            %Check other instance of TF_node in TO_elements_id
            TF_node_instances=find(TO_elements_id==TF_node);
            if length(TF_node_instances)~=1
                error('TF multiport ill-defined')
            end
            %Since there is just one instance, it is the node_2_index
            node_2_index=TF_node_instances;
            %The constraint is y_i + bar(y_j) =1 OR y_i - y_j = 0
            Aeq(constraint_index,node_1_index)=1;
            Aeq(constraint_index,node_2_index)=-1;
            beq(constraint_index)=0;
            constraint_index = constraint_index + 1;
        end
        TF_nodes_considered = [FROM_elements_id(binary_index);TF_nodes_considered];
        %Ignore case 3) and only consider case 4)
    elseif (TO_priority_id(binary_index) == TF && not(ismember(TO_elements_id(binary_index),TF_nodes_considered)))
        node_1_index = binary_index;
        TF_node=TO_elements_id(binary_index);
        %Check other instance of TF_node in TO_elements_id
        TF_node_instances=find(TO_elements_id==TF_node);
        if length(TF_node_instances)>2
            error('TF multiport ill-defined')
        end
        %Case 4)
        if length(TF_node_instances)==2
            node_2_index=setdiff(TF_node_instances,node_1_index);
            %Since both variables are in TO list, bar(y_i)+bar(y_j)=1
            %OR y_i + y_j = 1
            Aeq(constraint_index,node_1_index)=1;
            Aeq(constraint_index,node_2_index)=1;
            beq(constraint_index)=1;
            constraint_index = constraint_index + 1;
        end
        TF_nodes_considered = [TO_elements_id(binary_index);TF_nodes_considered];
    end
    %GY constraints. GY is connected to two nodes. One node could be in FROM edge list and another could
    %be in TO edge list. Ensure GY node has not been considered before
    %There are FOUR cases:
    %1) FROM FROM
    %2) FROM TO
    %3) TO FROM
    %4) TO TO
    %The third case can be ignored as it will be considered within the
    %second case.
    %Case 1) and 2) If one if the indices is in the FROM_elements_id
    %Check if GY node has not been considerd before
    if (FROM_priority_id(binary_index) == GY && not(ismember(FROM_elements_id(binary_index),GY_nodes_considered)))
        %Find all instances of the GY node in the FROM or TO edge list.
        %Store the indices in two separate variables.
        %If there are more than two instances throw an error.
        node_1_index = binary_index;
        GY_node=FROM_elements_id(binary_index);
        %Check other instance of GY_node in FROM_elements_id
        GY_node_instances=find(FROM_elements_id==GY_node);
        if length(GY_node_instances)>2
            error('GY multiport ill-defined')
        end
        %Case 1)
        if length(GY_node_instances)==2
            node_2_index=setdiff(GY_node_instances,node_1_index);
            %Since both variables are in FROM list, y_i=y_j OR y_i-y_j=0
            Aeq(constraint_index,node_1_index)=1;
            Aeq(constraint_index,node_2_index)=-1;
            beq(constraint_index)=0;
            constraint_index = constraint_index + 1;
            %Case 2)
        elseif length(GY_node_instances)==1
            %Check other instance of GY_node in TO_elements_id
            GY_node_instances=find(TO_elements_id==GY_node);
            if length(GY_node_instances)~=1
                error('GY multiport ill-defined')
            end
            %Since there is just one instance, it is the node_2_index
            node_2_index=GY_node_instances;
            %The constraint is y_i = bar(y_j) =1 OR y_i + y_j = 1
            Aeq(constraint_index,node_1_index)=1;
            Aeq(constraint_index,node_2_index)=1;
            beq(constraint_index)=1;
            constraint_index = constraint_index + 1;
        end
        GY_nodes_considered = [FROM_elements_id(binary_index);GY_nodes_considered];
        %Ignore case 3) and only consider case 4)
    elseif (TO_priority_id(binary_index) == GY && not(ismember(TO_elements_id(binary_index),GY_nodes_considered)))
        node_1_index = binary_index;
        GY_node=TO_elements_id(binary_index);
        %Check other instance of GY_node in TO_elements_id
        GY_node_instances=find(TO_elements_id==GY_node);
        if length(GY_node_instances)>2
            error('GY multiport ill-defined')
        end
        %Case 4)
        if length(GY_node_instances)==2
            node_2_index=setdiff(GY_node_instances,node_1_index);
            %Since both variables are in TO list, bar(y_i)=bar(y_j)=1
            %OR y_i = y_j OR y_i - y_j = 0
            Aeq(constraint_index,node_1_index)=1;
            Aeq(constraint_index,node_2_index)=-1;
            beq(constraint_index)=0;
            constraint_index = constraint_index + 1;
        end
        GY_nodes_considered = [TO_elements_id(binary_index);GY_nodes_considered];
    end
    %ONE constraints. ONE is connected to multiple nodes. One node could be in FROM edge list or the
    %TO edge list in multiple instances. Ensure ONE node has not been considered before
    %Find the count of when ONE is in the FROM_elements_id list and when ONE is
    %in the TO_elements_id list
    if (FROM_priority_id(binary_index) == ONE && not(ismember(FROM_elements_id(binary_index),ONE_nodes_considered))) || (TO_priority_id(binary_index) == ONE && not(ismember(TO_elements_id(binary_index),ONE_nodes_considered)))
        %Find all instances of the ONE node in the FROM or TO edge list.
        %Store the indices in two separate vectors.
        if (FROM_priority_id(binary_index) == ONE && not(ismember(FROM_elements_id(binary_index),ONE_nodes_considered)))
            ONE_node=FROM_elements_id(binary_index);
            ONE_nodes_considered = [FROM_elements_id(binary_index);ONE_nodes_considered];
        elseif (TO_priority_id(binary_index) == ONE && not(ismember(TO_elements_id(binary_index),ONE_nodes_considered)))
            ONE_node=TO_elements_id(binary_index);
            ONE_nodes_considered = [TO_elements_id(binary_index);ONE_nodes_considered];
        end
        %Find instances of ONE_node in FROM_elements_id
        ONE_node_FROM_instances=find(FROM_elements_id==ONE_node);
        %Find instances of ONE_node in TO_elements_id
        ONE_node_TO_instances=find(TO_elements_id==ONE_node);
        %If all instances are in TO_elements_id then y_i+y_j+...=1
        %For every instance in FROM_elements_id, coefficient of y_i is -1
        %and 1 subtracted from beq(constraint_index).
        for ONE_FROM_index=1:length(ONE_node_FROM_instances)
            Aeq(constraint_index,ONE_node_FROM_instances(ONE_FROM_index))=-1;
        end
        for ONE_TO_index=1:length(ONE_node_TO_instances)
            Aeq(constraint_index,ONE_node_TO_instances(ONE_TO_index))=1;
        end
        beq(constraint_index)=1-length(ONE_node_FROM_instances);
        constraint_index = constraint_index + 1;
    end
    %ZERO constraints. ZERO is connected to multiple nodes. A ZERO node could be in FROM edge list or the
    %TO edge list in multiple instances. Ensure ZERO node has not been considered before
    %Find the count of when ZERO is in the FROM_elements_id list and when ZERO is
    %in the TO_elements_id list
    if (FROM_priority_id(binary_index) == ZERO && not(ismember(FROM_elements_id(binary_index),ZERO_nodes_considered))) || (TO_priority_id(binary_index) == ZERO && not(ismember(TO_elements_id(binary_index),ZERO_nodes_considered)))
        %Find all instances of the ZERO node in the FROM or TO edge list.
        %Store the indices in two separate vectors.
        if (FROM_priority_id(binary_index) == ZERO && not(ismember(FROM_elements_id(binary_index),ZERO_nodes_considered)))
            ZERO_node=FROM_elements_id(binary_index);
            ZERO_nodes_considered = [FROM_elements_id(binary_index);ZERO_nodes_considered];
        elseif (TO_priority_id(binary_index) == ZERO && not(ismember(TO_elements_id(binary_index),ZERO_nodes_considered)))
            ZERO_node=TO_elements_id(binary_index);
            ZERO_nodes_considered = [TO_elements_id(binary_index);ZERO_nodes_considered];
        end
        %Find instances of ZERO_node in FROM_elements_id
        ZERO_node_FROM_instances=find(FROM_elements_id==ZERO_node);
        %Find instances of ZERO_node in TO_elements_id
        ZERO_node_TO_instances=find(TO_elements_id==ZERO_node);
        %If all instances are in FROM_elements_id then y_i+y_j+...=1
        %For every instance in TO_elements_id, coefficient of y_i is -1
        %and 1 subtracted from beq(constraint_index).
        for ZERO_FROM_index=1:length(ZERO_node_FROM_instances)
            Aeq(constraint_index,ZERO_node_FROM_instances(ZERO_FROM_index))=1;
        end
        for ZERO_TO_index=1:length(ZERO_node_TO_instances)
            Aeq(constraint_index,ZERO_node_TO_instances(ZERO_TO_index))=-1;
        end
        beq(constraint_index)=1-length(ZERO_node_TO_instances);
        constraint_index = constraint_index + 1;
    end
    %Super node constraints. This constraint will be created if binary
    % index is a member of non mesh indices. Create a for loop and cycle
    % through various super nodes.
    % ZERO Super node is connected to multiple nodes.
    % A ZERO Super node could be in FROM non mesh edge list or the
    %TO non mesh edge list in multiple instances. Ensure ZERO Super node has not been considered before
    %Find the count of when ZERO Supr node is in the FROM_elements_id list and when ZERO is
    %in the TO_elements_id list. If binary_index is a member of non mesh
    %edge indices then create constraint.
    if (ismember(binary_index,non_mesh_edges_indices)) && ((ismember(FROM_elements_id(binary_index),Super_nodes)) || (ismember(TO_elements_id(binary_index),Super_nodes))&& not(ismember(TO_elements_id(binary_index),Super_nodes_considered)))
        %Find the G_non_mesh_edges_indices from non_mesh_edges_indices and
        %for each occurence add a constraint if it clears further checks.
        for cycle_index=1:length(G_non_mesh_edges_indices_cell)
            if ismember(binary_index,cell2mat(G_non_mesh_edges_indices_cell(cycle_index)))
                %Find all instances of the ZERO node in the FROM or TO edge list.
                %Store the indices in two separate vectors.
                if not(ismember(FROM_elements_id(binary_index),Super_nodes_considered))||not(ismember(TO_elements_id(binary_index),Super_nodes_considered))
                    if ismember(FROM_elements_id(binary_index),Super_nodes)&& not(ismember(FROM_elements_id(binary_index),Super_nodes_considered))
                        Super_node=FROM_elements_id(binary_index)
                        Super_nodes_considered = [FROM_elements_id(binary_index);Super_nodes_considered]
                    elseif ismember(TO_elements_id(binary_index),Super_nodes)&& not(ismember(TO_elements_id(binary_index),Super_nodes_considered))
                        Super_node=TO_elements_id(binary_index)
                        Super_nodes_considered = [TO_elements_id(binary_index);Super_nodes_considered]
                    end
                    %Load cell array data
                    %Find instances of Super_node in FROM_elements_id. Only store
                    %instances for non mesh edges
                    G_non_mesh_edges_indices=cell2mat(G_non_mesh_edges_indices_cell(cycle_index))
                    FROM_non_mesh_elements_id=cell2mat(FROM_non_mesh_elements_id_cell(cycles_index))
                    TO_non_mesh_elements_id=cell2mat(TO_non_mesh_elements_id_cell(cycles_index))
                    Super_node_FROM_instances=G_non_mesh_edges_indices(find(FROM_non_mesh_elements_id==Super_node))
                    %Find instances of Super_node in TO_elements_id
                    Super_node_TO_instances=G_non_mesh_edges_indices(find(TO_non_mesh_elements_id==Super_node))

                    %If all instances are in FROM_elements_id then y_i+y_j+...=1
                    %For every instance in TO_elements_id, coefficient of y_i is -1
                    %and 1 subtracted from beq(constraint_index).
                    for SZERO_FROM_index=1:length(Super_node_FROM_instances)
                        %Only consider instances in non mesh edges
                        if ismember(Super_node_FROM_instances(SZERO_FROM_index),G_non_mesh_edges_indices)
                            Aeq(constraint_index,Super_node_FROM_instances(SZERO_FROM_index))=1;
                        end
                    end
                    count_Super_node_TO_instances=0;
                    for SZERO_TO_index=1:length(Super_node_TO_instances)
                        if ismember(Super_node_TO_instances(SZERO_TO_index),G_non_mesh_edges_indices)
                            Aeq(constraint_index,Super_node_TO_instances(SZERO_TO_index))=-1;
                            count_Super_node_TO_instances=count_Super_node_TO_instances+1;
                        end
                    end
                    beq(constraint_index)=1-count_Super_node_TO_instances;
                    constraint_index = constraint_index + 1;
                end
            end
        end
    end
end
%Computing causality using an MILP algorithm
causality_y=intlinprog(f_min_objective,intcon,[],[],Aeq,beq,lb,ub);
%Populate G_causal.Edges.EndNodes. If causality_y(i)=0 then write G_edges
%to G_causal.Edges.EndNodes as is else if causality_y(i)=1 then flip the
%columns.
New_Edges=zeros(intcon,2);
for index_flip=1:intcon
    if causality_y(index_flip)==1
        New_Edges(index_flip,:)=flip(G_edges(index_flip,:));
    elseif causality_y(index_flip)==0
        New_Edges(index_flip,:)=G_edges(index_flip,:);
    end
end
G_causal=addedge(G_causal,table(New_Edges,'VariableNames',{'EndNodes'}));

end