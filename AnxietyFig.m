function [r,p] = AnxietyFig(AllSubjData,param_name,param)

% Define colors
[cb] = cbrewer('qual', 'Set3', 12, 'pchip'); % set colors
cl(1, :) = cb(4, :);
cl(2, :) = cb(1, :);

anxiety_param = [AllSubjData.TA]';
all_param = cell(1,25);
for i = 1:25
    curr_param_name = param{i};
    extracted_columns = [];
    for j = 1:98       
        column_table = {AllSubjData.mean_wake};
        cur_table = column_table{j};
        cur_param = cur_table.(curr_param_name);
        extracted_columns = [extracted_columns; cur_param];
    end
    all_param{i} = extracted_columns;
end

mat_param = [anxiety_param(1:98) all_param{param_name}];
% mat_param(end-8,:) = []; onlty for CV Inhale Volume, ration cannot be >1
mat_param(any(isnan(mat_param),2),:)=[];
current_param = mat_param(:,1); 
dis_prog_fig = mat_param(:,2);

[dis_prog_fig,k] = sort(dis_prog_fig); 
current_param = current_param(k); 
[p,s]=polyfit(dis_prog_fig,current_param,1);
[yfit,dy]=polyconf(p,dis_prog_fig,s,'predopt','curve');

fig_open();
figure;
a= 100;
xconf = [dis_prog_fig' fliplr(dis_prog_fig')] ;         
yconf = [[yfit+dy]' fliplr([yfit-dy]')];
jitterX = 0; % Jitter amount for x-axis
jitterY = 0; % Jitter amount for y-axis
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
xlabel([param{param_name}]);
ylabel('Anxiety Score');
%axis equal
%xlim([0.3 1])

[r,p] = corr(current_param,dis_prog_fig,'Type','Spearman');
