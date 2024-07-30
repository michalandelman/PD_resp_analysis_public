function [median_total_scores,mean_total_scores,total_scores,yfit_PD] = ComputeClassifierMeanScoreWithAcc(max_num_of_5min,AllSubjData,WSA,num_param,param)

zscored = true;
if all([zscored,strcmpi('wake',WSA)])
    total_scores = zeros(size(AllSubjData,2),max_num_of_5min);
    yfit_PD = cell(size(AllSubjData,2),max_num_of_5min);
elseif all([zscored,strcmpi('sleep',WSA)])
    total_scores = zeros(size(AllSubjData,2)-1,max_num_of_5min);
    yfit_PD = cell(size(AllSubjData,2)-1,max_num_of_5min);
end

if all([zscored,strcmpi('wake',WSA)])
    for num_of_5min = 1:max_num_of_5min
        for sbj=1:size(AllSubjData,2)
            SubjectName=AllSubjData(sbj).Name;
            file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_zelano_wake_no_overlap_normalized.mat']);
            subj_mat = load([file.folder '/' file.name]);
            file_acc=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_average_acc_over_timewake_5min_no_overlap.mat']);
            acc = load([file_acc.folder '/' file_acc.name]);
            acc_data = acc.mat;
            for i = 1:numel(subj_mat.mat)
                subj_mat.mat(i).Accelaration = acc_data(i);
            end
            %subj_mat.mat(num_of_5min).Accelaration = acc_data(num_of_5min);
            F = @(s)any(structfun(@(a)isscalar(a)&&isnan(a),s)); % or All
            X = arrayfun(F,subj_mat.mat);
            subj_mat.mat(X) = [];
            for i = 1:num_param
                param_val = [subj_mat.mat.(param{i})]';
                means_param_wake(sbj,i) = param_val(num_of_5min);
            end
        end
        Table_param_wake = array2table(means_param_wake);
        Table_param_wake.Name = {AllSubjData.Name}';
        Table_param_wake.Group = {AllSubjData.Group}';
        for i = 1:num_param
            Table_param_wake = renamevars(Table_param_wake,i,param{i});
        end    
        network_table = table(Table_param_wake.Duty_Cycle_inhale,...
            Table_param_wake.COV_BreathingRate,Table_param_wake.Duty_Cycle_InhalePause,...
            Table_param_wake.Accelaration, Table_param_wake.Group);
        network_table = renamevars(network_table,["Var1","Var2","Var3","Var4","Var5"],["Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause","Acceleration","Group"]);   
        % % network_table = table(Table_param_wake.Rate,Table_param_wake.Duty_Cycle_inhale,...
        %     Table_param_wake.Duty_Cycle_exhale,Table_param_wake.COV_BreathingRate,...
        %     Table_param_wake.Group);
        % network_table = renamevars(network_table,["Var1","Var2","Var3","Var4","Var5"],["Rate","Duty_Cycle_inhale","Duty_Cycle_exhale","COV_BreathingRate","Group"]);
        % network_table = table(Table_param_wake.Duty_Cycle_inhale,...
        %     Table_param_wake.Inhale_Duration,Table_param_wake.COV_BreathingRate,...
        %     Table_param_wake.Group);
        % network_table = renamevars(network_table,["Var1","Var2","Var3","Var4"],["Duty_Cycle_inhale","Inhale_Duration","COV_BreathingRate","Group"]);
        Y_Group = network_table.Group;
        rng(10)
        [validationPredictions, validationScores,~] = trainClassifierSubspaceDiscriminantWithAcc(network_table);
        %[yfit,scores] = trainedClassifier.predictFcn(network_table);
        scores_PD = validationScores(:,1);
        total_scores(:,num_of_5min) = scores_PD;
        yfit_PD(:,num_of_5min) = validationPredictions;
    end
elseif  all([zscored,strcmpi('sleep',WSA)])
    for num_of_5min = 1:max_num_of_5min
        for sbj=1:size(AllSubjData,2)
            SubjectName=AllSubjData(sbj).Name;
            if ~strcmp(SubjectName,'NC33')
                file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_zelano_sleep_no_overlap_normalized.mat']);
                load([file.folder '/' file.name])
                F = @(s)any(structfun(@(a)isscalar(a)&&isnan(a),s)); % or All
                X = arrayfun(F,mat);
                mat(X) = [];
                for i = 1:num_param
                    param_val = [mat.(param{i})]';
                    means_param_sleep(sbj,i) = param_val(num_of_5min);
                end
            end
        end
        Table_param_sleep = array2table(means_param_sleep);
        Table_param_sleep.Name = {AllSubjData.Name}';
        Table_param_sleep.Group = {AllSubjData.Group}';
        for i = 1:num_param
            Table_param_sleep = renamevars(Table_param_sleep,i,param{i});
        end
        Table_param_sleep(28,:) = [];
        % network_table = table(Table_param_wake.Inhale_Duration,Table_param_wake.Rate,Table_param_wake.Duty_Cycle_inhale,...
        %     Table_param_wake.COV_BreathingRate,Table_param_wake.Duty_Cycle_InhalePause, Table_param_wake.Group);
        % network_table = renamevars(network_table,["Var1","Var2","Var3","Var4","Var5","Var6"],["Inhale_Duration","Rate","Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause","Group"]);
        network_table = table(Table_param_sleep.Duty_Cycle_inhale,...
            Table_param_sleep.COV_BreathingRate,Table_param_sleep.Duty_Cycle_InhalePause, Table_param_sleep.Group);
        network_table = renamevars(network_table,["Var1","Var2","Var3","Var4"],["Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause","Group"]);
        Y_Group = network_table.Group;
        rng(10)
        [validationPredictions, validationScores,~, ~] = trainClassifierSubspaceDiscriminant(network_table);
        %[validationPredictions, validationScores,~, ~] = trainClassifierLinearSVM3features(network_table);
        %[yfit,scores] = trainedClassifier.predictFcn(network_table);
        scores_PD = validationScores(:,1);
        total_scores(:,num_of_5min) = scores_PD;
        yfit_PD(:,num_of_5min) = validationPredictions;
    end
end

median_total_scores = median(total_scores,2);
mean_total_scores = mean(total_scores,2);
%disp(median_total_scores);

% prepare ROC curve
[X,Y,~,AUC] = perfcurve(Y_Group,mean_total_scores,'PD');
fig_open();
figure;
plot(X,Y,'LineWidth',1.5);
xlabel('False positive rate')
ylabel('True positive rate')
hline = refline(1);
hline.Color = [.7 .7 .7];
hline.LineStyle = "--";
hline.LineWidth = 2;
ax = gca;
ax.FontSize = 24;
ax.XLim = [-0.05 1.05];
ax.YLim = [-0.05 1.05];
xticks([0 0.2 0.4 0.6 0.8 1])
daspect([1 1 1])

disp(AUC);
end