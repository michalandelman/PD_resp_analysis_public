function median_total_scores_men = ComputeClassifierMedianScoreMen(max_num_of_5min,AllSubjData,num_param,param)
total_scores = zeros(size(AllSubjData,2)-6,max_num_of_5min);
yfit_PD = cell(size(AllSubjData,2)-6,max_num_of_5min);
for num_of_5min = 1:max_num_of_5min
    for sbj=1:size(AllSubjData,2)
        SubjectName=AllSubjData(sbj).Name;
        if ~any(strcmp(SubjectName,{'NC10','NC29','NCH10','NCH14','NCH22','NCH32'}))
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
    end
    Table_param_wake = array2table(means_param_wake);
    Table_param_wake.Name = {AllSubjData.Name}';
    Table_param_wake.Group = {AllSubjData.Group}';
    for i = 1:num_param
        Table_param_wake = renamevars(Table_param_wake,i,param{i});
    end
    Table_param_wake([10 24 38 42 51 60],:) = [];
    network_table = table(Table_param_wake.Inhale_Duration,Table_param_wake.Rate,Table_param_wake.Duty_Cycle_inhale,...
        Table_param_wake.COV_BreathingRate,Table_param_wake.Duty_Cycle_InhalePause, Table_param_wake.Group);
    network_table = renamevars(network_table,["Var1","Var2","Var3","Var4","Var5","Var6"],["Inhale_Duration","Rate","Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause","Group"]);
    Y_Group = network_table.Group;
    rng(10)
    [trainedClassifier, ~] = trainClassifierSubspaceDiscriminant(network_table);
    [yfit,scores] = trainedClassifier.predictFcn(network_table);
    scores_PD = scores(:,1);
    total_scores(:,num_of_5min) = scores_PD;
    yfit_PD(:,num_of_5min) = yfit;
end

median_total_scores_men = median(total_scores,2);

end