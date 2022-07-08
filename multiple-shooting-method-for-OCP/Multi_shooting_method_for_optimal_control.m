%--------------------------------------------------------------------------
% This code demonstrates an example of solving constrained optimization problem 
% with multiple shooting method.
% Author: Vinh Quang Nguyen - University of Massachusetts, Amherst
%--------------------------------------------------------------------------
% ˵����Ӧ�ö��ش�з������Լ�����ſ�������
% ���ӣ������Ż������ſ��ơ� pp. 257 ��13.1 
% ���ͣ��޿���Լ�������ſ�������
% ʱ�䣺2022/07/05
%--------------------------------------------------------------------------
clear;clc;close all;

%% 01 ��ʼ��������
p.ns = 1; p.nu = 1;                     % ״̬�������Ϳ���������
p.t0 = 0; p.tf = 1;                     % ��ʼʱ�����ֹʱ��
p.x0 = 10;                              % ��ʼ����

% ���ش�з���������
p.N = 20;                               % ��е��� => (N-1) ����ʱ������
p.M = 4;                                % ÿ����ʱ�����ΰ����Ĵ�е�
p.t = linspace(p.t0,p.tf,p.N);          % ʱ������

% ����״̬���Ϳ�����������
p.x_index = 1:p.N;
p.u_index = p.N+1:2*p.N;
%% 02 ����㷨
% ���ó�ֵ
y0 = ones((p.ns + p.nu)* p.N, 1);
% �趨���������
options = optimoptions('fmincon','Display','Iter','Algorithm','sqp','MaxFunEvals',1e5); 
% mc = 10;
% time_record = zeros(mc,1);
% 
% for index = 1:mc
tic;
[X,fval,exitflag,output] = fmincon(@(y) objfun(y, p),y0,[],[],[],[],[],[],@(y) noncon(y, p),options);
toc;
% time_record(index) = toc; 
% end
% time_cal = sum(time_record)/mc;

%% 03 ��������
p.x = reshape(X(p.x_index), [], p.ns);
p.u = reshape(X(p.u_index), [], p.nu);
% �����������һ��ʱ����ֵ
% p.u(p.N) = (p.t(p.N)-p.t(p.N-1)) * (p.u(p.N-1)-p.u(p.N-2)) / (p.t(p.N-1)-p.t(p.N-2)) + p.u(p.N-1);
% ����ƽ����һ��ʱ����ֵ
u0 = p.u(1+1) + (p.u(1+1)-p.u(2+1))*(p.t(0+1)-p.t(1+1))/(p.t(1+1)-p.t(2+1));
p.u(1) = u0;
%% 04 ��ͼ
window_width = 500;
window_height = 416;

% ״̬���Ϳ�����
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
% save(['.\','multi_shooting_method.mat']);
%% �Ӻ���  
% Ŀ�꺯��
function f = objfun(y,p)
    % �õ�״̬���Ϳ�����
    x = y(p.x_index);
    u = y(p.u_index);
    % Ϊ�˱�֤ x �� u ��ά��һ�£���Ҫ�� u �������ƣ��õ� u ��ĩ��ʱ�̵�ֵ
    % ���ü򵥵��������Ʒ�����������
    % k = (x2-x1)/(t2-t1) == (x3-x2)/(t3-t2)
    % x3 = (t3-t2)(x2-x1)/(t2-t1) + x2
%     N = p.N;
%     t = p.t;
%     u(N) = (t(N)-t(N-1)) * (u(N-1)-u(N-2)) / (t(N-1)-t(N-2)) + u(N-1);
    L = u.^2/2 + x.^2/2;            % ������
    f = trapz(p.t,L);               % ����Ŀ�꺯��
end

% ״̬����
function dy = state_eq(y,u)
    dy = -y^2 + u;
end

% Լ������
function [c,ceq] = noncon(y,p)
    % �õ�״̬���Ϳ�����
    x = reshape(y(p.x_index),[],p.ns);
    u = reshape(y(p.u_index),[],p.nu);
    
    % ʱ�䲽��
    h = p.tf/(p.N-1)/(p.M-1);
    
    % ÿ����ʱ�����ν��е��δ�з�
    states_at_nodes = zeros(p.N, p.ns);
    for i = 1:p.N-1
       x0 = x(i,:);
       u0 = u(i,:);
       states = zeros(p.M,p.ns);
       states(1,:) = x0;
       for j =1:p.M-1
           k1 = state_eq(states(j,:), u0);
           k2 = state_eq(states(j,:) + h/2 * k1, u0);
           k3 = state_eq(states(j,:) + h/2 * k2, u0);
           k4 = state_eq(states(j,:) + h * k3, u0);
           states(j+1,:) = states(j,:) + h/6*(k1 + 2*k2 + 2*k3 + k4);
       end
       states_at_nodes(i+1,:) = states(end,:);
    end
    
    % ��֤��������ʼ���������
    ceq_temp = x(2:end,:) - states_at_nodes(2:end,:);
    
    % �ѳ�ʼʱ�̵�״̬Լ���ŵ� ceq ��
    ceq_temp = [ceq_temp; x(1,:) - p.x0];
    ceq = reshape(ceq_temp, [], 1);
    
    % ����ʽԼ��
    c = [];
end