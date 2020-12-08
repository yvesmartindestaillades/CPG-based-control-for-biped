clc;
clear;
close all;

% optimize
% optimize the initial conditions and controller hyper parameters
q0 = [pi/9; -pi/9; 0];
dq0 = [0; 0; 8]; 
n0 = [30; -11.5; 0];
parameters = control_hyper_parameters();
fun_g = g('full','suite');
save('fun_g','fun_g');

x0 = [q0; dq0; n0; parameters];

load('param_opt');

%% THIS PART IS TO DO LOCAL OPTIMIZATION, UNAVAILABLE AT THE MOMENT
% use fminsearch and optimset to control the MaxIter
options = optimset('TolX',0.2,'MaxIter',30,'display','iter');
%optimize only omega, gamma, K
param_opt(15:17) = fminsearch(@custom_optimization_fun,x0(15:17),options)
save('param_opt','param_opt');

%% THIS PART IS TO DO GLOABL OPTIMIZATION, AVAILABLE
problem = createOptimProblem('fmincon',...
    'objective',@(x)custom_optimization_fun(x),...
    'x0',parameters,'options',...
    optimoptions(@fmincon,'Algorithm','sqp','Display','off'));
param_opt(10:17) = fmincon(problem);
gs = GlobalSearch('Display','iter');
rng(14,'twister') % for reproducibility
[x,fval] = run(gs,problem)
save('param_opt','param_opt');

%% DISPLAY RESULTS
disp("q");
param_opt(1:3)
disp("dq");
param_opt(4:6)
disp("x");
param_opt(7:8)
disp("teta_0");
param_opt(9)
disp("kp");
param_opt(10:11)
disp("kd");
param_opt(12:13)
disp("alpha");
param_opt(14);
disp("omega");
param_opt(15)
disp("gamma");
param_opt(16)
disp("K");
param_opt(17)

%% simulate solution
clc
close all;
param_opt(10:end) = control_hyper_parameters;
% extract parameters
q0 = param_opt(1:3);
dq0 = param_opt(4:6);
n0 = param_opt(7:9);
x_opt = param_opt(10:end);

% simulate
num_steps = 10;
sln = solve_eqns(q0, dq0, n0, num_steps, x_opt, fun_g);
animate(sln);
results = analyse(sln, x_opt,0,1);