function ChosenParamAlongTime(max_num_of_5min,AllSubjData,num_param,param,num_PD,num_control)

% Define colors
[cb] = cbrewer('qual', 'Set3', 12, 'pchip'); % set colors
cl(1, :) = cb(4, :);
cl(2, :) = cb(1, :);

means_along_time_control = [];
SEM_along_time_control = [];
means_along_time_PD = [];
SEM_along_time_PD = [];

for num_of_block = 1:max_num_of_5min
    for sbj=1:size(AllSubjData,2)
        SubjectName=AllSubjData(sbj).Name;
        file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_zelano_wake_no_overlap_normalized.mat']);
        load([file.folder '/' file.name])
        F = @(s)any(structfun(@(a)isscalar(a)&&isnan(a),s)); % or All
        X = arrayfun(F,mat);
        mat(X) = [];
        for i = 1:num_param
            param_val = [mat.(param{i})]';
            means_param_wake(sbj,i) = param_val(num_of_block);
        end
    end
    Table_param_wake = array2table(means_param_wake);
    Table_param_wake.Name = {AllSubjData.Name}';
    Table_param_wake.Group = {AllSubjData.Group}';
    for i = 1:num_param
        Table_param_wake = renamevars(Table_param_wake,i,param{i});
    end
    network_table = Table_param_wake;
    % network_table = table(Table_param_wake.Duty_Cycle_inhale,...
    %     Table_param_wake.COV_BreathingRate,Table_param_wake.Duty_Cycle_InhalePause, Table_param_wake.Group);
    % network_table = renamevars(network_table,["Var1","Var2","Var3","Var4"],["Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause","Group"]);
    % calculate mean and std per parameter per block
    Table_param_wake_control = network_table(strcmp(network_table.Group, 'control'), :);
    means_control_per_block = mean(Table_param_wake_control(:,1:25));
    means_along_time_control(num_of_block,:) = table2array(means_control_per_block);
    SEM_control_per_block = std(Table_param_wake_control(:,1:25))./sqrt(num_control);
    SEM_along_time_control(num_of_block,:) = table2array(SEM_control_per_block);
    Table_param_wake_PD = network_table(strcmp(network_table.Group, 'PD'), :);
    means_PD_per_block = mean(Table_param_wake_PD(:,1:25));
    means_along_time_PD(num_of_block,:) = table2array(means_PD_per_block);
    SEM_PD_per_block = std(Table_param_wake_PD(:,1:25))./sqrt(num_PD);
    SEM_along_time_PD(num_of_block,:) = table2array(SEM_PD_per_block);
    %disp(num_of_block);
end

% plot
chosen_param = {'Inhale_Volume','Exhale_Volume','Inhale_Duration','Exhale_Duration',...
    'Inhale_value','Exhale_value','Inter_breath_interval','Rate','Tidal_volume',...
    'Minute_Ventilation','Duty_Cycle_inhale','Duty_Cycle_exhale',...
    'COV_InhaleDutyCycle','COV_ExhaleDutyCycle','COV_BreathingRate',...
    'COV_InhaleVolume','COV_ExhaleVolume','Inhale_Pause_Duration',...
    'Exhale_Pause_Duration','COV_InhalePauseDutyCycle','COV_ExhalePauseDutyCycle',...
    'Duty_Cycle_InhalePause','Duty_Cycle_ExhalePause','PercentBreathsWithExhalePause',...
    'PercentBreathsWithInhalePause'};
% chosen_param = {'Duty_Cycle_inhale','COV_BreathingRate','Duty_Cycle_InhalePause'};
for i = 1:25
    param = chosen_param{i};
    time = 5:5:max_num_of_5min*5;
    fig_open()
    figure;
    fill([time'; flipud(time')],[smoothdata(means_along_time_PD(:,i))-SEM_along_time_PD(:,i);flipud(smoothdata(means_along_time_PD(:,i))+SEM_along_time_PD(:,i))],cb(4,:),'FaceAlpha',0.2, 'linestyle', 'none');
    hold on
    plot(time,smoothdata(means_along_time_PD(:,i)),'Color',cb(4,:),'LineWidth',2)
    %eb = errorbar(time,means_along_time_PD.(param),SEM_along_time_PD.(param),'LineStyle','none', 'Color', [cb(4,:) 0.8],'linewidth', 1);
    fill([time'; flipud(time')],[smoothdata(means_along_time_control(:,i))-SEM_along_time_control(:,i);flipud(smoothdata(means_along_time_control(:,i))+SEM_along_time_control(:,i))],cb(5,:),'FaceAlpha',0.2, 'linestyle', 'none');
    plot(time,smoothdata(means_along_time_control(:,i)),'Color',cb(5,:),'LineWidth',2)
    %eb1 = errorbar(time,means_along_time_control.(param),SEM_along_time_control.(param),'LineStyle','none', 'Color', [cb(5,:) 0.8],'linewidth', 1);
    %ylim([0 inf])
    xlabel('Time (minutes)');
    ylabel(param,'Interpreter','none');
    ax = gca;
    ax.FontSize = 36;
end

end