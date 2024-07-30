% Specify the directory containing your CSV files
directory = '/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/data_time';

% Get a list of all CSV files in the directory
files = dir(fullfile(directory, '*.csv'));

% Initialize empty arrays to store data
time_points = [];
feature_data = [];

% Initialize a figure
figure;

% Loop through your files
for i = 1:3  % Assuming you have 60 files
    % Construct file name
    filename = files(i).name;
    
    % Read CSV file
    data = readtable([directory,'/',filename]);
    feature_columns = [data.Duty_Cycle_inhale];

    % Convert time column to datetime
    data.Time = datetime(data.Time, 'Format', 'HH:mm');
    % sort only the first column, return indices of the sort
    data = sortrows(data, 'Time');
    
    % Align time points by finding the common time vector
    if isempty(time_points)
        time_points = data.Time;
    else
        time_points = intersect(time_points, data.Time);
    end
    
    % Extract the features for the common time points
    features_at_common_times = feature_columns(ismember(time_column, time_points));
    
    % Store the features for each file
    feature_data = [feature_data, features_at_common_times];

    % Plot the data
    % hold on;  % To overlay plots on the same figure
    % plot(data.Time, feature_columns);
end

mean_data = mean(feature_data, 2);
std_data = std(feature_data, 0, 2);

% Plot the data
figure;
errorbar(time_points, mean_data, std_data, 'b', 'LineWidth', 2);
xlabel('Time');
ylabel('Mean Value');
title('Mean and STD of Features over Time');
grid on;
xlim([datetime('08:00','Format', 'HH:mm'), datetime('20:00','Format', 'HH:mm')]);

% % Customize the plot if needed (e.g., labels, title)
% xlabel('Time');
% ylabel('Feature');
% title('Combined Plot Title');
% grid on;
% xlim([datetime('08:00','Format', 'HH:mm'), datetime('20:00','Format', 'HH:mm')]);

% Add a legend for each plot
legend('File 1', 'File 2');  % Add file names accordingly