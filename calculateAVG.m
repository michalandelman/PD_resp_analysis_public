% List of CSV files
directory = '/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/data_time';
files = dir(fullfile(directory, '*.csv'));

total_pd = 0;
num_of_rows_pd = 0;
total_control = 0;
num_of_rows_control = 0;

for i = 1:length(files)
    disp(['file ' num2str(i) ' started'])
    data = readtable([files(i).folder, '/', files(i).name]);

    Duty_Cycle_inhale_col = data.Duty_Cycle_inhale;
    l = length(Duty_Cycle_inhale_col);
    s = sum(Duty_Cycle_inhale_col, 'omitnan');
    num_of_rows_pd = num_of_rows_pd + l;
    total_pd = total_pd + s;
end

avg = total_pd / num_of_rows_pd;

disp(avg);