function [f_handle, varargout]= conn_graph_plot(G_connection,varargin)
%varargin -> 'Layout',graph_layout,'textRotation',text_rotation,'textXshift',text_Xshift,'textYshift', text_Yshift,'XData', Xdata_in,'YData', Ydata_in
%varargout-> Xdata_out, Ydata_out
global BrBG
layout_flag = 0;
position_flag = 0;
text_rotation = 0;
text_Xshift = 0;
text_Yshift = 0;
cam_rotation = 0;
var_arguments=varargin;
l_varargin = length(varargin);
for ii = 1:2:l_varargin
    if strcmp('Layout',var_arguments{ii})
        graph_layout = var_arguments{ii+1};
        layout_flag = 1;
    elseif strcmp('textRotation',var_arguments{ii})
        text_rotation =  var_arguments{ii+1};
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

f_handle=figure;

if position_flag == 1
    layout_flag = 0;
end

if layout_flag == 1
    %plotData = plot(G_connection,'NodeLabel',G_connection.Nodes.element_name,'LineWidth', 2,'Layout',graph_layout,'Direction','Right','Source',11,'NodeColor',BrBG(1,:),'EdgeColor',BrBG(9,:));%For plotting three tank results
    plotData = plot(G_connection,'NodeLabel',G_connection.Nodes.element_name,'LineWidth',2,'Layout',graph_layout,'NodeColor',BrBG(1,:),'EdgeColor',BrBG(9,:));
   %%Generic plotter
elseif layout_flag == 0
    plotData = plot(G_connection,'NodeLabel',G_connection.Nodes.element_name,'LineWidth', 2,'XData',Xdata_in,'YData',Ydata_in,'NodeColor',BrBG(1,:),'EdgeColor',BrBG(9,:));
end
Xdata_out = plotData.XData;
Ydata_out = plotData.YData;
NodeLabelData = plotData.NodeLabel;
plotData.NodeLabel = {};
text_label = text(Xdata_out+text_Xshift, Ydata_out+text_Yshift ,strcat(num2str(G_connection.Nodes.id),{', '},NodeLabelData'), ...
    'VerticalAlignment','Bottom',...
    'HorizontalAlignment', 'left',...
    'FontSize', 8,'FontWeight','Bold');
set(text_label,'Rotation',text_rotation)
axis off;
set(gca,'XColor', 'none','YColor','none')
camroll(cam_rotation)
%camzoom(2)

varargout{1} = Xdata_out;
varargout{2} = Ydata_out;
end