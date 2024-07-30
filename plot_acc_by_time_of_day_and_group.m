% Initialize the map
dataMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

% List of CSV files
directory = '/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/data_time/Acc_by_time_of_day';
files = dir(fullfile(directory, '*.csv'));

% List of feature names
featureNames = {'Acceleration'};

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
        skipFeatureCheck = true;
        updateMapGroups(dataMap, currentTime, featureNames, struct2array(featureValues), group, skipFeatureCheck);
    end
end

calculateAndSetAvgAndStd(dataMap, featureNames);

% Display the map
disp(['Time   Count_PD   AvgAcceleration_PD   stdAcceleration_PD   ' ...
    '   Count_control   AvgAcceleration_control   stdAcceleration_control']);
keysArray = keys(dataMap);
for k = 1:length(keysArray)
    key = keysArray{k};
    value = dataMap(key);
    fprintf('%s   %d   %.3f   %.3f   %.3f   %d   %.3f   %.3f   %.3f', key, ...
        value.count_PD, value.average_Acceleration_PD, value.std_Acceleration_PD,...
        value.count_control, value.average_Acceleration_control, value.std_Acceleration_control);
    fprintf('\n');
end

createFiguresForPlottingByTimeOfDayAndByGroupAcceleration(dataMap)
