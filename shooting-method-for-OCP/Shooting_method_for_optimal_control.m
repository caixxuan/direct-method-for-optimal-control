%--------------------------------------------------------------------------
% Method_SingleShooting.m
% Attempt to solve the Bryson-Denham problem using a single shooting method
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
% Primary Contributor: Daniel R. Herber, Graduate Student, University of 
% Illinois at Urbana-Champaign
% https://github.com/danielrherber/optimal-control-direct-method-examples
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% ˵����Ӧ��ֱ�Ӵ�з������Լ�����ſ�������
% ���ӣ������Ż������ſ��ơ� pp. 257 ��13.1 
% ���ͣ��޿���Լ�������ſ�������
% ʱ�䣺2022/07/01
%--------------------------------------------------------------------------
clear;clc;close all;

%% 01 ��ʼ��������
p.ns = 1; p.nu = 1;                     % ״̬�������Ϳ���������
p.t0 = 0; p.tf = 1;                     % ��ʼʱ�����ֹʱ��
p.x0 = 10;                              % ��ʼ����

% ֱ�Ӵ�з���������
p.nt = 20;                              % ��е��������
p.t = linspace(p.t0,p.tf,p.nt)';        % ʱ������

% ����������ɢ
p.u_index = 1:p.nt;

%% 02 ����㷨
% ������������ֵ
p.u = -0.5*ones(p.nt,1);
u0 = p.u;                               % �������ĳ�ֵ�²�
% mc = 10;                                % �ظ��������
% time_record = zeros(mc,1);

% for index = 1:mc
% ��������
options = optimoptions(@fmincon,'display','iter','MaxFunEvals',1e5,'algorithm','sqp');
tic;
[u,fval,exitflag,output] = fmincon(@(u) objective(u,p),u0,[],[],[],[],[],[],[],options);
toc;
p.u = u;
time_record = toc;
% time_record(index) = toc;
% end
% time_cal = sum(time_record)/mc;

% �ٽ���һ�η���õ�����
[~,Y] = ode45(@(t,y) derivative(t,y,p),p.t,p.x0);
p.x = Y(:,1);

%% ��ͼ
k = 0;
window_width = 500;
window_height = 416;

% ״̬��
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
% save(['..\','shooting_method.mat']);

%% �Ӻ�������
% Ŀ�꺯��
function f = objective(u_obj,p)
    p.u = u_obj(p.u_index);
    [~,Y] = ode45(@(t,y) derivative(t,y,p),p.t,p.x0); % ����õ�ʱ��״̬��
    x = Y;                          % ״̬��
    u = u_obj(p.u_index);           % ������
    L = u.^2/2 + x.^2/2;            % ������
    f = trapz(p.t,L);               % ����Ŀ�꺯��
end

% ״̬����
function dy = derivative(t,y,p)
    % ʹ�� interp1qr() ���в�ֵ
    u = interp1qr(p.t,p.u,t);
    % ʹ�� interp1q() �������в�ֵ
    % ���� interp1q() ���ٶȱ� interp1() �죬��nterp1qr() �ٶ�һ��
%     u = interp1q(p.t,p.u,t);
    % ʹ�� interp1() �������в�ֵ
%     u = interp1(p.t,p.u,t);    
    dy = -y^2 + u;
end
