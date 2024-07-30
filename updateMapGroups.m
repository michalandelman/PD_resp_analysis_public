function updateMapGroups(dataMap, currentTime, featureNames, featureValues, group, skipFeatureCheck)
    % Check for NaN values in feature columns
    nanIndices = isnan(featureValues);
    
    % Skip if any of the feature values is NaN
    if any(nanIndices)
        return;
    end

    if nargin < 6 || ~skipFeatureCheck
        if any(featureValues > 1)
            return
        end
    end
    
    % Create time entry if not present
    if ~isKey(dataMap, currentTime)
        dataMap(currentTime) = createGroupEntry(featureNames);
    end
    
    % Update counts, averages, and raw data for the specific group
    updateGroupEntry(dataMap, currentTime, featureNames, featureValues, group);
end

function entry = createGroupEntry(featureNames)
    entry = struct('count_PD', 0, 'count_control', 0);
    
    % Initialize raw data fields with empty arrays
    for k = 1:length(featureNames)
        featureName = featureNames{k};
        entry.(['raw_' featureName '_PD']) = [];
        entry.(['raw_' featureName '_control']) = [];
        entry.(['average_' featureName '_PD']) = 0;
        entry.(['std_' featureName '_PD']) = 0;
        entry.(['average_' featureName '_control']) = 0;
        entry.(['std_' featureName '_control']) = 0;
    end
end

function updateGroupEntry(dataMap, currentTime, featureNames, featureValues, group)
    currentData = dataMap(currentTime);
    
    % Determine the appropriate field names based on the group
    countField = string(strjoin(['count_' group], ''));
    count = currentData.(countField) + 1;

    for k = 1:length(featureNames)
        featureName = featureNames{k};
        rawField = string(strjoin(['raw_' featureName '_' group], ''));

        % Append value to raw data
        currentData.(rawField) = [currentData.(rawField), featureValues(k)];
    end
    currentData.(countField) = count;
    dataMap(currentTime) = currentData;
end
