% Initialize the map
dataMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

% List of CSV files
directory = '/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/data_time';
files = dir(fullfile(directory, '*.csv'));

% List of feature names
featureNames = {'Duty_Cycle_inhale', 'COV_BreathingRate', 'Duty_Cycle_InhalePause'};

for i = 1:length(files)
    disp(['file ' num2str(i) ' started'])
    data = readtable([files(i).folder, '/', files(i).name]);
    timeStrings = cellstr(data.Time);

    for j = 1:length(timeStrings)
        currentTime = timeStrings{j};
        % Initialize a structure to hold feature values
        featureValues = struct();
        
        % Loop through feature names and extract values
        for k = 1:length(featureNames)
            featureName = featureNames{k};
            featureValues.(featureName) = data.(featureName)(j);
        end
        updateMap2(dataMap, currentTime, featureNames, struct2array(featureValues));
    end
end

% Display the map
disp('Time   Count   AvgDutyCycleInhale   AvgCovBreathingRate   AvgDutyCycleInhalePause');
keysArray = keys(dataMap);
for k = 1:length(keysArray)
    key = keysArray{k};
    value = dataMap(key);
    fprintf('%s   %d   %.3f   %.3f   %.3f\n', key, value.count, ...
        value.average_Duty_Cycle_inhale, value.average_COV_BreathingRate, value.average_Duty_Cycle_InhalePause);
end
