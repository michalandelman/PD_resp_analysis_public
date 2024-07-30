function [AUC_all] = ...
    AUCLongitudinal(AllSubjData,max_num_of_5min,num_PD,num_control,WSA,num_param,param)

zscored = true;
if all([zscored,strcmpi('wake',WSA)])
    mean_total_scores_per_block = zeros(num_PD+num_control,max_num_of_5min);
elseif all([zscored,strcmpi('sleep',WSA)])
    mean_total_scores_per_block = zeros(num_PD+num_control-1,max_num_of_5min);
end

if all([zscored,strcmpi('wake',WSA)])
    for num_of_block = 1:max_num_of_5min
        total_scores = zeros((num_PD+num_control),num_of_block);
        yfit_PD = cell((num_PD+num_control),num_of_block);
        for num_of_5min = 1:num_of_block
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
                % Table_param_wake.COV_BreathingRate,Table_param_wake.Duty_Cycle_InhalePause, Table_param_wake.Group);
            % network_table = renamevars(network_table,["Var1","Var2","Var3","Var4","Var5","Var6"],["Inhale_Duration","Rate","Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause","Group"]);
            network_table = table(Table_param_wake.Duty_Cycle_inhale,...
                Table_param_wake.COV_BreathingRate,Table_param_wake.Duty_Cycle_InhalePause, Table_param_wake.Group);
            network_table = renamevars(network_table,["Var1","Var2","Var3","Var4"],["Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause","Group"]);   
            Y_Group = network_table.Group;
            rng(10)
            [validationPredictions, validationScores,~, ~] = trainClassifierSubspaceDiscriminant(network_table);
            % [yfit,scores] = trainedClassifier.predictFcn(network_table);
            scores_PD = validationScores(:,1);
            total_scores(:,num_of_5min) = scores_PD;
            yfit_PD(:,num_of_5min) = validationPredictions;
        end
        mean_total_scores_per_block(:,num_of_block) = mean(total_scores,2);
        disp(num_of_block);
    end

    for i = 1:size(mean_total_scores_per_block,2)
        scores_current_block = mean_total_scores_per_block(:,i);
        [X,Y,T,AUC] = perfcurve(Y_Group,scores_current_block,'PD');
        AUC_all(i) = AUC;
        % scores_PD = scores_current_block(1:num_PD);
        % scores_control = scores_current_block(num_PD+1:num_PD+num_control);
        % acc_PD = length(find(scores_PD>0.5))/num_PD;
        % acc_control = length(find(scores_control<0.5))/num_control;
        % total_acc(i) = (length(find(scores_PD>0.5)) + length(find(scores_control<0.5))) / (num_PD+num_control);
    end

elseif all([zscored,strcmpi('sleep',WSA)])
    % Mean score wins
    mean_total_scores_per_block = zeros(size(AllSubjData,2)-1,max_num_of_5min);
    for num_of_block = 1:max_num_of_5min
        total_scores = zeros(size(AllSubjData,2)-1,num_of_block);
        yfit_PD = cell(size(AllSubjData,2)-1,num_of_block);
        for num_of_5min = 1:num_of_block
            for sbj=1:size(AllSubjData,2)
                SubjectName=AllSubjData(sbj).Name;
                if ~strcmp('NC33',SubjectName)
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
            % network_table = table(Table_param_sleep.Inhale_Duration,Table_param_sleep.Rate,Table_param_sleep.Duty_Cycle_inhale,...
            %     Table_param_sleep.COV_BreathingRate,Table_param_sleep.Duty_Cycle_InhalePause, Table_param_sleep.Group);
            % network_table = renamevars(network_table,["Var1","Var2","Var3","Var4","Var5","Var6"],["Inhale_Duration","Rate","Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause","Group"]);
            network_table = table(Table_param_sleep.Duty_Cycle_inhale,...
                Table_param_sleep.COV_BreathingRate,Table_param_sleep.Duty_Cycle_InhalePause, Table_param_sleep.Group);
            network_table = renamevars(network_table,["Var1","Var2","Var3","Var4"],["Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause","Group"]);   
            Y_Group = network_table.Group;
            rng(10)
            [validationPredictions, validationScores,~, ~] = trainClassifierSubspaceDiscriminant(network_table);
            % [yfit,scores] = trainedClassifier.predictFcn(network_table);
            scores_PD = validationScores(:,1);
            total_scores(:,num_of_5min) = scores_PD;
            yfit_PD(:,num_of_5min) = validationPredictions;
        end
        mean_total_scores_per_block(:,num_of_block) = mean(total_scores,2);
        disp(num_of_block);
    end

    %num_PD = 27;
    for i = 1:size(mean_total_scores_per_block,2)
        scores_current_block = mean_total_scores_per_block(:,i);
        [X,Y,T,AUC] = perfcurve(Y_Group,scores_current_block,'PD');
        AUC_all(i) = AUC;
        % scores_PD = scores_current_block(1:num_PD);
        % scores_control = scores_current_block(num_PD+1:num_PD+num_control);
        % acc_PD = length(find(scores_PD>0.5))/num_PD;
        % acc_control = length(find(scores_control<0.5))/num_control;
        % total_acc(i) = (length(find(scores_PD>0.5)) + length(find(scores_control<0.5))) / (num_PD+num_control);
    end
end

% plot
time = 5:5:5*max_num_of_5min;
fig_open()
figure;
plot(time,AUC_all,'LineWidth',2);
ylim([0 1])
xlabel('Time (minutes)');
ylabel('Accuracy (%)');
ax = gca;
ax.FontSize = 36;

end