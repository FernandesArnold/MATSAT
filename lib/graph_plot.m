function [f_handle,varargout]= graph_plot(G_graph,varargin)
%varargin -> 'Layout',graph_layout,'textRotation',text_rotation,'textXshift',text_Xshift,'textYshift', text_Yshift,'XData', Xdata_in,'YData', Ydata_in
%varargout-> Xdata_out, Ydata_out
%Create an inputParser object to allow parsing function input, validate
%arguments, and provide for name-value pair arguments

%Find if we need to plot a graph or a digraph
%The function isa(A,dataType) is used
graph_arguments = varargin;
if isa(G_graph,'graph')
    [f_handle, Xdata_out, Ydata_out]= conn_graph_plot(G_graph,graph_arguments{:});
elseif isa(G_graph,'digraph')
    [f_handle, Xdata_out, Ydata_out]= causal_graph_plot(G_graph,graph_arguments{:});
else
    error('Unknown graph type')
end

varargout{1} = Xdata_out;
varargout{2} = Ydata_out;

end