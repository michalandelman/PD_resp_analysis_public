function [Table_param] = ComputeZelanoParam(AllSubjData,WSA,max_num_min)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
zscored=true;

param = {'Inhale_Volume','Exhale_Volume','Inhale_Duration','Exhale_Duration',...
    'Inhale_value','Exhale_value','Inter_breath_interval','Rate','Tidal_volume',...
    'Minute_Ventilation','Duty_Cycle_inhale','Duty_Cycle_exhale',...
    'COV_InhaleDutyCycle','COV_ExhaleDutyCycle','COV_BreathingRate',...
    'COV_InhaleVolume','COV_ExhaleVolume','Inhale_Pause_Duration',...
    'Exhale_Pause_Duration','COV_InhalePauseDutyCycle','COV_ExhalePauseDutyCycle',...
    'Duty_Cycle_InhalePause','Duty_Cycle_ExhalePause','PercentBreathsWithExhalePause',...
    'PercentBreathsWithInhalePause'};

% function to calculate mean param per participant, day and night
% open each folder in the directory
num_param = 25;
if all([zscored,strcmpi('wake',WSA)])
        means_param_wake = zeros(size(AllSubjData,2),num_param);
    elseif  all([zscored,strcmpi('sleep',WSA)])
        means_param_sleep = zeros(size(AllSubjData,2)-1,num_param);
end
for sbj=1:size(AllSubjData,2)
    SubjectName=AllSubjData(sbj).Name;
    if all([zscored,strcmpi('wake',WSA)])
        file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_zelano_wake_no_overlap_normalized.mat']);
        load([file.folder '/' file.name])
        F = @(s)any(structfun(@(a)isscalar(a)&&isnan(a),s)); % or All
        X = arrayfun(F,mat);
        mat(X) = [];
        for i = 1:num_param
            param_val = [mat.(param{i})]';
            means_param_wake(sbj,i) = mean(param_val(1:max_num_min));
        end
    elseif  all([zscored,strcmpi('sleep',WSA)])
        if ~strcmpi(SubjectName,'NC33')
            file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_zelano_sleep_no_overlap_normalized.mat']);
            load([file.folder '/' file.name])
            F = @(s)any(structfun(@(a)isscalar(a)&&isnan(a),s)); % or All
            X = arrayfun(F,mat);
            mat(X) = [];
            for i = 1:num_param
                param_val = [mat.(param{i})]';
                means_param_sleep(sbj,i) = mean(param_val(1:max_num_min));
            end
        end
    end
end

% Organize parameters in a table, for sleep and wake
if all([zscored,strcmpi('wake',WSA)])
    Table_param_wake = array2table(means_param_wake);
    Table_param_wake.Name = {AllSubjData.Name}';
    Table_param_wake.Group = {AllSubjData.Group}';
    for i = 1:num_param
        Table_param_wake = renamevars(Table_param_wake,i,param{i});
    end
    Table_param = Table_param_wake;
elseif  all([zscored,strcmpi('sleep',WSA)])
    Table_param_sleep = array2table(means_param_sleep);
    Table_param_sleep.Name = {AllSubjData.Name}';
    Table_param_sleep.Group = {AllSubjData.Group}';
    for i = 1:num_param
        Table_param_sleep = renamevars(Table_param_sleep,i,param{i});
    end
    Table_param_sleep(28,:) = []; % remove subj 'NC33' due to lack of sleep
    Table_param = Table_param_sleep;
end
end



