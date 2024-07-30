function createFiguresForPlottingByTimeOfDayAndByGroupAcceleration(dataMap)
    % Extract keys and convert them to datetime
    keysArray = keys(dataMap);
    datetimeKeys = datetime(keysArray, 'InputFormat', 'HH:mm', 'Format', 'HH:mm');
    
    % Sort datetime keys
    [sortedDatetimeKeys, ~] = sort(datetimeKeys);
    % Remove NaT values
    sortedDatetimeKeys = sortedDatetimeKeys(~isnat(sortedDatetimeKeys));
    % Extract values for plotting
    countPD = zeros(size(sortedDatetimeKeys));
    countControl = zeros(size(sortedDatetimeKeys));
    averageAccelerationPD = zeros(size(sortedDatetimeKeys));
    averageAccelerationControl = zeros(size(sortedDatetimeKeys));
    stdAccelerationPD = zeros(size(sortedDatetimeKeys));
    stdAccelerationControl = zeros(size(sortedDatetimeKeys));
    
    for i = 1:length(sortedDatetimeKeys)
        key = sortedDatetimeKeys(i);
        % Extract components of datetime
        keyComponents = datevec(key);
        
        % Construct the formatted key without leading zeros
        formattedKey = sprintf('%d:%02d', keyComponents(4), keyComponents(5));
        value = dataMap(char(formattedKey));
        
        countPD(i) = value.count_PD;
        countControl(i) = value.count_control;
        averageAccelerationPD(i) = value.average_Acceleration_PD;
        stdAccelerationPD(i) = value.std_Acceleration_PD;
        averageAccelerationControl(i) = value.average_Acceleration_control;
        stdAccelerationControl(i) = value.std_Acceleration_control;
    end
    
    % Plot the data
    % Define colors
    [cb] = cbrewer('qual', 'Set3', 12, 'pchip'); % set colors
    cl(1, :) = cb(4, :);
    cl(2, :) = cb(1, :);
    
    % Average Acceleration
    averageAccelerationControlnoNan = averageAccelerationControl;
    averageAccelerationControlnoNan(isnan(averageAccelerationControlnoNan))=0;
    stdAccelerationControlnoNan = stdAccelerationControl;
    stdAccelerationControlnoNan(isnan(stdAccelerationControl))=0;
    averageAccelerationPDnoNan = averageAccelerationPD;
    averageAccelerationPDnoNan(isnan(averageAccelerationPDnoNan))=0;
    stdAccelerationPDnoNan = stdAccelerationPD;
    stdAccelerationPDnoNan(isnan(stdAccelerationPD))=0;
    figure;
    % fig_open()
    plot(sortedDatetimeKeys,smoothdata(averageAccelerationPDnoNan),'Color',cb(4,:),'LineWidth',2)
    hold on
    plot(sortedDatetimeKeys,smoothdata(averageAccelerationControlnoNan),'Color',cb(5,:),'LineWidth',2)
    fill([sortedDatetimeKeys'; flipud(sortedDatetimeKeys')],...
        [(smoothdata(averageAccelerationPDnoNan)-stdAccelerationPDnoNan)'; ...
        flipud((smoothdata(averageAccelerationPDnoNan)+stdAccelerationPDnoNan)')]...
        ,cb(4,:),'FaceAlpha',0.2, 'linestyle', 'none');
    fill([sortedDatetimeKeys'; flipud(sortedDatetimeKeys')],...
        [(smoothdata(averageAccelerationControlnoNan)-stdAccelerationControlnoNan)';...
        flipud((smoothdata(averageAccelerationControlnoNan)+stdAccelerationControlnoNan)')],...
        cb(5,:),'FaceAlpha',0.2, 'linestyle', 'none');
        xlim([datetime('08:00', 'Format', 'HH:mm'), datetime('20:00', 'Format', 'HH:mm')]);
    xlabel('Time (minutes)');
    ylabel('Average Acceleration','Interpreter','none');
    legend('PD', 'Control');
    ax = gca;
    %ax.FontSize = 36;

    % count - histogram stacked
    figure;
    bar(sortedDatetimeKeys, countControl,'BarWidth', 1.5,'FaceColor', cb(5,:),'FaceAlpha', 0.5)
    hold on
    bar(sortedDatetimeKeys, countPD,'BarWidth', 1.5,'FaceColor', cb(4,:),'FaceAlpha', 0.5)
    title('Count of PD and Control');
    xlabel('Time');
    ylabel('Count PD');
    legend('Control','PD');
    xlim([datetime('08:00', 'Format', 'HH:mm'), datetime('20:00', 'Format', 'HH:mm')]);
