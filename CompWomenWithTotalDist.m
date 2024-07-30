function CompWomenWithTotalDist(chosen_param,Table_param_PD,Table_param_control)

% women PD: NC10, NC29. Women control: NCH10, NCH14, NCH22, NCH32.
for i = 1:length(chosen_param)
    param_PD = Table_param_PD.(chosen_param(i));
    z_score_param_PD = zscore(param_PD);
    figure;
    histogram(z_score_param_PD);
    women_z_PD = z_score_param_PD([10,24]);
    disp(women_z_PD);
    % men_PD = param_PD;
    % men_PD([10,24]) = [];
    param_control = Table_param_control.(chosen_param(i));
    z_score_param_control = zscore(param_control);
    figure;
    histogram(z_score_param_control);
    women_z_control = z_score_param_control([10,14,22,32]);
    disp(women_z_control);
    % men_control = param_control;
    % men_control([10,14,22,32]) = [];
end

% idx_chosen_param = [3,8,11,15,18];
% % PCA for everyone
% [~,score_30min_control,~,~,~,~]...
%     = pca(table2array(Table_param_wake_control(:,idx_chosen_param)));
% pc1_control_men = score_30min_control([1:9,11:13,15:21,23:31,33],1);
% pc2_control_men = score_30min_control([1:9,11:13,15:21,23:31,33],2);
% pc1_control_women = score_30min_control([10,14,22,32],1);
% pc2_control_women = score_30min_control([10,14,22,32],2);
% 
% figure;
% scatter(pc1_control_men,pc2_control_men);
% hold on
% scatter(pc1_control_women,pc2_control_women);
% 
% [~,score_30min_PD,~,~,~,~]...
%     = pca(table2array(Table_param_wake_PD(:,idx_chosen_param)));
% pc1_PD_men = score_30min_PD([1:9,11:23,25:end],1);
% pc2_PD_men = score_30min_PD([1:9,11:23,25:end],2);
% pc1_PD_women = score_30min_PD([10,24],1);
% pc2_PD_women = score_30min_PD([10,24],2);
% 
% figure;
% scatter(pc1_PD_men,pc2_PD_men);
% hold on
% scatter(pc1_PD_women,pc2_PD_women);
end