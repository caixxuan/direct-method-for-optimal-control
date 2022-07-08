%--------------------------------------------------------------------------
% Method_Pseudospectral.m
% Attempt to solve the Bryson-Denham problem using a pseudospectral method
% (namely LGL nodes and Gaussian quadrature) 
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
% Primary Contributor: Daniel R. Herber, Graduate Student, University of 
% Illinois at Urbana-Champaign
% https://github.com/danielrherber/optimal-control-direct-method-examples
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% ˵����Ӧ��α�׷������Լ�����ſ�������
% ���ӣ������Ż������ſ��ơ� pp. 257 ��13.1 
% ���ͣ��޿���Լ�������ſ�������
% ʱ�䣺2022/07/07
%--------------------------------------------------------------------------
clear;clc;close all;

%% 01 ��ʼ��������
p.ns = 1; p.nu = 1;                     % ״̬�������Ϳ���������
p.t0 = 0; p.tf = 1;                     % ��ʼʱ�����ֹʱ��
p.x0 = 10;                              % ��ʼ����

p.nt = 50;                              % ���õ����
% p.method = 'LGL';                       % ѡ����㷽ʽ��Legendre-Gauss-Lobatto(LGL)
p.method = 'CGL';                       % ���� Chebyshev-Gauss-Lobatto(CGL)
% p.method = 'LGR';                       % ���� Legendre-Gauss-Radau(LGR)
if strcmp(p.method,'LGL')
    p.tau = LGL_nodes(p.nt-1);          % ��ʱ��������ɢ��[-1,1]��
    p.D   = LGL_Dmatrix(p.tau);         % ΢�־���
    p.w   = LGL_weights(p.tau);         % ���õ�Ȩ��
elseif strcmp(p.method,'CGL')    
    p.tau = CGL_nodes(p.nt-1);          % ��ʱ��������ɢ��[-1,1]��
    p.D   = CGL_Dmatrix(p.tau);         % ΢�־���
    p.w   = CGL_weights(p.tau);         % ���õ�Ȩ��
elseif strcmp(p.method,'LGR')
    [p.tau,p.w] = LGR_nodes_and_weights(p.nt-1);
    p.D   = LGR_Dmatrix(p.tau);         % ΢�־���
end

% ��������ɢΪ x = [x,u]
p.x_index = 1:p.nt;
p.u_index = p.nt+1:2*p.nt;

%% 02 ����㷨
% ��[x;u]����ֵ
y0 = zeros(p.nt*(p.ns+p.nu),1);
% ���������
options = optimoptions(@fmincon,'display','iter','MaxFunEvals',1e5,'algorithm','sqp');

mc = 10;
time_record = zeros(mc,1);

for index = 1:mc
tic;
[y,fval] = fmincon(@(y) objective(y,p),y0,[],[],[],[],[],[],@(y) constraints(y,p),options);
% toc;
time_record(index) = toc; 
end
time_cal = sum(time_record)/mc;

% �õ������
p.x = y(p.x_index);                     % ״̬��
p.u = y(p.u_index);                     % ������
p.t = tau2t(p);                         % ��ʱ������� tau ת��Ϊ t 

%% 03 ��ͼ    
window_width = 500;
window_height = 416;

% ״̬��
k = 1;
figure('color',[1 1 1],'position',[300+k*window_width,300,window_width,window_height]);
plot(p.t, p.x, 'o-', 'LineWidth',1.5);hold on;
plot(p.t, p.u, 'x-', 'LineWidth',1.5);
xlabel('Time');
ylabel('State & control');
set(gca,'FontSize',15,...
        'FontName','Times New Roman',...
        'LineWidth',1.5);
legend('$x(t)$','$u(t)$',...
        'Location','Northeast',...
        'FontSize',10,...
        'interpreter','latex');

% ��������
% .\ ��һ���ļ���
% ..\ ��һ���ļ���
% save(['..\','pseudospectral_method.mat']);
%% 04 �Ӻ�������
% Ŀ�꺯��
function J = objective(y,p)
    % �õ�״̬���Ϳ�����
    x = y(p.x_index);
    u = y(p.u_index);
    
    L = u.^2 + x.^2;                    % ������
    J = (p.tf-p.t0)/2 * dot(p.w,L)/2;   % ����Ŀ�꺯��
end

% Լ������
function [c,ceq] = constraints(y,p)
    % �õ�״̬���Ϳ�����
    x = y(p.x_index);
    u = y(p.u_index);
    % ״̬����Լ��
    Y = x; F = (p.tf-p.t0)/2*(-x.^2+u);
    % ��ʼ״̬Լ��
    ceq1 = x(1) - p.x0;
    ceq2 = p.D*Y - F;
    % ���Լ������    
    ceq = [ceq1;ceq2(:)];
    c = [];
end

% �� tau ת��Ϊ t
function t = tau2t(p)
    % ���ա�����Եش����������滮���Ƶ�������2013 pp.79 ʽ(4.25)��д���´���
    t = (p.tf-p.t0)*p.tau/2+(p.tf-p.t0)/2;
end