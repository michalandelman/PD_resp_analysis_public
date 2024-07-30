% Initialize the map
dataMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

% List of CSV files
directory = '/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/data_time';
files = dir(fullfile(directory, '*.csv'));

% List of feature names
featureNames = {'Duty_Cycle_inhale', 'COV_BreathingRate', 'Duty_Cycle_InhalePause','Rate'};

for i = 1:length(files)
    disp([num2str(i) ' file ' files(i).name ' started'])
    data = readtable([files(i).folder, '/', files(i).name]);

    for j = 1:length(data.Time)
        currentTime = data.Time{j};
        group = data.Group(j); % Assuming the group information is in the 'Group' column
        
        % Initialize a structure to hold feature values
        featureValues = struct();
        
        % Loop through feature names and extract values
        for k = 1:length(featureNames)
            featureName = featureNames{k};
            featureValues.(featureName) = data.(featureName)(j);
        end
        
        % Call the reusable function to update the map
        updateMapGroups(dataMap, currentTime, featureNames, struct2array(featureValues), group);
    end
end

calculateAndSetAvgAndStd(dataMap, featureNames);

% Display the map
disp(['Time   Count_PD   AvgDutyCycleInhale_PD   stdDutyCycleInhale_PD   AvgCovBreathingRate_PD   stdCovBreathingRate_PD   AvgDutyCycleInhalePause_PD   stdDutyCycleInhalePause_PD AvgRate_PD stdRate_PD' ...
    '   Count_control   AvgDutyCycleInhale_control   stdDutyCycleInhale_control   AvgCovBreathingRate_control   stdCovBreathingRate_control   AvgDutyCycleInhalePause_control   stdDutyCycleInhalePause_control AvgRate_control stdRate_control']);
keysArray = keys(dataMap);
for k = 1:length(keysArray)
    key = keysArray{k};
    value = dataMap(key);
    fprintf('%s   %d   %.3f   %.3f   %.3f   %d   %.3f   %.3f   %.3f\n', key, ...
        value.count_PD, value.average_Duty_Cycle_inhale_PD, value.std_Duty_Cycle_inhale_PD, value.average_COV_BreathingRate_PD, value.std_COV_BreathingRate_PD, value.average_Duty_Cycle_InhalePause_PD, value.std_Duty_Cycle_InhalePause_PD, value.average_Rate_PD, value.std_Rate_PD,...
        value.count_control, value.average_Duty_Cycle_inhale_control, value.std_Duty_Cycle_inhale_control, value.average_COV_BreathingRate_control, value.std_COV_BreathingRate_control, value.average_Duty_Cycle_InhalePause_control, value.std_Duty_Cycle_InhalePause_control, value.average_Rate_control, value.std_Rate_control);
end

createFiguresForPlottingByTimeOfDayAndByGroup(dataMap)
