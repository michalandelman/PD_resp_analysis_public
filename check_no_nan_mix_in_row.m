% List of CSV files
directory = '/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/data_time';
files = dir(fullfile(directory, '*.csv'));

% Specify the columns of interest
cols_of_interest = {'Duty_Cycle_inhale', 'COV_BreathingRate', 'Duty_Cycle_InhalePause'}

for i = 1:length(files)    
    disp(i)
    data = readtable([files(i).folder, '/', files(i).name]);

    % Extract columns of interest
    selected_data = data(:, cols_of_interest);

    % Check for the specified condition
    % condition_met = any(~isnan(selected_data.Duty_Cycle_inhale) & isnan(selected_data.COV_BreathingRate));

    condition_met = any(all(~isnan(selected_data{:, 1:end-1}) & isnan(selected_data{:, 2:end}), 2) & isnan(selected_data{:, end}));

end
% Display the result
if condition_met
    disp('The condition is met for at least one row.');
else
    disp('The condition is not met for any row.');
end
