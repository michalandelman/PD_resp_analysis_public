% Define the start and end times
startTime = datetime('10:00', 'Format', 'HH:mm'); %12:00-15:30
endTime = datetime('20:00', 'Format', 'HH:mm');

% Define the time interval
timeInterval = minutes(5);

timeSegments = startTime:timeInterval:endTime;
numOftimeSegments = numel(timeSegments);

% Initialize cell arrays to store tables and results
tables = cell(1, numel(timeSegments));
results = cell(1, numel(timeSegments));

% List of CSV files
directory = '/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/data_time';
files = dir(fullfile(directory, '*.csv'));

% Define the list of feature names
featureNames = {'Duty_Cycle_inhale', 'COV_BreathingRate', 'Duty_Cycle_InhalePause'};

for j = 1:length(files)
    fileName = files(j).name;
    filePath = [files(j).folder, '/', files(j).name];
    logger([num2str(j) ' file ' fileName ' started'])
    data = readtable(filePath);
    
    % Loop through time intervals
    for i = 1:numOftimeSegments
        currentTime = timeSegments(i);
        currentTimeStr = string(currentTime);
        
        % Extract the row for the current time point, if it exists
        matchingRows = data(strcmp(data.Time, currentTimeStr), :);
        
        % Check if there are matching rows
        if ~isempty(matchingRows)
            % Select the first matching row
            row = matchingRows(1, {'Time', 'Group'}); % Initialize with 'Time', 'Group'
            
            % Add 'Name' column
            splittedFileName = split(fileName, '_');
            row.Name = splittedFileName{1};
            
            % Extract only the specified features
            for k = 1:numel(featureNames)
                featureName = featureNames{k};
                row.(featureName) = matchingRows.(featureName)(1);
            end
            
            % If the table for the current time point doesn't exist, create it
            if isempty(tables{i})
                variableTypes = repelem({'string', 'double'}, [3, numel(featureNames)]);
                variableNames = [{'Name'}, {'Time'}, {'Group'}, featureNames(:)'];
                tables{i} = table('Size', [0, 3 + numel(featureNames)], 'VariableTypes', variableTypes, ...
                    'VariableNames', variableNames);
            end
            
            % Append the row to the table for the current time point
            tables{i} = [tables{i}; row];
        end
    end
end

% Initialize subjectResults table
subjectResults = table('Size', [length(files), 2], 'VariableTypes', {'string', 'string'}, ...
    'VariableNames', {'Name', 'Group'});
subjectNames = arrayfun(@getSubjectName, files, 'UniformOutput', false);
subjectResults.Name = string(subjectNames);
subjectResults.Group = categorical(...
    cellfun(@(name) contains(name, 'H'), subjectResults.Name),...
    [0, 1],...
    {'PD', 'control'}...
);

for i = 1:numel(timeSegments)
    currentTime = timeSegments(i);
    currentTimeStr = string(currentTime);
    logger(['Working on time segment ' currentTimeStr]);
    logger('Preparing data for prediction');
    currentTable = tables{i};
    
    % Identify rows with no NaN values in feature columns
    validRows = ~any(isnan(currentTable{:, featureNames}), 2);
    
    % Extract valid subject names from the Time column
    currentValidSubjectNames = currentTable.Name(validRows);
    
    % Extract sub table of "Group" and selected features cols only for the valid subjects
    trainingData = currentTable(...
        ismember(currentTable.Name, currentValidSubjectNames),...
        [{'Group'}, featureNames(:)']...
    );    

    % Get predictions
    logger('Predicting...');
    [~, validationScores, ~] = trainClassifierSubspaceDiscriminant(trainingData);
    predictions = validationScores(:,1);
    logger('Done!');
    % Loop through valid subject names and insert predictions in subjectResults
    for j = 1:length(currentValidSubjectNames)
        subjectName = currentValidSubjectNames{j};

        % Find the row index in subjectResults corresponding to the current subjectName
        rowIndex = find(subjectResults.Name == subjectName);

        % Assign the prediction to the correct place in subjectResults
        subjectResults.(currentTimeStr)(rowIndex) = predictions(j);
    end
end

% Convert 0 values to NaN values
subjectResultsData = table2array(subjectResults(:, 3:end));
subjectResultsData(subjectResultsData == 0) = NaN;
subjectResults(:, 3:end) = array2table(subjectResultsData);
% 
for i = 1:43
    mean_scores = mean(table2array(subjectResults(:, 2+i:4+i)),2,'omitnan');
    length(find(mean_scores(1:28)<0.5))
end

% Count NaN
nanCount = sum(isnan(table2array(subjectResults(1:28,3:end))));

% end-12:end-10,31:33 -> 6 misclassified PD, 6 misclassified Ctrl (balanced
% missing values between the groups)
% for i = 15:32
%     mean_scores = mean(table2array(subjectResults(:, i:end-10)),2,'omitnan');
%     length(find(mean_scores(1:28)<0.5))
%     length(find(mean_scores(29:end)>0.5))
% end

mean_scores = mean(table2array(subjectResults(:, 3:end)),2,'omitnan');
length(find(mean_scores(1:28)<0.5))
length(find(mean_scores(29:end)>0.5))
