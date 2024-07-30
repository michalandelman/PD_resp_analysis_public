function CompareAccBetweenGroups()

% Define colors
[cb] = cbrewer('qual', 'Set3', 12, 'pchip'); % set colors
cl(1, :) = cb(4, :);
cl(2, :) = cb(1, :);

% Define the paths to the mat files for each group
groupControl_path = '/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/Accelerometry/Acc_Control_magnitude'; %Acc_Control_time (locations),Acc_Control_magnitude(average)
groupPD_path = '/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/Accelerometry/Acc_PD_magnitude'; %Acc_PD_time (locations), Acc_PD_magnitude(average)

% Load data for group 1
groupControl_files = dir(fullfile(groupControl_path, '*.mat')); % List all mat files in group1_path
groupControl_min_length = inf; % Initialize minimum length as infinity

groupControl_accel_data = []; % Initialize array to store acceleration data for group 1
min_length = 138; %138 = min length
for i = 1:numel(groupControl_files)
    filename = fullfile(groupControl_path, groupControl_files(i).name);
    data = load(filename);
    % Assuming the variable name containing acceleration data is 'accel_data'
    accel_data = data.mat;
    %accel_data = accel_data/1000;
    % Resize accel_data to match the shortest array
    % Calculate the minimum length
    accel_data = accel_data(1:min_length);
    %groupControl_min_length = min(groupControl_min_length, numel(accel_data));
    groupControl_accel_data = [groupControl_accel_data; accel_data'];
end

% Calculate mean acceleration for group 1
groupControl_mean_accel = mean(groupControl_accel_data,2);

% Load data for group 2
groupPD_files = dir(fullfile(groupPD_path, '*.mat')); % List all mat files in group2_path
groupPD_min_length = inf; % Initialize minimum length as infinity

groupPD_accel_data = []; % Initialize array to store acceleration data for group 2

for i = 1:numel(groupPD_files)
    filename = fullfile(groupPD_path, groupPD_files(i).name);
    data = load(filename);
    % Assuming the variable name containing acceleration data is 'accel_data'
    accel_data = data.mat;
    %accel_data = accel_data/1000; % Convert to milliG
    % Calculate the minimum length
    accel_data = accel_data(1:min_length);
    groupPD_accel_data = [groupPD_accel_data; accel_data'];
end

% Calculate mean acceleration for group 2
groupPD_mean_accel = mean(groupPD_accel_data,2);

% Compare mean accelerations between groups
[h, p] = ttest2(groupControl_mean_accel, groupPD_mean_accel);

% Display the results
disp(['Mean Acceleration Group Control: ', num2str(mean(groupControl_mean_accel))]);
disp(['Mean Acceleration Group PD: ', num2str(mean(groupPD_mean_accel))]);
disp(['p-value: ', num2str(p)]);
if p < 0.05
    disp('There is a significant difference between the mean accelerations of the two groups.');
else
    disp('There is no significant difference between the mean accelerations of the two groups.');
end

time = 1:min_length;
num_PD = size(groupPD_accel_data,1);
num_Control = size(groupControl_accel_data,1);
SEM_PD = std(groupPD_accel_data)./sqrt(num_PD);
SEM_Control = std(groupControl_accel_data)./sqrt(num_Control);

% Plot along time
fig_open()
figure;
plot(time,smoothdata(mean(groupPD_accel_data,1)),'Color',cb(4,:),'LineWidth',2)
hold on
%eb = errorbar(time,means_along_time_PD.(param),SEM_along_time_PD.(param),'LineStyle','none', 'Color', [cb(4,:) 0.8],'linewidth', 1);
plot(time,smoothdata(mean(groupControl_accel_data,1)),'Color',cb(5,:),'LineWidth',2)
%eb1 = errorbar(time,means_along_time_control.(param),SEM_along_time_control.(param),'LineStyle','none', 'Color', [cb(5,:) 0.8],'linewidth', 1);
%ylim([0 inf])
fill([time'; flipud(time')],[(smoothdata(mean(groupControl_accel_data,1))-SEM_Control)'; flipud((smoothdata(mean(groupControl_accel_data,1))+SEM_Control)')],cb(5,:),'FaceAlpha',0.2, 'linestyle', 'none');
fill([time'; flipud(time')],[(smoothdata(mean(groupPD_accel_data,1))-SEM_PD)'; flipud((smoothdata(mean(groupPD_accel_data,1))+SEM_PD)')],cb(4,:),'FaceAlpha',0.2, 'linestyle', 'none');
xlabel('Time (minutes)');
ylabel('Average acceleration');
legend('PD','Control')
ax = gca;
ax.FontSize = 36;

% Boxplot of mean differences
param_PD = mean(groupPD_accel_data,2);
param_control = mean(groupControl_accel_data,2);
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
ylabel('Acceleration (m/sec^2)','Fontsize',30);
[p_U,h_U,stats_U] = ranksum(param_PD,param_control);
Effect = meanEffectSize(param_PD,param_control,Effect="Cliff");
disp(['U test, p Bonf = ',num2str(p_U)]);
disp(stats_U);
disp(Effect);
disp(['mean PD: ',num2str(mean(param_PD)), 'mean_control:', num2str(mean(param_control))]);
disp(['STD PD: ',num2str(std(param_PD)), 'STD_control:', num2str(std(param_control))]);

end