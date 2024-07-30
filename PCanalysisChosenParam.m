function [Table_for_PCA_wake_PD,Table_for_PCA_wake_control] = PCanalysisChosenParam(AllSubjData,max_num_of_5min,num_param,param)

% Define colors
[cb] = cbrewer('qual', 'Set3', 12, 'pchip'); % set colors
cl(1, :) = cb(4, :);
cl(2, :) = cb(1, :);

network_tables = [];
for num_of_5min = 1:max_num_of_5min
    for sbj=1:size(AllSubjData,2)
        SubjectName=AllSubjData(sbj).Name;
        file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_zelano_wake_no_overlap_normalized.mat']);
        load([file.folder '/' file.name])
        F = @(s)any(structfun(@(a)isscalar(a)&&isnan(a),s)); % or All
        X = arrayfun(F,mat);
        mat(X) = [];
        for i = 1:num_param
            param_val = [mat.(param{i})]';
            means_param_wake(sbj,i) = param_val(num_of_5min);
        end
    end
    Table_param_wake = array2table(means_param_wake);
    Table_param_wake.Name = {AllSubjData.Name}';
    Table_param_wake.Group = {AllSubjData.Group}';
    for i = 1:num_param
        Table_param_wake = renamevars(Table_param_wake,i,param{i});
    end
    % network_table = table(Table_param_wake.Inhale_Duration,Table_param_wake.Rate,Table_param_wake.Duty_Cycle_inhale,...
    %     Table_param_wake.COV_BreathingRate,Table_param_wake.Duty_Cycle_InhalePause, Table_param_wake.Group);
    % network_table = renamevars(network_table,["Var1","Var2","Var3","Var4","Var5","Var6"],["Inhale_Duration","Rate","Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause","Group"]);
    network_table = table(Table_param_wake.Duty_Cycle_inhale,...
        Table_param_wake.COV_BreathingRate,Table_param_wake.Duty_Cycle_InhalePause, Table_param_wake.Group);
    network_table = renamevars(network_table,["Var1","Var2","Var3","Var4"],["Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause","Group"]);
    network_tables = [network_tables; network_table];
end

Table_for_PCA_wake_PD = network_tables(strcmp(network_tables.Group, 'PD'), :);
Table_for_PCA_wake_control = network_tables(strcmp(network_tables.Group, 'control'), :);
Table_for_PCA_wake_all = [Table_for_PCA_wake_PD; Table_for_PCA_wake_control];

[~,score_zelano,~,~,explained,~]...
    = pca(table2array(Table_for_PCA_wake_all(:,1:3)));

% Plot everyone
pc1_healthy = score_zelano((size(Table_for_PCA_wake_PD,1)+1):(size(Table_for_PCA_wake_PD,1)+size(Table_for_PCA_wake_control,1)),1);
pc2_healthy = score_zelano((size(Table_for_PCA_wake_PD,1)+1):(size(Table_for_PCA_wake_PD,1)+size(Table_for_PCA_wake_control,1)),2);
pc3_healthy = score_zelano((size(Table_for_PCA_wake_PD,1)+1):(size(Table_for_PCA_wake_PD,1)+size(Table_for_PCA_wake_control,1)),3);

pc1_PD = score_zelano(1:size(Table_for_PCA_wake_PD,1),1);
pc2_PD = score_zelano(1:size(Table_for_PCA_wake_PD,1),2);
pc3_PD = score_zelano(1:size(Table_for_PCA_wake_PD,1),3);

%Plot
fig_open();
figure;
s1 = scatter(pc1_healthy,pc2_healthy,100,cb(5,:),'filled','MarkerFaceAlpha',.7);
s1.MarkerEdgeColor = 'w';
hold on
s2 = scatter(pc1_PD,pc2_PD,100,cb(4,:),'filled','MarkerFaceAlpha',.7);
s2.MarkerEdgeColor = 'w';
xlabel('PC1');
ylabel('PC2');
ylim([-1 2]);
zlabel('PC3');
legend('healthy','PD');
ax = gca;
ax.FontSize = 24;
xticks([-1:3])
yticks([-1:3])

end