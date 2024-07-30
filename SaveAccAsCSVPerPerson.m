function SaveAccAsCSVPerPerson(AllSubjData,WSA)

zscored=true;

for sbj=1:size(AllSubjData,2)
    SubjectName=AllSubjData(sbj).Name;
    if all([zscored,strcmpi('wake',WSA)])
        file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_average_acc_over_timewake_5min_no_overlap.mat']);
        load([file.folder '/' file.name])
        T.Acceleration = mat';
        T.Group = repmat(labels(1),1,length(mat))';
        T1 = struct2table(T);
        if ~exist(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_Acc_wake.csv'],'file')
            filename = ['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_Acc_wake.csv'];
            writetable(T1,filename);
        end
    elseif  all([zscored,strcmpi('sleep',WSA)])
        file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_average_acc_over_timewake_5min_no_overlap.mat']);
        load([file.folder '/' file.name])
        T = struct2table(mat);
        T.Group = labels;
        if ~exist(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_Acc_sleep.csv'],'file')
            filename = ['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_Acc_sleep.csv'];
            writetable(T,filename);
        end
    end
end

end