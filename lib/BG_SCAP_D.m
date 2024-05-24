function G_causal = BG_SCAP_D(G)
G_causal = digraph; %Create a causal digraph with only node information and no edge information
G_causal = addnode(G_causal,G.Nodes);
%% Causality assignment
%Fixed Se causality
G_causal = SE_SCAP_I(G,G_causal);

%Fixed Sf causality
G_causal = SF_SCAP_I(G,G_causal);

%Preferred C causality
G_causal = C_SCAP_D(G,G_causal);

%Preferred I causality (similar to fixed causality)
G_causal = I_SCAP_D(G,G_causal);

%Indifferent DE causality
G_causal = DE_SCAP_D(G,G_causal);

%Indifferent DF causality
G_causal = DF_SCAP_D(G,G_causal);

%Indifferent R causality
G_causal = R_SCAP_D(G,G_causal);


end