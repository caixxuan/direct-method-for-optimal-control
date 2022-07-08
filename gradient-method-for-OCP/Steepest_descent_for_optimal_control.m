%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ˵����Ӧ�������½���������ſ�������
% ���ӣ������Ż������ſ��ơ� pp. 257 ��13.1 
% ���ͣ��޿���Լ�������ſ�������
% ���ߣ������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;clc;close all;

%% ����������
eps = 1e-3;
options = odeset('RelTol', 1e-4, 'AbsTol',1e-4);
t0 = 0; tf = 1;
t_segment = 50;
Tu = linspace(t0, tf, t_segment);	% ��ʱ����ɢ��
u = -0.5*ones(1, t_segment);        % �������ĳ�ֵ�²�
initx = 10;                         % ״̬������ֵ
initp = 0.1;                          % Э̬������ֵ
max_iteration = 50;                 % ����������
H_Norm = zeros(max_iteration,1);
step = 0.55*ones(max_iteration,1);
J = zeros(max_iteration,1);
d = zeros(max_iteration,max_iteration);

%% �㷨��ʼ
tic;
% ��¼����ʱ��
% mc = 10;
% time_record = zeros(mc,1);
% 
% for index = 1:mc
for i = 1:max_iteration   
    disp('---------------------------');
    fprintf('%d iterarion times \n',i)
    % 1) �������״̬���̵õ� x(t) 
    [Tx, X] = ode45(@(t,x) stateEq(t,x,u,Tu), [t0 tf], initx, options);
    
    % 2) �������Э̬���̵õ� p(t)
    x = X;
    [Tp, P] = ode45(@(t,p) costateEq(t,p,x,Tx), [tf, t0], initp, options);
    p = P;
    
    % ��Ϊ��õ�Э̬��������ʱ�䷴�����У�Ϊ��֤ x �� p ��ͬһʱ��������
    % ��Ҫ������˳��
    p =interp1(Tp,p,Tx);
    
    % ���� dH/du����Ŀ�귺�����ݶ�deltaH
    dH = gradient(p,Tx,u,Tu);
    H_Norm(i,1) = dH'*dH;
    
    % ����Ŀ�꺯����ֵ
    J(i,1) = fun(tf,x,Tx,u,Tu);
    fprintf('The value of the objective function is %.4f \n',J(i,1))
    
    % ����ݶ� dH/du < epsilon�����˳�ѭ��
    if H_Norm(i,1) < eps
        % ��ʾ���һ�ε�Ŀ�꺯��ֵ
%         fprintf('The value of the objective function is %.4f \n',J(i,1))
        break;
    else
        % ���򣬸��¿�������������һ�ε���
        u_old = u;
        % ������²���
        % �ҷ��ֲ�����Ӱ�����ʹ��ʹ��armijo�����������������Խ��Ӱ�첻��beta = 0.55��
        % step = 0.1*ones(max_iteration,1) ʱ�����ݶȷ����� u �ĵ�������Ϊ 39 �Σ������ݶȷ�Ϊ 14 ��
        % step = 0.55*ones(max_iteration,1) ʱ�����ݶȷ����� u �ĵ�������Ϊ 5 �Σ������ݶȷ�Ϊ 6 ��
        % ��step = 0*ones(max_iteration,1) ʱ����armijo������������������
        % ���ݶȷ����� u �ĵ�������Ϊ 6 �Σ������ݶȷ�Ϊ 13 ��
        step(i,1) = armijo(u_old, -dH, tf, x, Tx, Tu);
        u = control_update_by_gradient(dH,Tx,u_old,Tu,step(i,1));
%         [u,d] = control_update_by_conjugate_gradient(H_Norm,dH,d,Tx,u_old,Tu,step(i,1),i);
    end
end

if i == max_iteration
    disp('---------------------------');
    disp('�Ѵ�������������ֹͣ�㷨.');
end
toc;
% time_record(index) = toc;
% end
% time_cal = sum(time_record)/mc;
%% ��ͼ
window_width = 500;
window_height = 416;
figure('color',[1 1 1],'position',[300,200,window_width,window_height]);
plot(Tx, X, 'x-','LineWidth',1.5);hold on;
plot(Tu, u, 'x-','LineWidth',1.5);
xlabel('Time');
ylabel('State & control');
set(gca,'FontSize',15,...
        'FontName','Times New Roman',...
        'LineWidth',1.5);
legend('$x(t)$','$u(t)$',...
        'Location','Northeast',...
        'FontSize',10,...
        'interpreter','latex');

count = find(J==0);
if isempty(count)
    t_plot = (1:length(J))';
    J_plot = J;
else
    if J(count(1)-1)-J(count(1)) > 1 
        t_plot = (1:count(1)-1)';
        J_plot = J(1:count-1);
    else
        t_plot = (1:length(J))';
        J_plot = J;
    end
end
figure('color',[1 1 1],'position',[300+window_width,200,window_width,window_height]);
plot(t_plot,J_plot,'x-','LineWidth',1.5);
xlabel('Iterations');
ylabel('J');
set(gca,'FontSize',15,...
        'FontName','Times New Roman',...
        'LineWidth',1.5);
legend('$J$',...
       'Location','Northeast',...
       'FontSize',10,...
       'interpreter','latex');

%% �Ӻ������岿��
% ״̬����
function dx = stateEq(t,x,u,Tu)
    u = interp1(Tu,u,t);
    dx = -x^2+u;
end

% Э̬����
function dp = costateEq(t,p,x,Tx)
    x = interp1(Tx,x,t);
    dp = -x + 2*p.*x;
end

% ���ݶȷ���� dH/du �ı��ʽ
function dH = gradient(p,Tx,u,Tu)
    u = interp1(Tu,u,Tx);
    dH = p + u;
end

% ���¿��������ݶȷ���
function u_new = control_update_by_gradient(dH,tx,u,tu,step)
    beta = 0.55;
    dH = interp1(tx,dH,tu);
    % ��armijo׼����������
%     u_new = u - beta^step*dH;
    % ����armijo׼����������
    u_new = u - step*dH;
end

% ���¿������������ݶȷ���
function [u_new,d] = control_update_by_conjugate_gradient(H_Norm,dH,d,tx,u,tu,step,i)
    beta = 0.55;
    dH = interp1(tx,dH,tu);
    if i == 1
        d(:,i) = -dH;
    else
        beta = H_Norm(i)/H_Norm(i-1);
        d(:,i) = -dH' + beta*d(:,i-1);
    end
    % ��armijo׼����������
    u_new = u + beta^step*d(:,i)';
    % ����armijo׼����������
%     u_new = u + step*d(:,i)';
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ˵����armijo׼��Ǿ�ȷ������������������������
% ���ף������Ż���������Matlab������ơ� pp. 26
% ���ߣ�Ԭ����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mk = armijo(xk, dk, tf, x, Tx, Tu)
dk = -interp1(Tx,dk,Tu);
beta = 0.55;
sigma = 0.5;
m = 0;
mmax = 20;
while m <= mmax
    if fun(tf,x,Tx,xk+beta^m*dk,Tu) <= fun(tf,x,Tx,xk+beta^m*dk,Tu)+sigma*beta^m*gfun(tf,xk,Tu)*dk'
        m = m+1;
        break;
    end
    m = m+1;
end
mk = m;
% ��� end ������ function 
end

function J = fun(tf,x,Tx,u,Tu)
    % 2022-07-01 �Ĵ���
    % д��з���ʱ�����ݶȷ���Ŀ�꺯���ķ�������
    % ��������Ŀ�꺯���ķ�ʽ������Ϊ����󷨲��ǶԵ�
    u = interp1(Tu,u,Tx);
    L = x.^2 / 2 + u.^2 /2;
    J = tf*trapz(Tx,L);
    % 2022-06-25 �Ĵ���
%     J = tf*(((x')*x)/length(Tx) + (u*u')/length(Tu));
end

function gJ = gfun(tf,u,Tu)
    gJ = tf*(2*u)/length(Tu);
end