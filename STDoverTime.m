function [p_PD, stats_PD, p_control, stats_control] = ...
    STDoverTime(Table_for_PCA_wake_PD,Table_for_PCA_wake_control,num_PD,num_control)

%% Define colors
[cb] = cbrewer('qual', 'Set3', 12, 'pchip'); % set colors
cl(1, :) = cb(4, :);
cl(2, :) = cb(1, :);

stds_table_within_PD1 = [];
stds_table_within_PDall = [];
stds_table_within_PD2 = [];
for i = 1:num_PD
std_per_block1 = std(Table_for_PCA_wake_PD(i:28:(27*12+i),1:3)); %first half hour
std_per_block2 = std(Table_for_PCA_wake_PD(27*13+i:28:(27*24+i),1:3));
std_per_blockall = std(Table_for_PCA_wake_PD(i:28:(27*78+i),1:3)); %6.5h recording
stds_table_within_PD1 = [stds_table_within_PD1; std_per_block1];
stds_table_within_PD2 = [stds_table_within_PD2; std_per_block2];
stds_table_within_PDall = [stds_table_within_PDall; std_per_blockall];
end

stds_table_within_control1 = [];
stds_table_within_controlall = [];
stds_table_within_control2 = [];
for i = 1:num_control
std_per_block1 = std(Table_for_PCA_wake_control(i:33:(32*12+i),1:3)); %first half hour
std_per_block2 = std(Table_for_PCA_wake_control(32*13+i:33:(33*24+i),1:3));
std_per_blockall = std(Table_for_PCA_wake_control(i:33:(32*78+i),1:3));
stds_table_within_control1 = [stds_table_within_control1; std_per_block1];
stds_table_within_control2 = [stds_table_within_control2; std_per_block2];
stds_table_within_controlall = [stds_table_within_controlall; std_per_blockall]; %6.5 hours
end

stds_array_within_PD1 = table2array(stds_table_within_PD1);
stds_array_within_PDall = table2array(stds_table_within_PDall);

[h,p_PD,ci,stats_PD] = ttest(stds_array_within_PD1(:),stds_array_within_PDall(:));

figure; 
s = scatter(stds_array_within_PD1(:),stds_array_within_PDall(:),100,cb(4,:),'filled');
s.MarkerEdgeColor = 'w';
xlim([0 0.7])
ylim([0 0.7])
refline(1)
ax = gca;
ax.FontSize = 24;
xlabel('std during first half hour')
ylabel('std during 6.5 hours')
title('PD')

stds_array_within_control1 = table2array(stds_table_within_control1);
stds_array_within_controlall = table2array(stds_table_within_controlall);

[h,p_control,ci,stats_control] = ttest(stds_array_within_control1(:),stds_array_within_controlall(:));

figure; 
s = scatter(stds_array_within_control1(:),stds_array_within_controlall(:),100,cb(5,:),'filled');
s.MarkerEdgeColor = 'w';
refline(1)
ax = gca;
ax.FontSize = 24;
xlim([0 0.7])
ylim([0 0.7])
xlabel('std during first half hour')
ylabel('std during 6.5 hours')
title('control')

end