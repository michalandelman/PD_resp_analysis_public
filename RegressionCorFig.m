function RegressionCorFig(validationPredictions,dis_prog)

[cb] = cbrewer('qual', 'Set3', 12, 'pchip'); % set colors
cl(1, :) = cb(4, :);
cl(2, :) = cb(1, :);

current_param = validationPredictions; 
dis_prog_fig = dis_prog;

[dis_prog_fig,k] = sort(dis_prog_fig); 
current_param = current_param(k); 
[p,s]=polyfit(dis_prog_fig,current_param,1);
[yfit,dy]=polyconf(p,dis_prog_fig,s,'predopt','curve');

fig_open();
figure;
a= 100;
xconf = [dis_prog_fig' fliplr(dis_prog_fig')] ;         
yconf = [[yfit+dy]' fliplr([yfit-dy]')];
jitterX = 1.5; % Jitter amount for x-axis
jitterY = 1.5; % Jitter amount for y-axis
xJittered = dis_prog_fig + jitterX * rand(size(dis_prog_fig)) - jitterX/2;
yJittered = current_param + jitterY * rand(size(current_param)) - jitterY/2;
p = fill(xconf,yconf,cb(5,:),'FaceAlpha',0.2);
%p.FaceColor = [0.9 0.9 0.9];      
p.EdgeColor = 'none';  
hold on
line(dis_prog_fig,yfit,'color','k','LineWidth',1);
% e = errorbar(xJittered,yJittered,std_resgression_scores./sqrt(max_num_of_5min),...
%     'Color',[.7 .7 .7], 'LineWidth', 0.5,"LineStyle","none");
h1 = scatter(xJittered,yJittered,a,cb(5,:),'filled');
h1.MarkerEdgeColor = 'w';
%e.CapSize = 0;
ax = gca;
ax.YAxis.FontSize = 24;
ax.XAxis.FontSize = 24;
xlabel('MDS-UPDRS Total');
ylabel('Predicted Score');
%axis equal
ylim([25 87]);
xlim([25 87]);
