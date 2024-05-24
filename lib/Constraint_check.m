function G_causal = Constraint_check(G_connection,G_causal)
SE = 1;
SF = 2;
C = 3;
I = 4;
R = 5;
ONE = 6;
ZERO = 7;
TF = 8;
GY = 9;
change_flag = 1;

while change_flag
    %Call function ONE_constraint to check if causal constraints at one junctions
    %are satisfied
    G_causal_temp = ONE_constraint(G_connection,G_causal);
    %If the causal bond graph has been modified, raise the ONE_change_flag
    ONE_change_flag=~isequal(G_causal_temp,G_causal);
    G_causal = G_causal_temp;
    
    %Call function ZERO_constraint to check if causal constraints at zero junctions
    %are satisfied
    G_causal_temp = ZERO_constraint(G_connection,G_causal);
    %If the causal bond graph has been modified, raise the ZERO_change_flag
    ZERO_change_flag=~isequal(G_causal_temp,G_causal);
    G_causal = G_causal_temp;
    
    %Call function TF_constraint to check if causal constraints at
    %transformers are satisfied
    G_causal_temp = TF_constraint(G_connection,G_causal);
    %If the causal bond graph has been modified, raise the TF_change_flag
    TF_change_flag=~isequal(G_causal_temp,G_causal);
    G_causal = G_causal_temp;
    
    %Call function GY_constraint to check if causal constraints at
    %gyrators are satisfied
    G_causal_temp = GY_constraint(G_connection,G_causal);
    %If the causal bond graph has been modified, raise the GY_change_flag
    GY_change_flag=~isequal(G_causal_temp,G_causal);
    G_causal = G_causal_temp;
    
    %If any of the flags have been raised, re-check constraints
    change_flag = ONE_change_flag || ZERO_change_flag || TF_change_flag || GY_change_flag;
end

end