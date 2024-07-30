function [recording_length] = RecodingLength(AllSubjData,WSA)

zscored = true;
if all([zscored,strcmpi('wake',WSA)])
    for sbj=1:size(AllSubjData,2)
        SubjectName=AllSubjData(sbj).Name;
        file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_zelano_wake_no_overlap_normalized.mat']);
        load([file.folder '/' file.name])
        F = @(s)any(structfun(@(a)isscalar(a)&&isnan(a),s)); % or All
        X = arrayfun(F,mat);
        mat(X) = [];
        recording_length(sbj) = size(mat,2);
    end
elseif all([zscored,strcmpi('sleep',WSA)])
    for sbj=1:size(AllSubjData,2)
        SubjectName=AllSubjData(sbj).Name;
        if ~strcmp('NC33',SubjectName)
            file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/' SubjectName '_zelano_sleep_no_overlap_normalized.mat']);
            load([file.folder '/' file.name])
            F = @(s)any(structfun(@(a)isscalar(a)&&isnan(a),s)); % or All
            X = arrayfun(F,mat);
            mat(X) = [];
            recording_length(sbj) = size(mat,2);
        end
    end
end
end