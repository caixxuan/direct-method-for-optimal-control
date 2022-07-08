%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ˵�����Աȡ����Ż������ſ��ơ� pp.257 ��13.1 α�׷�������Ա�
% ʱ�䣺2022/07/06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;clc;close all;

%% ��������
res_RPM_20points = load('RPM_for_OPC_in_20points.mat');
res_RPM_30points = load('RPM_for_OPC_in_30points.mat');
res_RPM_40points = load('RPM_for_OPC_in_40points.mat');
res_RPM_50points = load('RPM_for_OPC_in_50points.mat');

res_LPM_20points = load('LPM_for_OPC_in_20points.mat');
res_LPM_30points = load('LPM_for_OPC_in_30points.mat');
res_LPM_40points = load('LPM_for_OPC_in_40points.mat');
res_LPM_50points = load('LPM_for_OPC_in_50points.mat');

res_CPM_20points = load('CPM_for_OPC_in_20points.mat');
res_CPM_30points = load('CPM_for_OPC_in_30points.mat');
res_CPM_40points = load('CPM_for_OPC_in_40points.mat');
res_CPM_50points = load('CPM_for_OPC_in_50points.mat');

res_SM_20points = load('SM_for_OPC_in_20points.mat');
res_SM_30points = load('SM_for_OPC_in_30points.mat');
res_SM_40points = load('SM_for_OPC_in_40points.mat');
res_SM_50points = load('SM_for_OPC_in_50points.mat');

res_MSM_20points = load('MSM_for_OPC_in_20points.mat');
res_MSM_30points = load('MSM_for_OPC_in_30points.mat');
res_MSM_40points = load('MSM_for_OPC_in_40points.mat');
res_MSM_50points = load('MSM_for_OPC_in_50points.mat');

%% ��ͼ 
window_width  = res_RPM_20points.window_width;
window_height = res_RPM_20points.window_height;

% ����ʱ����״ͼ
k = 0;
figure('color',[1 1 1],'position',[50+k*window_width,200,window_width,window_height]);
y = [res_RPM_20points.time_cal res_LPM_20points.time_cal res_CPM_20points.time_cal res_SM_20points.time_cal res_MSM_20points.time_cal
     res_RPM_30points.time_cal res_LPM_30points.time_cal res_CPM_30points.time_cal res_SM_30points.time_cal res_MSM_30points.time_cal
     res_RPM_40points.time_cal res_LPM_40points.time_cal res_CPM_40points.time_cal res_SM_40points.time_cal res_MSM_40points.time_cal
     res_RPM_50points.time_cal res_LPM_50points.time_cal res_CPM_50points.time_cal res_SM_50points.time_cal res_MSM_50points.time_cal];
plot(1:4,y,'x-','LineWidth',1.5);
ylabel('Calculation time');
set(gca,'YLim',[0,2],...
        'XLim',[1,4],...
        'XTick',1:4,....
        'XTickLabel',{'20 pts','30 pts','40 pts','50 pts'},...
        'FontSize',15,...
        'FontName','Times New Roman',...
        'LineWidth',1.5);
legend('RPM','LPM','CPM','���δ�з�','���ش�з�',...
       'Location','Northwest',...
       'FontName','��������',...
       'FontSize',10);

%%
% ��ͬ��ɢ����״̬���Ϳ������ıȽ�
k = 1;
figure('color',[1 1 1],'position',[50+k*window_width,200,window_width*1.5,window_height*1.5]);
% 20����ɢ��ıȽ�
subplot(221);
plot(res_RPM_20points.p.t, res_RPM_20points.p.x, 'o-', 'LineWidth',1.5);hold on;
plot(res_RPM_20points.p.t, res_RPM_20points.p.u, 'o-', 'LineWidth',1.5);
plot(res_LPM_20points.p.t, res_LPM_20points.p.x, 'x-', 'LineWidth',1.5);
plot(res_LPM_20points.p.t, res_LPM_20points.p.u, 'x-', 'LineWidth',1.5);
title('$N=20$','Interpreter','Latex');
xlabel('Time');
ylabel('Statr and control','interpreter','latex');
set(gca,'FontSize',15,...
        'FontName','Times New Roman',...
        'LineWidth',1.5,....
        'XTick',res_RPM_20points.p.t0:0.2:res_RPM_20points.p.tf);
% 30����ɢ��ıȽ�
subplot(222);
plot(res_RPM_30points.p.t, res_RPM_30points.p.x, 'o-', 'LineWidth',1.5);hold on;
plot(res_RPM_30points.p.t, res_RPM_30points.p.u, 'o-', 'LineWidth',1.5);
plot(res_LPM_30points.p.t, res_LPM_30points.p.x, 'x-', 'LineWidth',1.5);
plot(res_LPM_30points.p.t, res_LPM_30points.p.u, 'x-', 'LineWidth',1.5);
title('$N=30$','Interpreter','Latex');
xlabel('Time');
ylabel('Statr and control','interpreter','latex');
set(gca,'FontSize',15,...
        'FontName','Times New Roman',...
        'LineWidth',1.5,....
        'XTick',res_RPM_20points.p.t0:0.2:res_RPM_20points.p.tf);
legend('$x(t)$ in SM','$u(t)$ in SM',...
       '$x(t)$ in MSM','$u(t)$ in MSM',...
       'Location','Northeast',...
       'FontName','Times New Roman',...
       'FontSize',12,...
       'Interpreter','Latex');
% 40����ɢ��ıȽ�
subplot(223);
plot(res_RPM_40points.p.t, res_RPM_40points.p.x, 'o-', 'LineWidth',1.5);hold on;
plot(res_RPM_40points.p.t, res_RPM_40points.p.u, 'o-', 'LineWidth',1.5);
plot(res_LPM_40points.p.t, res_LPM_40points.p.x, 'x-', 'LineWidth',1.5);
plot(res_LPM_40points.p.t, res_LPM_40points.p.u, 'x-', 'LineWidth',1.5);
title('$N=40$','Interpreter','Latex');
xlabel('Time');
ylabel('Statr and control','interpreter','latex');
set(gca,'FontSize',15,...
        'FontName','Times New Roman',...
        'LineWidth',1.5,....
        'XTick',res_RPM_20points.p.t0:0.2:res_RPM_20points.p.tf);
% 50����ɢ��ıȽ� 
subplot(224);
plot(res_RPM_50points.p.t, res_RPM_50points.p.x, 'o-', 'LineWidth',1.5);hold on;
plot(res_RPM_50points.p.t, res_RPM_50points.p.u, 'o-', 'LineWidth',1.5);
plot(res_LPM_50points.p.t, res_LPM_50points.p.x, 'x-', 'LineWidth',1.5);
plot(res_LPM_50points.p.t, res_LPM_50points.p.u, 'x-', 'LineWidth',1.5);
title('$N=50$','Interpreter','Latex');
xlabel('Time');
ylabel('Statr and control','interpreter','latex');
set(gca,'FontSize',15,...
        'FontName','Times New Roman',...
        'LineWidth',1.5,....
        'XTick',res_RPM_20points.p.t0:0.2:res_RPM_20points.p.tf);    