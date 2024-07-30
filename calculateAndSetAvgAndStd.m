function calculateAndSetAvgAndStd(dataMap, featureNames)
    % Get all the keys (time entries) in the dataMap
    keys = dataMap.keys;

    for i = 1:length(keys)
        currentTime = keys{i};
        currentData = dataMap(currentTime);

        for k = 1:length(featureNames)
            featureName = featureNames{k};
            
            % Build field names dynamically
            pdRawField = ['raw_' featureName '_PD'];
            controlRawField = ['raw_' featureName '_control'];
            
            % Calculate average and std for PD group
            pdRawData = currentData.(pdRawField);
            averagePD = mean(pdRawData);
            stdPD = std(pdRawData) / sqrt(length(pdRawData));
            
            % Calculate average and std for control group
            controlRawData = currentData.(controlRawField);
            averageControl = mean(controlRawData);
            stdControl = std(controlRawData) / sqrt(length(controlRawData));
            
            % Update the dataMap entry with calculated values
            currentData.(['average_' featureName '_PD']) = averagePD;
            currentData.(['std_' featureName '_PD']) = stdPD;
            currentData.(['average_' featureName '_control']) = averageControl;
            currentData.(['std_' featureName '_control']) = stdControl;
        end
        
        % Update the dataMap with the modified entry
        dataMap(currentTime) = currentData;
    end
end
