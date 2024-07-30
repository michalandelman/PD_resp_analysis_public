function [accuracy_bootstrap] = BootstrapAccOfClassifier(bootstrap_num_max,max_num_of_5min,AllSubjData,num_param,param)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
accuracy_bootstrap = zeros(1,bootstrap_num_max);
for bootstrap_num = 1:bootstrap_num_max
    total_scores = zeros(size(AllSubjData,2),max_num_of_5min);
    yfit_PD = cell(size(AllSubjData,2),max_num_of_5min);
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
        Group = {AllSubjData.Group}';
        Table_param_wake.Group = Group(randperm(size(Group, 1)), :);
        %disp(Table_param_wake.Group)
        for i = 1:num_param
            Table_param_wake = renamevars(Table_param_wake,i,param{i});
        end
        % network_table = table(Table_param_wake.Inhale_Duration,Table_param_wake.Rate,Table_param_wake.Duty_Cycle_inhale,...
        %     Table_param_wake.COV_BreathingRate,Table_param_wake.Duty_Cycle_InhalePause, Table_param_wake.Group);
        % network_table = renamevars(network_table,["Var1","Var2","Var3","Var4","Var5","Var6"],["Inhale_Duration","Rate","Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause","Group"]);
        network_table = table(Table_param_wake.Duty_Cycle_inhale,...
            Table_param_wake.COV_BreathingRate,Table_param_wake.Duty_Cycle_InhalePause, Table_param_wake.Group);
        network_table = renamevars(network_table,["Var1","Var2","Var3","Var4"],["Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause","Group"]);   
        % Y_Group = network_table.Group;
        %rng(10)
        [validationPredictions, validationScores,~, ~] = trainClassifierSubspaceDiscriminant(network_table);
        %[yfit,scores] = trainedClassifier.predictFcn(network_table);
        scores_PD = validationScores(:,1);
        total_scores(:,num_of_5min) = scores_PD;
        yfit_PD(:,num_of_5min) = validationPredictions;
    end
    mean_total_scores = mean(total_scores,2);
    accuracy = (sum(mean_total_scores(1:28)>0.5) + sum(mean_total_scores(29:end)<0.5))/61;
    %disp(accuracy)
    accuracy_bootstrap(bootstrap_num) = accuracy;
    disp(bootstrap_num)
end

figure;
histogram(accuracy_bootstrap,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.9 0.9 0.9],...
    'FaceAlpha',0.6);
xlim([0 1]);

zscore_accuracy_bootstrap = zscore(accuracy_bootstrap);
disp(normcdf(0.87,mean(accuracy_bootstrap),std(accuracy_bootstrap)));

end