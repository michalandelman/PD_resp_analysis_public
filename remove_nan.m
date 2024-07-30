% remove NaN from table

load('/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/NC_analysis/allAnalysisFields61.mat')
AllSubjData = allAnalysisFields;
WSA='wake';
zscored=true;

for sbj=1:size(AllSubjData,2)
    SubjectName=AllSubjData(sbj).Name;
    if all([zscored,strcmpi('wake',WSA)])
        file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_zelano_wake_no_overlap_normalized.mat']);
        load([file.folder '/' file.name])
        F = @(s)any(structfun(@(a)isscalar(a)&&isnan(a),s)); % or ANY
        X = arrayfun(F,mat);
        mat(X) = [];
    elseif  all([zscored,strcmpi('sleep',WSA)])
        file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_zelano_sleep_no_overlap_normalized.mat']);
        load([file.folder '/' file.name])
    end
end