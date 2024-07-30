function updateMap(dataMap, currentTime, featureNames, featureValues)
    % Check for NaN values in feature columns
    nanIndices = isnan(featureValues);
    
    % Skip if any of the feature values is NaN
    if any(nanIndices)
        return;
    end
    
    if isKey(dataMap, currentTime)
        % Update count and averages
        currentData = dataMap(currentTime);
        count = currentData.count + 1;

        % Update averages for each feature
        for k = 1:length(featureNames)
            featureName = featureNames{k};
            averageFeature = (currentData.(['average' featureName]) * currentData.count + featureValues(k)) / count;
            currentData.(['average' featureName]) = averageFeature;
        end

        dataMap(currentTime) = currentData;
    else
        % Add new entry
        count = 1;
        
        % Initialize structure for the new entry
        newEntry = struct('count', count);
        
        % Set initial values for each feature
        for k = 1:length(featureNames)
            featureName = featureNames{k};
            newEntry.(['average' featureName]) = featureValues(k);
        end
        
        dataMap(currentTime) = newEntry;
    end
end

% Initialize the map
dataMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

% List of CSV files
fileList = {'file1.csv', 'file2.csv', 'file3.csv'}; % Add your file names

% List of feature names
featureNames = {'Duty_Cycle_inhale', 'COV_BreathingRate', 'Duty_Cycle_InhalePause'};

for i = 1:length(fileList)
    % Read CSV file
    data = readtable(fileList{i});
    
    % Convert time column to cell array of strings
    timeStrings = cellstr(data.Time);
    
    % Loop through each row and update the map
    for j = 1:length(timeStrings)
        currentTime = timeStrings{j};
        featureValues = [data.Duty_Cycle_inhale(j), data.COV_BreathingRate(j), data.Duty_Cycle_InhalePause(j)];
        
        % Call the reusable function to update the map
        updateMap(dataMap, currentTime, featureNames, featureValues);
    end
end

% Display the map
disp('Time   Count   AvgDutyCycleInhale   AvgCovBreathingRate   AvgDutyCycleInhalePause');
keysArray = keys(dataMap);
for k = 1:length(keysArray)
    key = keysArray{k};
    value = dataMap(key);
    fprintf('%s   %d   %.3f   %.3f   %.3f\n', key, value.count, ...
        value.averageDuty_Cycle_inhale, value.averageCOV_BreathingRate, value.averageDuty_Cycle_InhalePause);
end
