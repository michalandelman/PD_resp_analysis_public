function [zscore_women_median_scores_PD,zscore_women_median_scores_control] =...
    WomenScoresOnClassifier(median_total_scores,num_PD,num_control)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

% colors
[cb] = cbrewer('qual', 'Set3', 12, 'pchip'); % set colors
cl(1, :) = cb(4, :);
cl(2, :) = cb(1, :);

women_median_total_scores_PD = median_total_scores([10,24]);
zscore_median_total_scores_PD = zscore(median_total_scores(1:28));
zscore_women_median_scores_PD = zscore_median_total_scores_PD([10,24]);

women_median_total_scores_control = median_total_scores(num_PD+[10,14,22,32]);
zscore_median_total_scores_control = zscore(median_total_scores(29:end));
zscore_women_median_scores_control = zscore_median_total_scores_control([10,14,22,32]);

% figure boxplot
param_PD = median_total_scores(1:28);
param_control = median_total_scores(29:end);
ratings = [{param_PD} {param_control}];
group = categorical([repmat(1,1,num_PD),repmat(2,1,num_control)]);
figure;
hold on
colors = [4 5];
for m = 1:2
    b = boxchart(categorical(repmat(m,size(ratings{m},1),1)),ratings{m});
    b.MarkerStyle = 'none';
    b.LineWidth = 2;
    b.BoxFaceAlpha = 0.5;
    b.BoxFaceColor = cb(colors(m),:);
end
scatter(group(1),women_median_total_scores_PD,'o','k','SizeData',75,'jitter','on', 'jitterAmount', 0.07);
scatter(group(29),women_median_total_scores_control,'o','k','SizeData',75,'jitter','on', 'jitterAmount', 0.07);
xticklabels({'PD','Control'});
ax = gca;
ax.YAxis.FontSize = 30;
ax.XAxis.FontSize = 30;
ax.LineWidth = 4;
%ylim([-20 120]);
%yticks([0 100]);
box on
xlabel('Group','FontSize', 30);
ylabel('Median score','Interpreter', 'none','Fontsize',30);

if ~exist('median_scores_30min.csv','file')
    writematrix(median_total_scores,'median_scores_30min.csv');
end
disp('PD women Zscore: '); 
disp(zscore_women_median_scores_PD); 
disp('Control women Zscore: '); 
disp(zscore_women_median_scores_control);
end