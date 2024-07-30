load('/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/NC_analysis/allAnalysisFields61.mat')
AllSubjData = allAnalysisFields;
SeparateNost=false;
% choose subjects:
% subject_to_use=importdata('/Users/timnas/Documents/projects/ADHD/SubjectsToUse.xlsx');
% subject_to_use=subject_to_use.controls2nd;
%
% subjectsNamesToRemoveFromNasalCycleAnalysis=setdiff({AllSubjData.Name},subject_to_use);
% % subjectsNamesToRemoveFromNasalCycleAnalysis = setdiff({allAnalysisFields(strcmp({allAnalysisFields.Group}, 'ADHD')).SubjectName}, 'AKS229_rit1');
% subjectsIndicesToRemoveFromNasalCycleAnalysis = cellfun(@(str) any(strcmp(str, subjectsNamesToRemoveFromNasalCycleAnalysis)), {AllSubjData.Name});
% AllSubjData = AllSubjData(~subjectsIndicesToRemoveFromNasalCycleAnalysis);

%
UseSelfReportedTimings=true;
% if ~UseSelfReportedTimings
%     load('/Users/timnas/Documents/projects/24h_recordings/accelero/accdata.mat');
% end
xtrain=[];
training_labels=[];
xtest=[];
testing_labels=[];

for i=1:size(AllSubjData,2)
    subjData=AllSubjData(i);

    [qa.startpoint,qa.length_sessions,qa.corrupted,qa.CorruptedAccelero,DataToUse] =technical_qa(subjData);

    [Data, times_vec, timesInSecondsFromSessionStart] = ParseMustahceOutput_LI(subjData);

    % if size(Data,1)~=size(DataToUse,1)
    %     fprintf('check data of %s\n',subjData.Name)
    % end

    Start_sleep=subjData.SleepTime;
    Wake_up=subjData.WakeUpTime;
    NapStart=subjData.NapStart;
    NapEnd=subjData.NapEnd;
    if strcmpi('',NapStart)
        NapStart=[];
        NapEnd=[];
    end

    [timings_per_subj.night, timings_per_subj.morning] = Timna_SleepTime(times_vec, Start_sleep, Wake_up);
    if ~isempty(NapStart)
        [timings_per_subj.nap_start, timings_per_subj.nap_end] = Timna_SleepTime(times_vec, NapStart, NapEnd);
    else
        timings_per_subj.nap_start=nan;
        timings_per_subj.nap_end=nan;
    end
    %% create data wake, data_sleep and data all
    %  takeOnlyContinuesMeasures=true; / mornings...
    CutEdge=1; %exclude morning shorter than CutEdge (in Hours)
    ExcludeNap=true; %exclude nap
    [Data_wake,Data_sleep]=extract_wake_sleep_raw(DataToUse,timings_per_subj,CutEdge,ExcludeNap); % to use raw, insert DataToUse as first parameter

    Data_all=DataToUse;

    block_length_in_minutes=1;
    sliding_window_in_minutes=1;


    [raw_in_block]= data_into_blocks(block_length_in_minutes,sliding_window_in_minutes,Data_wake,SeparateNost); %change here Data_wake or Data_sleep
    %     end
    raw_in_block(end,:)=[];
    labels=repmat({subjData.Name(1:4)},size(raw_in_block));
    group_labels=repmat({subjData.Group},size(raw_in_block));

    if ~exist(['PD/' subjData.Name],'dir')
        mkdir(['PD/' subjData.Name])
        save(['Data/' subjData.Name '/raw_full_data_wake_1min_block.mat'],"labels","raw_in_block",'group_labels');
    else
        save(['Data/' subjData.Name '/raw_full_data_wake_1min_block.mat'],"labels","raw_in_block",'group_labels');
    end
    clearvars "labels" "raw_in_block" 'group_labels'
end
