%% 二阶倒立摆系统的最小阶观测器s-function建模
function [sys,x0,str,ts,simStateCompliance] = order2_min_observer_sfun(t,x,u,flag, x_0, th1_0, th2_0, dx_0, dth1_0, dth2_0)
switch flag,
    case 0,
        [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes(t,x,u, x_0, th1_0, th2_0, dx_0, dth1_0, dth2_0);
    case 1,
        sys=mdlDerivatives(t,x,u);
    case 2,
        sys=mdlUpdate(t,x,u);
    case 3,
        sys=mdlOutputs(t,x,u);
    case 4,
        sys=mdlGetTimeOfNextVarHit(t,x,u);
    case 9,
        sys=mdlTerminate(t,x,u);
    otherwise
        DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));
end
% 主函数结束


%% ---------------------------------------------
function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes(t,x,u,x_0, th1_0, th2_0, dx_0, dth1_0, dth2_0)
% 初始化
sizes = simsizes;% 生成sizes数据结构

sizes.NumContStates  = 3;% 连续状态数, 分别是dx, dth1, dth2
sizes.NumDiscStates  = 0;% 离散状态数,缺省为 0
sizes.NumOutputs     = 6;% 输出量个数,缺省为 0
sizes.NumInputs      = 4;% 输入量个数，缺省为 0
sizes.DirFeedthrough = 1;% 是否存在直接馈通。1：存在；0：不存在，缺省为 1 
sizes.NumSampleTimes = 1;   % at least one sample time is needed
sys = simsizes(sizes);       
x0  = [dx_0; dth1_0; dth2_0] - [6, -6, 0; 6, 6, 0; 0,0,18]*[x_0; th1_0; th2_0];  % 设置初始状态
str = [];% 保留变量置空
ts  = [0 0]; % 连续系统
simStateCompliance = 'UnknownSimState';
% end mdlInitializeSizes

%% ---------------------------------------------
function sys=mdlDerivatives(t, x, u)
%  计算导数例程子函数
A = [0  0  0  0   -4.4100    0.4900;
     0  0  0  0   77.1750  -33.0750;
     0  0  0  0  -99.2250   84.5250;
     1  0  0  0      0         0;
     0  1  0  0      0         0;
     0  0  1  0      0         0];
B = [0.4667; -1.5000; 0.5000; 0; 0; 0];
% 注意这里Ke_j对应的状态变量顺序换了，变成了[x,th1,th2,dx,dth1,dth2]
Ke_j = [6    -6     0;
        6     6     0;
        0     0    18];
A_hat = A(1:3, 1:3) - Ke_j*A(4:end, 1:3);
B_hat = A_hat*Ke_j + A(1:3, 4:end) - Ke_j*A(4:end, 4:end);
F_hat = B(1:3) - Ke_j*B(4:end);
sys = A_hat*x + B_hat*[u(2);u(3);u(4)] + F_hat*u(1) ;  % u1是输入，u2/3/4是可观的变量x,th1,th2

%% ---------------------------------------------
function sys=mdlUpdate(t,x,u)
%3. 状态更新例程子函数
sys = [];

%% ---------------------------------------------
function sys=mdlOutputs(t,x,u)
%4. 计算输出例程子函数
C_hat = [1 0 0; 0 1 0; 0 0 1; 0 0 0; 0 0 0; 0 0 0];
D_hat = [6 -6 0; 6 6 0; 0 0 18; 1 0 0; 0 1 0; 0 0 1];
sys = C_hat*x + D_hat*[u(2);u(3);u(4)];  % 这里输出又变回了原来的[dx,dth1,dth2,x,th1,th2]的顺序

%% ---------------------------------------------
function sys=mdlGetTimeOfNextVarHit(t,x,u)
 % 5. 计算下一个采样时间，仅在系统是变采样时间系统时调用
sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

%% ---------------------------------------------
function sys=mdlTerminate(t,x,u)
 % 6. 仿真结束时要调用的例程函数
sys = [];
