%% OCA-I for the hoist model 
clc; clear; close all;

% f = [0;-1;0;0;0;-1;0;0;0;1;0;0;-1];
% intcon = 13;
% Aeq=zeros(8,13);
% Aeq(1,1:4)=1;
% Aeq(2,5:8)=1;
% Aeq(3,11:13)=1;
% Aeq(4,9:10)=-1;Aeq(4,12)=1;
% Aeq(5,4)=1;Aeq(5,5)=-1;
% Aeq(6,8:9)=1;
% Aeq(7,1)=1;
% Aeq(8,11)=1;
% 
% beq=[1;1;1;-1;0;1;0;0];
% lb=zeros(13,1);
% ub=ones(13,1);
% 
% x=intlinprog(f,intcon,[],[],Aeq,beq,lb,ub)
%% OCA-I for the delta sub-network
% % f = [0;0;0;-1;0;-1;0;0;0;0;0;0];
% % intcon = 12;
% % Aeq=zeros(8,intcon);
% % Aeq(1,1)=-1; Aeq(1,[7,8])=1;
% % Aeq(2,[3,7])=1;Aeq(2,9)=-1;
% % Aeq(3,[4,9])=-1;Aeq(3,10)=1;
% % Aeq(4,[5,10,11])=1;
% % Aeq(5,6)=-1;Aeq(5,[11,12])=1;
% % Aeq(6,[2,8,12])=1;
% % Aeq(7,1)=1;
% % Aeq(8,[1,4,6])=-1;
% % beq=[0;0;-1;1;0;1;1;-2];
% % lb=zeros(intcon,1);
% % ub=ones(intcon,1);
% % 
% % x=intlinprog(f,intcon,[],[],Aeq,beq,lb,ub)