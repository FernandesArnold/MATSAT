function G_causal = BG_CA(G,varargin)
    var_arguments=varargin;
    l_varargin = length(varargin);
    for i_varargin = 1:2:l_varargin
        if strcmpi('Procedure',var_arguments{i_varargin}) && strcmpi('SCAP-I',var_arguments{i_varargin+1})
            G_causal = BG_SCAP_I(G);
        elseif strcmpi('Procedure',var_arguments{i_varargin}) && strcmpi('SCAP-D',var_arguments{i_varargin+1})
            G_causal = BG_SCAP_D(G);
        elseif strcmpi('Procedure',var_arguments{i_varargin}) && strcmpi('OCA-I',var_arguments{i_varargin+1})
            G_causal = BG_OCA(G,'Causality','Integral');
        elseif strcmpi('Procedure',var_arguments{i_varargin}) && strcmpi('OCA-D',var_arguments{i_varargin+1})
            G_causal = BG_OCA(G,'Causality','Derivative');
        else
            error('Incorrect arguments')
        end
    end
end