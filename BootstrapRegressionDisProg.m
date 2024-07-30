function [regression_bootstrap] = BootstrapRegressionDisProg(bootstrap_num_max,max_num_of_5min,AllSubjData,num_param,param,dis_prog,num_PD)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
regression_bootstrap = zeros(1,bootstrap_num_max);
for bootstrap_num = 1:bootstrap_num_max
    scores_regression_PD = zeros(num_PD,max_num_of_5min);
    for num_of_5min = 1:max_num_of_5min
        for sbj=1:num_PD
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
        dis_prog_rand = dis_prog(randperm(size(dis_prog, 1)), :);
        for i = 1:num_param
            Table_param_wake = renamevars(Table_param_wake,i,param{i});
        end
        network_table = table(Table_param_wake.Inhale_Duration,Table_param_wake.Rate,Table_param_wake.Duty_Cycle_inhale,...
            Table_param_wake.COV_BreathingRate,Table_param_wake.Duty_Cycle_InhalePause);
        network_table = renamevars(network_table,["Var1","Var2","Var3","Var4","Var5"],["Inhale_Duration","Rate","Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause"]);
        %rng(10)
        [trainedModel, validationRMSE] = trainRegressionModel(network_table(1:num_PD,1:5), dis_prog_rand);
        yfit = trainedModel.predictFcn(network_table(1:num_PD,1:5));
        scores_regression_PD(:,num_of_5min) = yfit;
    end

    median_regression_scores = median(scores_regression_PD,2,'omitnan');
    current_param = median_regression_scores; % scores_regression_PD(:);
    [dis_prog,k] = sort(dis_prog);
    current_param = current_param(k);
    [regression_score,~] = corr(current_param,dis_prog,'Rows','pairwise','type','Spearman');
    regression_bootstrap(bootstrap_num) = regression_score;
    disp(bootstrap_num)
end

figure;
histogram(regression_bootstrap,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.9 0.9 0.9],...
    'FaceAlpha',0.6);
%xlim([0.2 1]);

zscore_regression_bootstrap = zscore(regression_bootstrap);
zscore_regression_bootstrap_and_actual = zscore([regression_bootstrap 0.53]);
normcdf(0.53,mean(regression_bootstrap),std(regression_bootstrap));

end