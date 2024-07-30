% Define the time points
timePoints = {'12:00', '12:05', '12:10', '12:15', '12:20', '12:30'};

% Define the list of feature names
featureNames = {'Duty_Cycle_inhale', 'COV_BreathingRate', 'Duty_Cycle_InhalePause'};

% Initialize cell arrays to store tables and results
tables = cell(1, numel(timePoints));
results = cell(1, numel(timePoints));

% List of CSV files
directory = '/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/data_time';
files = dir(fullfile(directory, '*.csv'));

for j = 1:length(files)
    fileName = files(j).name;
    filePath = [files(j).folder, '/', files(j).name];
    disp([num2str(j) ' file ' fileName ' started'])
    data = readtable(filePath);
    
    % Loop through time points
    for i = 1:numel(timePoints)
        currentTime = timePoints{i};
        
        % Extract the row for the current time point, if it exists
        matchingRows = data(strcmp(data.Time, currentTime), :);
        
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
                variableTypes = repelem({'string'}, 3 + numel(featureNames));
                variableNames = {'Name', 'Time', 'Group', featureNames{:}};
                tables{i} = table('Size', [0, 3 + numel(featureNames)], 'VariableTypes', variableTypes, ...
                    'VariableNames', variableNames);
            end
            
            % Append the row to the table for the current time point
            tables{i} = [tables{i}; row];
        end
    end
end

% Loop through the tables and call the classifier function
for i = 1:numel(timePoints)
    % Call the function trainClassifierSubspaceDiscriminant with the current table
    % Replace 'YourClassifierFunction' with the actual function name
    % results{i} = YourClassifierFunction(tables{i});
end
