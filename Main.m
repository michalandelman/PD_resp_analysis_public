clear;
clc;

%% Define colors
[cb] = cbrewer('qual', 'Set3', 12, 'pchip'); % set colors
cl(1, :) = cb(4, :);
cl(2, :) = cb(1, :);

%% Load data
if ~exist('allAnalysisFields','var')
    load('/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/NC_analysis/allAnalysisFields61.mat')
end

%% Define Parameters
param = {'Inhale_Volume','Exhale_Volume','Inhale_Duration','Exhale_Duration',...
    'Inhale_value','Exhale_value','Inter_breath_interval','Rate','Tidal_volume',...
    'Minute_Ventilation','Duty_Cycle_inhale','Duty_Cycle_exhale',...
    'COV_InhaleDutyCycle','COV_ExhaleDutyCycle','COV_BreathingRate',...
    'COV_InhaleVolume','COV_ExhaleVolume','Inhale_Pause_Duration',...
    'Exhale_Pause_Duration','COV_InhalePauseDutyCycle','COV_ExhalePauseDutyCycle',...
    'Duty_Cycle_InhalePause','Duty_Cycle_ExhalePause','PercentBreathsWithExhalePause',...
    'PercentBreathsWithInhalePause'};
num_param = length(param);
num_PD = sum(strcmp({allAnalysisFields.Group},'PD'));
num_control = sum(strcmp({allAnalysisFields.Group},'control'));

%% Compute parameters
max_num_min = 6; %half an hour
Table_param_wake = ComputeZelanoParam(allAnalysisFields,'wake',max_num_min);
Table_param_sleep = ComputeZelanoParam(allAnalysisFields,'sleep',max_num_min);

% Separate param for each group
% PD wake
Table_param_wake_PD = Table_param_wake(strcmp(Table_param_wake.Group, 'PD'), :);
% control wake
Table_param_wake_control = Table_param_wake(strcmp(Table_param_wake.Group, 'control'), :);
% PD sleep
Table_param_sleep_PD = Table_param_sleep(strcmp(Table_param_sleep.Group, 'PD'), :);
% control sleep
Table_param_sleep_control = Table_param_sleep(strcmp(Table_param_sleep.Group, 'control'), :);

% save tables to cvs
if ~exist('Zelano_param_wake_control.csv','file')
    writetable(Table_param_wake_control,'Zelano_param_wake_control.csv');
end
if ~exist('Zelano_param_wake_PD.csv','file')
    writetable(Table_param_wake_PD,'Zelano_param_wake_PD.csv');
end
if ~exist('Zelano_param_wake.csv','file')
    writetable(Table_param_wake,'Zelano_param_wake.csv');
end

%% test normality of data
chosen_param = ["Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause"];
for i = 1:length(chosen_param)
    param_PD = Table_param_wake_PD.(chosen_param(i));
    param_control = Table_param_wake_control.(chosen_param(i));
    [h_norm_PD,p_norm_PD] = kstest(param_PD);
    figure;
    tiledlayout(2,1)
    ax1 = nexttile;
    qqplot(ax1,param_PD)
    ylabel(ax1,chosen_param(i),'Interpreter', 'none')
    title(ax1,['QQ Plot of PD' chosen_param(i)],'Interpreter', 'none')
    [h_norm_control,p_norm_control] = kstest(param_control);
    ax2 = nexttile;
    qqplot(ax2,param_control)
    ylabel(ax2,chosen_param(i),'Interpreter', 'none')
    title(ax2,['QQ Plot of Control' chosen_param(i)],'Interpreter', 'none')
end

% Calculate param for short disease duration (Supp Fig 2)
% under 20 years disease duration
allAnalysisFields_under20 = allAnalysisFields;
allAnalysisFields_under20(:,5) = [];
Table_param_wake_PD_under20 = Table_param_wake_PD;
Table_param_wake_PD_under20(5,:) = [];

% under 10 years disease duration
allAnalysisFields_under10 = allAnalysisFields;
allAnalysisFields_under10(:,[4 5 6 12 15]) = [];
Table_param_wake_PD_under10 = Table_param_wake_PD;
allAnalysisFields_over10 = allAnalysisFields(:,[4 5 6 12 15]);
Table_param_wake_PD_over10 = Table_param_wake_PD([4 5 6 12 15],:);
% Table_param_sleep_PD_over10 = Table_param_sleep_PD;
% Table_param_sleep_PD_over10=Table_param_sleep_PD_over10([4 5 6 12 15],:);

% under 5 years disease duration
allAnalysisFields_under5 = allAnalysisFields;
allAnalysisFields_under5(:,[1 3 4 5 6 8 11 12 13 15 16 17 18 21 23 26]) = [];
allAnalysisFields_5_to_10 = allAnalysisFields(:,[1 3 8 11 13 16 17 18 21 23 26]);
Table_param_wake_PD_under5 = Table_param_wake_PD;
Table_param_wake_PD_under5([1 3 4 5 6 8 11 12 13 15 16 17 18 21 23 26],:) = [];
Table_param_wake_PD_5_to_10 = Table_param_wake_PD([1 3 8 11 13 16 17 18 21 23 26],:);
%Table_param_sleep_PD_over5 = Table_param_sleep_PD;
%Table_param_sleep_PD_over5=Table_param_sleep_PD_over5([1 3 4 5 6 8 11 12 13 15 16 17 18 21 23 26],:);
%allAnalysisFields_over5 = allAnalysisFields;
%allAnalysisFields_over5 = allAnalysisFields(:,[1 3 4 5 6 8 11 12 13 15 16 17 18 21 23 26 29:end]);

% Plot Graphs for presenting parameters and calculate stats (U - for
% abnornal distribution) - Fig 2 + Supp fig 2
type_of_graphs = {'SimpleBoxPlot','NiceBoxPlot','BarPlot','ViolinPlot'};
PresentGraphsForParam(allAnalysisFields_under5,Table_param_wake_PD_under5,Table_param_wake_control,type_of_graphs(2));

%% Compute combined score for the three selected features
% Compare with disease severity, age, L-Dopa

%% Present accelerometer data 
% Average acceleration
CompareAccBetweenGroups()

%% Compare women scores of each parameter with total distribution
% Supp fig 6
CompWomenWithTotalDist(chosen_param,Table_param_wake_PD,Table_param_wake_control)

%% feature selection - 3 features (n=61)
Result = Auto_UFSTool(means_param_wake,'MCFS');
Result = Auto_UFSTool(table2array(Table_param_wake(:,1:25)),'MCFS');

% AutoUFS_GUI()

%% check the length of the recording
recording_length = RecodingLength(allAnalysisFields,'wake');

%% Principal component analysis
% all parameters during first 30min
PCanalysis(Table_param_wake,num_PD,num_control,num_param);

% PCA for 3 chosen parameters during first 30min (each 5min block is presented separately)
% Fig 2
max_num_of_5min = 6;
[Table_for_PCA_wake_PD,Table_for_PCA_wake_control] = PCanalysisChosenParam(allAnalysisFields,max_num_of_5min,num_param,param);
% Present the 3 features on common figure
%fig_open();
figure;
s1 = scatter3(Table_for_PCA_wake_PD.Duty_Cycle_inhale,Table_for_PCA_wake_PD.Duty_Cycle_InhalePause,Table_for_PCA_wake_PD.COV_BreathingRate,100,cb(4,:),'filled','MarkerFaceAlpha',.7);
s1.MarkerEdgeColor = 'w';
hold on
s2 = scatter3(Table_for_PCA_wake_control.Duty_Cycle_inhale,Table_for_PCA_wake_control.Duty_Cycle_InhalePause,Table_for_PCA_wake_control.COV_BreathingRate,100,cb(5,:),'filled','MarkerFaceAlpha',.7);
s2.MarkerEdgeColor = 'w';
xlabel('DC inhale');
ylabel('DC inhale pause');
%ylim([-1 2]);
zlabel('CV rate');
legend('PD','Control');
ax = gca;
ax.FontSize = 24;
%xticks([-1:3])
%yticks([-1:3])

%% Compute parameters for 5min-6.5h (longitudinal) - wake
% Fig 1
max_num_of_5min = 78;
ChosenParamAlongTime(max_num_of_5min,allAnalysisFields,num_param,param,num_PD,num_control)

%% compute std over time (30 min) within each participant
% Supp Fig 5

if ~exist('Wake_all_5min_blocks_PD.mat','file')
    max_num_of_5min = 78;
    [Wake_all_5min_blocks_PD,~] = PCanalysisChosenParam(allAnalysisFields,max_num_of_5min,num_param,param);
elseif load('Wake_all_5min_blocks_PD.mat')
end
if ~exist('Wake_all_5min_blocks_control.mat','file')
    max_num_of_5min = 78;
    [~,Wake_all_5min_blocks_control] = PCanalysisChosenParam(allAnalysisFields,max_num_of_5min,num_param,param);
elseif load('Wake_all_5min_blocks_control.mat')
end

[p_PD, stats_PD, p_control, stats_control] = ...
    STDoverTime(Wake_all_5min_blocks_PD,Wake_all_5min_blocks_control,num_PD,num_control);

%% Apply classifier - Mean score wins - wake
% Fig 2
max_num_of_5min = 6;
% 3 features
[median_total_scores_wake,mean_total_scores_wake,total_scores_wake,yfit_PD_wake] = ComputeClassifierMeanScore(max_num_of_5min,allAnalysisFields,'wake',num_param,param);
[~,mean_total_scores_sleep,total_scores_sleep,yfit_PD_sleep] = ComputeClassifierMeanScore(max_num_of_5min,allAnalysisFields,'sleep',num_param,param);

% Even groups
allAnalysisFields_even_groups = allAnalysisFields;
allAnalysisFields_even_groups(:,(num_PD+[14 20 21 26 32])) = [];

% Supp fig 3
allAnalysisFields_under20 = allAnalysisFields;
num_PD_under20 = 27;
allAnalysisFields_under20(:,[5 num_PD+[14 20 21 26 32 33]]) = [];

allAnalysisFields_under10 = allAnalysisFields;
num_PD_under10 = 23;
allAnalysisFields_under10(:,[4 5 6 12 15 num_PD+[14 20 21 26 32 33 13 15 8 3]]) = [];

num_PD_over10 = 5;
allAnalysisFields_over10 = allAnalysisFields(:,[4 5 6 12 15 num_PD+[33 13 15 8 3]]);

num_PD_5_to_10 = 11;
allAnalysisFields_5_to_10 = allAnalysisFields(:,[1 3 8 11 13 16 17 18 21 23 26 num_PD+[23 9 29 19 2 17 1 11 7 16 4]]);

allAnalysisFields_under5 = allAnalysisFields(:,[2 7 9 10 14 19 20 22 24 25 27 28 num_PD+[5 25 12 10 28 27 24 30 22 6 18 31]]);
num_PD_under5 = 12;

allAnalysisFields_withLDopa = allAnalysisFields;
allAnalysisFields_withLDopa(:,[2,9,14,19,21,24,25,27,28]) = [];
num_PD_withLDopa = 19;

allAnalysisFields_noLDopa = allAnalysisFields(:,[2,9,14,19,21,24,25,27,28:end]); 
num_PD_noLDopa = 9;

%% With acceleration
max_num_of_5min = 6;
num_param_with_acc = 26;
param_with_acc = {'Inhale_Volume','Exhale_Volume','Inhale_Duration','Exhale_Duration',...
    'Inhale_value','Exhale_value','Inter_breath_interval','Rate','Tidal_volume',...
    'Minute_Ventilation','Duty_Cycle_inhale','Duty_Cycle_exhale',...
    'COV_InhaleDutyCycle','COV_ExhaleDutyCycle','COV_BreathingRate',...
    'COV_InhaleVolume','COV_ExhaleVolume','Inhale_Pause_Duration',...
    'Exhale_Pause_Duration','COV_InhalePauseDutyCycle','COV_ExhalePauseDutyCycle',...
    'Duty_Cycle_InhalePause','Duty_Cycle_ExhalePause','PercentBreathsWithExhalePause',...
    'PercentBreathsWithInhalePause','Accelaration'};
allAnalysisFieldsWithAcc = allAnalysisFields;
allAnalysisFieldsWithAcc(:,[3,5,7,11,18,28,28+[3 15 23]]) = [];
allAnalysisFieldsWithAccEvenGroup = allAnalysisFields;
allAnalysisFieldsWithAccEvenGroup(:,[3,5,7,11,18,28,28+[3 9 11 15 19 23 25 31 33]]) = [];
% 3 features
[median_total_scores_wake,mean_total_scores_wake,total_scores_wake,yfit_PD_wake] = ComputeClassifierMeanScoreWithAcc(max_num_of_5min,allAnalysisFieldsWithAccEvenGroup,'wake',num_param_with_acc,param_with_acc);

%% Apply classifier - Mean score wins - wake - larger blocks
% Fig 2
size_of_block = 78; % 24:10,11, 25:9,10, 26:9,9, 27:10,9, 28:9,9, 29:9,9, 30:10,8, 78:11,8
% 3 features
[median_total_scores,mean_total_scores,total_scores,yfit_PD] = ComputeClassifierMeanScore_large_blocks(size_of_block,allAnalysisFields,'wake',num_param,param);
length(find(mean_total_scores(1:28)<0.5))
length(find(mean_total_scores(29:end)>0.5))

%% Show women on classifier's distribution
WomenScoresOnClassifier(mean_total_scores_wake,num_PD,num_control)

%% Bootstrap to get distribution of accuracy (for wake)
% Fig 2
bootstrap_num_max = 1000;
max_num_of_5min = 6;
if ~exist('accuracy_bootstrap.mat','file')
    [accuracy_bootstrap] = BootstrapAccOfClassifier(bootstrap_num_max,max_num_of_5min,allAnalysisFields,num_param,param);
    save('accuracy_bootstrap.mat','accuracy_bootstrap');
else
    load('accuracy_bootstrap.mat');
end

%% Wake - Median score wins - only men
max_num_of_5min = 6;
median_total_scores_men = ComputeClassifierMedianScoreMen(max_num_of_5min,allAnalysisFields,num_param,param);

%% regression calculation with disease progression
% Fig 3
% Load disease progression data
if ~exist('PD_disease_prog','var')
    PD_disease_prog = readtable('/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Questionnaires/Results/questionnaires/disease_duration_NC.xlsx');
end

max_num_of_5min = 6;
UPDRS_type = {'UPDRS_I','UPDRS_II','UPDRS_III','UPDRS_IV','UPDRS_total'};
dis_prog = PD_disease_prog.(UPDRS_type{5});

% Supp fig 4
dis_prog_under20 = dis_prog;
dis_prog_under20(5) = [];
dis_prog_under10 = dis_prog;
dis_prog_under10([4 5 6 12 15]) = [];
% under 5 years disease duration
dis_prog_under5 = dis_prog;
dis_prog_under5([1 3 4 5 6 8 11 12 13 15 16 17 18 21 23 26]) = [];

% Supp mat 4 + Fig 2
% plot mean param vs. age/severity
% Define the variables and their corresponding labels
chosen_param = {'Duty_Cycle_inhale', 'COV_BreathingRate', 'Duty_Cycle_InhalePause'};
for i = 1:length(chosen_param)
    figure;
    s = scatter(dis_prog,Table_param_wake_PD.(chosen_param{i}),100,cb(4,:),'filled');
    s.MarkerEdgeColor = 'w';
    xlabel('UPDRS-MDS Total score'); ylabel(chosen_param{i},'Interpreter','none');
    l = refline(); l.Color = 'k'; l.LineWidth = 1;
    [r,p] = corr(dis_prog,Table_param_wake_PD.(chosen_param{i}),'type','Spearman')
    figure;
    s2 = scatter(PD_disease_prog.Age,Table_param_wake_PD.(chosen_param{i}),100,cb(4,:),'filled');
    s2.MarkerEdgeColor = 'w';
    xlabel('Age'); ylabel(chosen_param{i},'Interpreter','none');
    l2 = refline(); l2.Color = 'k'; l2.LineWidth = 1;
    [r,p] = corr(Table_param_wake_PD.(chosen_param{i}),PD_disease_prog.Age,'type','Pearson')
end

% Fig 2
% Create combined score for the three figures
zscore_duty_cycle = zscore(-1*Table_param_wake.Duty_Cycle_inhale);
zscore_CV_rate = zscore(Table_param_wake.COV_BreathingRate);
zscore_duty_cycle_inhale_pause = zscore(Table_param_wake.Duty_Cycle_InhalePause);
combined_score = zscore_duty_cycle+zscore_CV_rate+zscore_duty_cycle_inhale_pause;

[r,p] = corr(PD_disease_prog.UPDRS_total,combined_score(1:28),'type','Spearman')
figure;
s1 = scatter(PD_disease_prog.UPDRS_total,combined_score(1:28),100,cb(4,:),'filled');
s1.MarkerEdgeColor = 'w';
xlabel('UPDRS Total'); ylabel('Combined Score');
l1 = refline(); l1.Color = 'k'; l1.LineWidth = 1;
[r,p] = corr(PD_disease_prog.Age,combined_score(1:28))
figure;
s2 = scatter(PD_disease_prog.Age,combined_score(1:28),100,cb(4,:),'filled');
s2.MarkerEdgeColor = 'w';
xlabel('Age'); ylabel('Combined Score');
l2 = refline(); l2.Color = 'k'; l2.LineWidth = 1;

param_PD_no_LDopa = combined_score([2,9,14,19,21,24,25,27,28]);
param_PD_with_LDopa = combined_score(1:28);
param_PD_with_LDopa([2,9,14,19,21,24,25,27,28])=[];

ratings = [{param_PD_no_LDopa} {param_PD_with_LDopa}];
%group = categorical([repmat(1,1,num_control),repmat(2,1,num_PD)]);
figure;
hold on
colors = [3 1];
for m = 1:2
    b = boxchart(categorical(repmat(m,size(ratings{m},1),1)),ratings{m});
    b.MarkerStyle = 'none';
    b.LineWidth = 2;
    b.BoxFaceAlpha = 0.5;
    b.BoxFaceColor = cb(colors(m),:);
end
xticklabels({'No L-Dopa','With L-Dopa'});
ax = gca;
ax.YAxis.FontSize = 30;
ax.XAxis.FontSize = 30;
ax.LineWidth = 4;
%ylim([0 0.5]);
%yticks([0 100]);
box on
xlabel('Group','FontSize', 30);
ylabel('Combined Score','Fontsize',30);
[p_U,h_U,stats_U] = ranksum(param_PD_no_LDopa,param_PD_with_LDopa);
Effect = meanEffectSize(param_PD_no_LDopa,param_PD_with_LDopa,Effect="Cliff");
disp(['U test, p = ',num2str(p_U)]);
disp(stats_U);
disp(Effect);
disp(['mean PD no L-DOPA: ',num2str(mean(param_PD_no_LDopa)), 'mean PD with L-DOPA:', num2str(mean(param_PD_with_LDopa))]);
disp(['STD PD no L-DOPA: ',num2str(std(param_PD_no_LDopa)), 'STD PD with L-DOPA:', num2str(std(param_PD_with_LDopa))]);


param_PD = combined_score(1:28);
param_control = combined_score(29:end);
ratings = [{param_control} {param_PD}];
%group = categorical([repmat(1,1,num_control),repmat(2,1,num_PD)]);
figure;
hold on
colors = [5 4];
for m = 1:2
    b = boxchart(categorical(repmat(m,size(ratings{m},1),1)),ratings{m});
    b.MarkerStyle = 'none';
    b.LineWidth = 2;
    b.BoxFaceAlpha = 0.5;
    b.BoxFaceColor = cb(colors(m),:);
end
xticklabels({'Control','PD'});
ax = gca;
ax.YAxis.FontSize = 30;
ax.XAxis.FontSize = 30;
ax.LineWidth = 4;
%ylim([0 0.5]);
%yticks([0 100]);
box on
xlabel('Group','FontSize', 30);
ylabel('Combined Score','Fontsize',30);
ylim([-7 7])
[p_U,h_U,stats_U] = ranksum(param_PD,param_control);
Effect = meanEffectSize(param_PD,param_control,Effect="Cliff");
disp(['U test, p = ',num2str(p_U)]);
disp(stats_U);
disp(Effect);
disp(['mean PD: ',num2str(mean(param_PD)), 'mean_control:', num2str(mean(param_control))]);
disp(['STD PD: ',num2str(std(param_PD)), 'STD_control:', num2str(std(param_control))]);

%% Compute parameters for regression
max_num_min = 6; %half an hour
Table_param_wake = ComputeZelanoParam(allAnalysisFields,'wake',max_num_min);

inhale_exhale_pause_perc = [Table_param_wake.PercentBreathsWithExhalePause Table_param_wake.PercentBreathsWithInhalePause];
inhale_exhale_pause_perc_PD = inhale_exhale_pause_perc(1:28,:);
% inhale_exhale_pause_perc_under20 = inhale_exhale_pause_perc_PD;
% inhale_exhale_pause_perc_under20(5,:) = [];
% inhale_exhale_pause_perc_under10 = inhale_exhale_pause_perc_PD;
% inhale_exhale_pause_perc_under10([4 5 6 12 15],:) = [];
% inhale_exhale_pause_perc_under5 = inhale_exhale_pause_perc_PD;
% inhale_exhale_pause_perc_under5([1 3 4 5 6 8 11 12 13 15 16 17 18 21 23 26],:) = [];
selected_features = [Table_param_wake.Duty_Cycle_inhale Table_param_wake.COV_BreathingRate Table_param_wake.Duty_Cycle_InhalePause];
selected_features_for_reg = selected_features(1:28,:);
selected_features_for_reg_under20 = selected_features_for_reg;
selected_features_for_reg_under20(5,:) = [];
selected_features_for_reg_under10 = selected_features_for_reg;
selected_features_for_reg_under10([4 5 6 12 15],:) = [];
selected_features_for_reg_under5 = selected_features_for_reg;
selected_features_for_reg_under5([1 3 4 5 6 8 11 12 13 15 16 17 18 21 23 26],:) = [];

% [validationPredictions,trainedModel, validationRMSE] = trainRegressionModelLinearReg3features(selected_features_for_reg_under5, dis_prog_under5);
[trainedModel, validationRMSE,validationPredictions] = trainRegressionModelIntLinearReg(inhale_exhale_pause_perc_PD, dis_prog);
[r,p] = corr(validationPredictions,dis_prog);
%[cor_val,p_val] = corr(validationPredictions,dis_prog,'Rows','pairwise','type','Spearman');

RegressionCorFig(validationPredictions,dis_prog);

% apply bootstrap
dis_prog = PD_disease_prog.(UPDRS_type{5});
regression_bootstrap = zeros(1,1000);
for bootstrap_num = 1:1000
    dis_prog_rand = dis_prog(randperm(size(dis_prog, 1)), :);
    [~, ~,validationPredictions] = trainRegressionModelIntLinearReg(inhale_exhale_pause_perc(1:num_PD,:), dis_prog_rand);
    [regression_score,p] = corr(validationPredictions,dis_prog);
    regression_bootstrap(bootstrap_num) = regression_score;
    %disp(bootstrap_num)
end

figure;
histogram(regression_bootstrap,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.9 0.9 0.9],...
    'FaceAlpha',0.6);
xlim([-1 1]);

zscore_regression_bootstrap = zscore(regression_bootstrap);
zscore_regression_bootstrap_and_actual = zscore([regression_bootstrap 0.49]);
normcdf(0.49,mean(regression_bootstrap),std(regression_bootstrap));

%[trainedModel, validationRMSE, validationPredictions] = trainRegressionModelSVM(inhale_exhale_pause_perc, dis_prog);
% [mean_regression_scores,median_regression_scores,cor_val,p_val] = ComputeRegressionMedianScore(max_num_of_5min,AllSubjData,num_param,param,dis_prog);

%% Bootstrap to get distribution of regression
% Fig 3
% bootstrap_num_max = 2;
% max_num_of_5min = 6;
% %UPDRS_type = {'UPDRS_I','UPDRS_II','UPDRS_III','UPDRS_IV','UPDRS_total'};
% %dis_prog = PD_disease_prog.(UPDRS_type{5});
% [mean_regression_scores,median_regression_scores,cor_val,p_val] = ComputeRegressionMedianScore(max_num_of_5min,allAnalysisFields,num_param,param,dis_prog);
% 
% if ~exist('regression_bootstrap.mat','file')
%     [regression_bootstrap] = BootstrapRegressionDisProg(bootstrap_num_max,max_num_of_5min,allAnalysisFields,num_param,param,dis_prog,num_PD);
%     save('regression_bootstrap.mat',accuracy_bootstrap);
% else
%     load('regression_bootstrap.mat');
% end

%% Compute accuracy for 5min-6.5h (longitudinal) - wake/sleep
% Fig 2 + Supp Fig 1

% Median score wins
if ~exist('AUC_all_wake.mat','file')
    max_num_of_5min = 78;
    [AUC_all_wake] = AUCLongitudinal(allAnalysisFields,max_num_of_5min,num_PD,num_control,'wake',num_param,param);
    save('AUC_all_wake.mat','AUC_all_wake')
elseif load('AUC_all_wake.mat')
end
if ~exist('AUC_all_sleep.mat','file')
    max_num_of_5min = 11;
    [AUC_all_sleep] = AUCLongitudinal(allAnalysisFields,max_num_of_5min,num_PD,num_control,'sleep',num_param,param);
    save('AUC_all_sleep.mat','AUC_all_sleep')
elseif load('AUC_all_sleep.mat')
end

%% Compute accuracy for each 30 min block (5-min sliding window) 

% Mean score wins
if ~exist('total_acc_half_hours.mat','file')
    max_num_of_5min = 72;
    [total_acc_half_hours] = AccHalfHours(allAnalysisFields,max_num_of_5min,num_PD,num_control,num_param,param);
    save('total_acc_half_hours.mat','total_acc_half_hours')
elseif load('total_acc_half_hours.mat')
end

%% caclulate model prediction with olfactory data
Healthy_sniffin_sticks = readtable('/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Questionnaires/Results/Sniffin_sticks/Sniffin_Sticks_Healthy.xlsx');
all_snifin_sticks = readtable('/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Questionnaires/Results/Sniffin_sticks/Sniffin_Sticks_31_7_23_NCexp.xlsx');

[trainedClassifier, validationAccuracy] = trainClassifierOlfaction(all_snifin_sticks);
[yfit,scores] = trainedClassifier.predictFcn(all_snifin_sticks);

[X,Y,T,AUC] = perfcurve(Y_Group,scores(:,2),'PD');

%% Supp 5 - correlation between anxiety and resp param
load anxiety_resp.mat
[r,p] = AnxietyFig(AllSubjData,11,param);