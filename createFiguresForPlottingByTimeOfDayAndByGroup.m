function createFiguresForPlottingByTimeOfDayAndByGroup(dataMap)
    % Extract keys and convert them to datetime
    keysArray = keys(dataMap);
    datetimeKeys = datetime(keysArray, 'InputFormat', 'HH:mm', 'Format', 'HH:mm');
    
    % Sort datetime keys
    [sortedDatetimeKeys, ~] = sort(datetimeKeys);
    
    % Extract values for plotting
    countPD = zeros(size(sortedDatetimeKeys));
    countControl = zeros(size(sortedDatetimeKeys));
    averageDutyCycleInhalePD = zeros(size(sortedDatetimeKeys));
    averageDutyCycleInhaleControl = zeros(size(sortedDatetimeKeys));
    stdDutyCycleInhalePD = zeros(size(sortedDatetimeKeys));
    stdDutyCycleInhaleControl = zeros(size(sortedDatetimeKeys));
    averageCOVBreathingRatePD = zeros(size(sortedDatetimeKeys));
    averageCOVBreathingRateControl = zeros(size(sortedDatetimeKeys));
    stdCOVBreathingRatePD = zeros(size(sortedDatetimeKeys));
    stdCOVBreathingRateControl = zeros(size(sortedDatetimeKeys));
    averageDutyCycleInhalePausePD = zeros(size(sortedDatetimeKeys));
    averageDutyCycleInhalePauseControl = zeros(size(sortedDatetimeKeys));
    stdDutyCycleInhalePausePD = zeros(size(sortedDatetimeKeys));
    stdDutyCycleInhalePauseControl = zeros(size(sortedDatetimeKeys));
    
    for i = 1:length(sortedDatetimeKeys)
        key = sortedDatetimeKeys(i);
        % Extract components of datetime
        keyComponents = datevec(key);
        
        % Construct the formatted key without leading zeros
        formattedKey = sprintf('%d:%02d', keyComponents(4), keyComponents(5));
        value = dataMap(char(formattedKey));
        
        countPD(i) = value.count_PD;
        countControl(i) = value.count_control;
        averageDutyCycleInhalePD(i) = value.average_Duty_Cycle_inhale_PD;
        stdDutyCycleInhalePD(i) = value.std_Duty_Cycle_inhale_PD;
        averageDutyCycleInhaleControl(i) = value.average_Duty_Cycle_inhale_control;
        stdDutyCycleInhaleControl(i) = value.std_Duty_Cycle_inhale_control;
        averageCOVBreathingRatePD(i) = value.average_COV_BreathingRate_PD;
        stdCOVBreathingRatePD(i) = value.std_COV_BreathingRate_PD;
        averageCOVBreathingRateControl(i) = value.average_COV_BreathingRate_control;
        stdCOVBreathingRateControl(i) = value.std_COV_BreathingRate_control;
        averageDutyCycleInhalePausePD(i) = value.average_Duty_Cycle_InhalePause_PD;
        stdDutyCycleInhalePausePD(i) = value.std_Duty_Cycle_InhalePause_PD;
        averageDutyCycleInhalePauseControl(i) = value.average_Duty_Cycle_InhalePause_control;
        stdDutyCycleInhalePauseControl(i) = value.std_Duty_Cycle_InhalePause_control;
        averageRatePD(i) = value.average_Rate_PD;
        stdRatePD(i) = value.std_Rate_PD;
        averageRateControl(i) = value.average_Rate_control;
        stdRateControl(i) = value.std_Rate_control;
    end
    
    % Plot the data
    % Define colors
    [cb] = cbrewer('qual', 'Set3', 12, 'pchip'); % set colors
    cl(1, :) = cb(4, :);
    cl(2, :) = cb(1, :);
    
    % Duty Cycle inhale
    figure;
    % fig_open()
    plot(sortedDatetimeKeys,smoothdata(averageDutyCycleInhalePD),'Color',cb(4,:),'LineWidth',2)
    hold on
    averageDutyCycleInhaleControlnoNan = averageDutyCycleInhaleControl;
    averageDutyCycleInhaleControlnoNan(isnan(averageDutyCycleInhaleControlnoNan))=0;
    stdDutyCycleInhaleControlnoNan = stdDutyCycleInhaleControl;
    stdDutyCycleInhaleControlnoNan(isnan(stdDutyCycleInhaleControl))=0;
    plot(sortedDatetimeKeys,smoothdata(averageDutyCycleInhaleControl),'Color',cb(5,:),'LineWidth',2)
    fill([sortedDatetimeKeys'; flipud(sortedDatetimeKeys')],...
        [(smoothdata(averageDutyCycleInhalePD)-stdDutyCycleInhalePD)'; flipud((smoothdata(averageDutyCycleInhalePD)+stdDutyCycleInhalePD)')]...
        ,cb(4,:),'FaceAlpha',0.2, 'linestyle', 'none');
    fill([sortedDatetimeKeys'; flipud(sortedDatetimeKeys')],...
        [(smoothdata(averageDutyCycleInhaleControlnoNan)-stdDutyCycleInhaleControlnoNan)';...
        flipud((smoothdata(averageDutyCycleInhaleControlnoNan)+stdDutyCycleInhaleControlnoNan)')],...
        cb(5,:),'FaceAlpha',0.2, 'linestyle', 'none');
        xlim([datetime('08:00', 'Format', 'HH:mm'), datetime('20:00', 'Format', 'HH:mm')]);
    xlabel('Time (minutes)');
    ylabel('Duty Cycle Inhale','Interpreter','none'); 
    legend('PD', 'Control');
    ax = gca;
    %ax.FontSize = 36;

    % CV Breathing rate
    figure;
    %fig_open()
    plot(sortedDatetimeKeys,smoothdata(averageCOVBreathingRatePD),'Color',cb(4,:),'LineWidth',2)
    hold on
    averageCOVBreathingRateControlnoNan = averageCOVBreathingRateControl;
    averageCOVBreathingRateControlnoNan(isnan(averageCOVBreathingRateControlnoNan))=0;
    stdCOVBreathingRateControlnoNan = stdCOVBreathingRateControl;
    stdCOVBreathingRateControlnoNan(isnan(stdCOVBreathingRateControl))=0;
    plot(sortedDatetimeKeys,smoothdata(averageCOVBreathingRateControlnoNan),'Color',cb(5,:),'LineWidth',2)
    fill([sortedDatetimeKeys'; flipud(sortedDatetimeKeys')],...
        [(smoothdata(averageCOVBreathingRatePD)-stdCOVBreathingRatePD)'; flipud((smoothdata(averageCOVBreathingRatePD)+stdCOVBreathingRatePD)')]...
        ,cb(4,:),'FaceAlpha',0.2, 'linestyle', 'none');
    fill([sortedDatetimeKeys'; flipud(sortedDatetimeKeys')],...
        [(smoothdata(averageCOVBreathingRateControlnoNan)-stdCOVBreathingRateControlnoNan)';...
        flipud((smoothdata(averageCOVBreathingRateControlnoNan)+stdCOVBreathingRateControlnoNan)')],...
        cb(5,:),'FaceAlpha',0.2, 'linestyle', 'none');
        xlim([datetime('08:00', 'Format', 'HH:mm'), datetime('20:00', 'Format', 'HH:mm')]);
    xlabel('Time (minutes)');
    ylabel('CV Breathing rate','Interpreter','none');
    legend('PD', 'Control');
    ax = gca;
    %ax.FontSize = 36;

    % Inhale pause duty cycle
    figure;
    %fig_open()
    plot(sortedDatetimeKeys,smoothdata(averageDutyCycleInhalePausePD),'Color',cb(4,:),'LineWidth',2)
    hold on
    averageDutyCycleInhalePauseControlnoNan = averageDutyCycleInhalePauseControl;
    averageDutyCycleInhalePauseControlnoNan(isnan(averageDutyCycleInhalePauseControlnoNan))=0;
    stdDutyCycleInhalePauseControlnoNan = stdDutyCycleInhalePauseControl;
    stdDutyCycleInhalePauseControlnoNan(isnan(stdDutyCycleInhalePauseControl))=0;
    plot(sortedDatetimeKeys,smoothdata(averageDutyCycleInhalePauseControlnoNan),'Color',cb(5,:),'LineWidth',2)
    fill([sortedDatetimeKeys'; flipud(sortedDatetimeKeys')],...
        [(smoothdata(averageDutyCycleInhalePausePD)-stdDutyCycleInhalePausePD)'; flipud((smoothdata(averageDutyCycleInhalePausePD)+stdDutyCycleInhalePausePD)')]...
        ,cb(4,:),'FaceAlpha',0.2, 'linestyle', 'none');
    fill([sortedDatetimeKeys'; flipud(sortedDatetimeKeys')],...
        [(smoothdata(averageDutyCycleInhalePauseControlnoNan)-stdDutyCycleInhalePauseControlnoNan)';...
        flipud((smoothdata(averageDutyCycleInhalePauseControlnoNan)+stdDutyCycleInhalePauseControlnoNan)')],...
        cb(5,:),'FaceAlpha',0.2, 'linestyle', 'none');
        xlim([datetime('08:00', 'Format', 'HH:mm'), datetime('20:00', 'Format', 'HH:mm')]);
    xlabel('Time (minutes)');
    ylabel('Duty Cycle Inhale Pause','Interpreter','none'); 
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

    % Rate
    figure;
    % fig_open()
    plot(sortedDatetimeKeys,smoothdata(averageRatePD),'Color',cb(4,:),'LineWidth',2)
    hold on
    averageRateControlnoNan = averageRateControl;
    averageRateControlnoNan(isnan(averageRateControlnoNan))=0;
    stdRateControlnoNan = stdRateControl;
    stdRateControlnoNan(isnan(stdRateControl))=0;
    plot(sortedDatetimeKeys,smoothdata(averageRateControl),'Color',cb(5,:),'LineWidth',2)
    fill([sortedDatetimeKeys'; flipud(sortedDatetimeKeys')],...
        [(smoothdata(averageRatePD)-stdRatePD)'; flipud((smoothdata(averageRatePD)+stdRatePD)')]...
        ,cb(4,:),'FaceAlpha',0.2, 'linestyle', 'none');
    fill([sortedDatetimeKeys'; flipud(sortedDatetimeKeys')],...
        [(smoothdata(averageRateControlnoNan)-stdRateControlnoNan)';...
        flipud((smoothdata(averageRateControlnoNan)+stdRateControlnoNan)')],...
        cb(5,:),'FaceAlpha',0.2, 'linestyle', 'none');
        xlim([datetime('08:00', 'Format', 'HH:mm'), datetime('20:00', 'Format', 'HH:mm')]);
    xlabel('Time (minutes)');
    ylabel('Rate','Interpreter','none'); 
    legend('PD', 'Control');
    ax = gca;
    %ax.FontSize = 36;

%% Using sub-plot

    % figure('WindowState', 'maximized');
    % % Subplot for Average Duty Cycle Inhale    
    % subplot(4, 2, 1);
    % plot(sortedDatetimeKeys, averageDutyCycleInhalePD, '-o', sortedDatetimeKeys, averageDutyCycleInhaleControl, '-o');
    % title('Average Duty Cycle Inhale for PD and Control');
    % xlabel('Time');
    % ylabel('Average Duty Cycle Inhale');
    % legend('PD', 'Control');
    % xlim([datetime('08:00', 'Format', 'HH:mm'), datetime('20:00', 'Format', 'HH:mm')]);
    % grid on;
    % 
    % % Subplot for Standard Deviation Duty Cycle Inhale
    % subplot(4, 2, 2);
    % plot(sortedDatetimeKeys, stdDutyCycleInhalePD, '-o', sortedDatetimeKeys, stdDutyCycleInhaleControl, '-o');
    % title('Standard Deviation Duty Cycle Inhale for PD and Control');
    % xlabel('Time');
    % ylabel('Std Duty Cycle Inhale');
    % legend('PD', 'Control');
    % xlim([datetime('08:00', 'Format', 'HH:mm'), datetime('20:00', 'Format', 'HH:mm')]);
    % grid on;
    % 
    % % Subplot for Average COV Breathing Rate
    % subplot(4, 2, 3);
    % plot(sortedDatetimeKeys, averageCOVBreathingRatePD, '-o', sortedDatetimeKeys, averageCOVBreathingRateControl, '-o');
    % title('Average COV Breathing Rate for PD and Control');
    % xlabel('Time');
    % ylabel('Average COV Breathing Rate');
    % legend('PD', 'Control');
    % xlim([datetime('08:00', 'Format', 'HH:mm'), datetime('20:00', 'Format', 'HH:mm')]);
    % grid on;
    % 
    % % Subplot for Standard Deviation COV Breathing Rate
    % subplot(4, 2, 4);
    % plot(sortedDatetimeKeys, stdCOVBreathingRatePD, '-o', sortedDatetimeKeys, stdCOVBreathingRateControl, '-o');
    % title('Standard Deviation COV Breathing Rate for PD and Control');
    % xlabel('Time');
    % ylabel('Std COV Breathing Rate');
    % legend('PD', 'Control');
    % xlim([datetime('08:00', 'Format', 'HH:mm'), datetime('20:00', 'Format', 'HH:mm')]);
    % grid on;
    % 
    % % Subplot for Average Duty Cycle Inhale Pause
    % subplot(4, 2, 5);
    % plot(sortedDatetimeKeys, averageDutyCycleInhalePausePD, '-o', sortedDatetimeKeys, averageDutyCycleInhalePauseControl, '-o');
    % title('Average Duty Cycle Inhale Pause for PD and Control');
    % xlabel('Time');
    % ylabel('Average Duty Cycle Inhale Pause');
    % legend('PD', 'Control');
    % xlim([datetime('08:00', 'Format', 'HH:mm'), datetime('20:00', 'Format', 'HH:mm')]);
    % grid on;
    % 
    % % Subplot for Standard Deviation Duty Cycle Inhale Pause
    % subplot(4, 2, 6);
    % plot(sortedDatetimeKeys, stdDutyCycleInhalePausePD, '-o', sortedDatetimeKeys, stdDutyCycleInhalePauseControl, '-o');
    % title('Standard Deviation Duty Cycle Inhale Pause for PD and Control');
    % xlabel('Time');
    % ylabel('Std Duty Cycle Inhale Pause');
    % legend('PD', 'Control');
    % xlim([datetime('08:00', 'Format', 'HH:mm'), datetime('20:00', 'Format', 'HH:mm')]);
    % grid on;

    % % Subplot for Count
    % subplot(4, 2, 7);
    % plot(sortedDatetimeKeys, countPD, '-o', sortedDatetimeKeys, countControl, '-o');
    % %plot(sortedDatetimeKeys, countPD+countControl, '-o');
    % title('Count of PD and Control');
    % xlabel('Time');
    % ylabel('Count');
    % legend('PD', 'Control');
    % xlim([datetime('08:00', 'Format', 'HH:mm'), datetime('20:00', 'Format', 'HH:mm')]);
    % grid on;
    % 