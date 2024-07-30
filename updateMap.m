function updateMap(dataMap, currentTime, featureNames, featureValues)
    % Check for NaN values in feature columns
    nanIndices = isnan(featureValues);
    
    % Skip if any of the feature values is NaN
    if any(nanIndices)
        return;
    end
    
    if isKey(dataMap, currentTime)
        currentData = dataMap(currentTime);
        count = currentData.count + 1;

        % Update averages for each feature
        for k = 1:length(featureNames)
            featureName = featureNames{k};
            averageFeature = (currentData.(['average_' featureName]) * currentData.count + featureValues(k)) / count;
            currentData.(['average_' featureName]) = averageFeature;
            currentData.count = count;
        end

        dataMap(currentTime) = currentData;
    else
        % Add new entry
        newEntry = struct('count', 1);        
        % Set initial values for each feature
        for k = 1:length(featureNames)
            featureName = featureNames{k};
            newEntry.(['average_' featureName]) = featureValues(k);
        end
        
        dataMap(currentTime) = newEntry;
    end
end
