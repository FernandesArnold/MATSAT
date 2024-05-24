function [Xdata, Ydata]=node_position(G_graph,varargin)
%Work in progress
pos_scale = 1;
start_node = 1;

%Additional arguments that can be passed on
var_arguments=varargin
l_varargin = length(varargin)
for ii = 1:2:l_varargin
    if strcmp('startNode',var_arguments{ii})
        start_node = var_arguments{ii+1};
    elseif strcmp('posScale',var_arguments{ii})
        pos_scale =  var_arguments{ii+1};
    elseif strcmp('textXshift',var_arguments{ii})
        text_Xshift = var_arguments{ii+1};
    elseif strcmp('textYshift',var_arguments{ii})
        text_Yshift = var_arguments{ii+1};
    elseif strcmp('XData',var_arguments{ii})
        Xdata_in = var_arguments{ii+1};
        position_flag = 1;
    elseif strcmp('YData',var_arguments{ii})
        Ydata_in = var_arguments{ii+1};
        position_flag = 1;
    elseif strcmp('CamRotation',var_arguments{ii})
        cam_rotation = var_arguments{ii+1};
    end
end

up = pos_scale*[0 1];
down = -up;
right = pos_scale*[1 0];
left = -left;

%Convert digraphs to graphs
if isa(G_graph,'digraph')
    A_graph = adjacency(G_graph)+adjacency(G_graph)';
    G_graph = graph(A_graph,G_graph.Nodes);
end

%If graphs then start allocating positions else throw an error
if isa(G_graph,'graph')
%Place DFS algorithm that finds
G_DFS = dfsearch(G_graph,start_node)

else
    error('Unknown graph type')
end

end