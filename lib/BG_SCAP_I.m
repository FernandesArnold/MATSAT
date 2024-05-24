function G_causal = BG_SCAP_I(G)
G_causal = digraph; %Create a causal digraph with only node information and no edge information
G_causal = addnode(G_causal,G.Nodes);
%% Causality assignment
%Fixed Se causality
G_causal = SE_SCAP_I(G,G_causal);

%Fixed Sf causality
G_causal = SF_SCAP_I(G,G_causal);

%Commented out as we are interested in sensor placement
% %Fixed DE causality
% G_causal = DE_causal_assign(G,G_causal);
% 
% %Fixed DF causality
% G_causal = DF_causal_assign(G,G_causal);

%Preferred C causality
G_causal = C_SCAP_I(G,G_causal);

%Preferred I causality
G_causal = I_SCAP_I(G,G_causal);

%Indifferent R causality
G_causal = R_SCAP_I(G,G_causal);
end