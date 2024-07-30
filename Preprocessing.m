%% Preprocessing of raw data file

% Step 1: Normalize the data and save in blocks of 5min (no overlap)

load('/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/NC_analysis/allAnalysisFields61.mat')
SeparateNost=true;
SaveNormPerPerson(allAnalysisFields,SeparateNost,'wake');
%Accelerometer_SaveNormPerPerson(allAnalysisFields,SeparateNost,'wake');

% Step 2: Compute Zelano features per each block
CalculateZelanoFeaturesPerBlock(allAnalysisFields,'wake');
CalculateAccPerBlock(allAnalysisFields,'wake');

% Step 3: Save zelano's features as CSV
SaveZelanoAsCSVPerPerson(allAnalysisFields,'wake');
%SaveAccAsCSVPerPerson(allAnalysisFields,'wake');