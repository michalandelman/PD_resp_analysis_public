clear;
clc;

load('/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/NC_analysis/allAnalysisFields61.mat')
AllSubjData = allAnalysisFields;
SeparateNost=false;
WSA='sleep';
zscored=true;

% choose subjects:
% subject_to_use=importdata('/Users/timnas/Documents/projects/ADHD/SubjectsToUse.xlsx');
% subject_to_use=subject_to_use.all_subj;
%
% subjectsNamesToRemoveFromNasalCycleAnalysis=setdiff({AllSubjData.Name},subject_to_use);
% % subjectsNamesToRemoveFromNasalCycleAnalysis = setdiff({allAnalysisFields(strcmp({allAnalysisFields.Group}, 'ADHD')).SubjectName}, 'AKS229_rit1');
% subjectsIndicesToRemoveFromNasalCycleAnalysis = cellfun(@(str) any(strcmp(str, subjectsNamesToRemoveFromNasalCycleAnalysis)), {AllSubjData.Name});
% AllSubjData = AllSubjData(~subjectsIndicesToRemoveFromNasalCycleAnalysis);


for sbj=1:size(AllSubjData,2)
    SubjectName=AllSubjData(sbj).Name;
    if all([zscored,strcmpi('wake',WSA)])
        file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/PD/' SubjectName '/raw_full_data_wake_5min_block.mat']);
    elseif  all([zscored,strcmpi('sleep',WSA)])
        file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/PD/' SubjectName '/raw_full_data_sleep_5min_block.mat']);
    end

    load([file.folder '/' file.name])
    % xtrain=reshape(xtrain,[size(xtrain,1)*size(xtrain,2) 1]);
    % training_labels=reshape(training_labels,[size(xtrain,1)*size(xtrain,2) 1]);
    %
    % xtest=reshape(xtest,[size(xtest,1)*size(xtest,2) 1]);
    % testing_labels=reshape(testing_labels,[size(xtest,1)*size(xtest,2) 1]);

    xtrain=raw_in_block(:,1);
    labels=group_labels(:,1);
    %
    %  xtest=xtest(:,1);
    % testing_labels=testing_labels(:,1);


    block_length=5;

    for i=1:length(xtrain)
        TimeSeries=xtrain{i};
        peaks=peaks_from_ts(TimeSeries');
        % % %     figure
        % % %     plot(TimeSeries)
        % % %     hold on
        % % %     plot([peaks.PeakLocation],[peaks.PeakValue],'ko')
        zelano_training(i)=calculate_z(peaks,block_length);
        TimeSeries=[];

        DataToLI=[training_L{i,1};training_R{i,1}];
        Fs=6;
        noiseThreshold=5;
        if size(DataToLI,2)<1000
            Resp=[];
        else
            [Resp,~]=hilbert24(DataToLI', Fs, noiseThreshold);
        end
        if size(Resp,2)<4
            measureResults(i).MeanLateralityIndex = nan;
            measureResults(i).stdLateralityIndex = nan;
            measureResults(i).stdAmplitudeLI = nan;
            measureResults(i).MeanAmplitudeLI = nan;
            measureResults(i).Nostril_Corr_RValue = nan;
            measureResults(i).Nostril_Corr_PValue = nan;
        else
            % one number variables
            Laterality_Index=(Resp(1,:)-Resp(2,:))./(Resp(1,:)+Resp(2,:));
            measureResults(i).MeanLateralityIndex = mean(Laterality_Index);
            measureResults(i).stdLateralityIndex = std(Laterality_Index);
            measureResults(i).stdAmplitudeLI = std(abs(Laterality_Index));
            measureResults(i).MeanAmplitudeLI = mean(abs(Laterality_Index));
            [NostrilCorrR, NostrilCorrP] = corrcoef(Resp(1,:), Resp(2,:));
            measureResults(i).Nostril_Corr_RValue = NostrilCorrR(2,1);
            measureResults(i).Nostril_Corr_PValue = NostrilCorrP(2,1);
        end
    end

    % for i=1:length(xtest)
    %     TimeSeries=xtest{i};
    %     peaks=peaks_from_ts(TimeSeries');
    % zelano_testing(i)=calculate_z(peaks,block_length);
    % TimeSeries=[];
    % end

    mat=zelano_training;
    % testing_mat=struct2table(zelano_testing);

    % save('zelano_train_test_full42wake','training_mat','testing_mat','training_labels','testing_labels');
    if zscored
        save(['PD/' SubjectName '/' SubjectName '_zelano_' WSA '_no_overlap_normalized.mat'],'mat','labels');
    else
        save(['PD/' SubjectName '/' SubjectName '_zelano_' WSA '_no_overlap.mat'],'mat','labels');
    end

    % save('zelano_train_test_1h_train_1h_test_97wake','training_mat','testing_mat','training_labels','testing_labels');
    clearvars training_mat training_labels measureResults zelano_training
end






% function[inhales_and_exhales_properties_passed_threshold]=peaks_from_ts(TimeSeries)
% %length parameters
% Fs=6;
% sampleLength=1/Fs;
% time_in_serial_sec_from_start=(1:length(TimeSeries))/Fs;
% 
% peaks_properties = {...
%     'MinPeakDistance', 11, ...     %0.5 * whole_day_period_in_seconds, ...
%     'MinPeakWidth',0.4,...
%     'MinPeakProminence', 0.5};
% 
% Thresh_param.Volume= 0.1;
% Thresh_param.Duration= 0.25;
% Thresh_param.Prctile_Peakvalue=90; %1 percent of max
% Thresh_param.PeakValue=0.01; %1 percent of max
% Thresh_param.duration_of_neigbors_for_baseline_in_minutes=1;
% 
% [inhale_peaks, inhale_indices] = findpeaks(TimeSeries, peaks_properties{:});
% [exhale_peaks, exhale_indices] = findpeaks(-TimeSeries, peaks_properties{:});
% %exhale_peaks = -exhale_peaks;
% 
% Thresh_in=median(inhale_peaks(inhale_peaks>prctile(inhale_peaks,Thresh_param.Prctile_Peakvalue)));
% Thresh_ex=median(exhale_peaks(exhale_peaks>prctile(exhale_peaks,Thresh_param.Prctile_Peakvalue)));
% 
% inhale_peaks_to_keep= inhale_peaks > Thresh_param.PeakValue*Thresh_in; %0.1
% exhale_peaks_to_keep = exhale_peaks > Thresh_param.PeakValue*Thresh_ex;  %-0.1
% 
% 
% inhale_peaks = inhale_peaks(inhale_peaks_to_keep);
% inhale_indices_to_keep = inhale_indices(inhale_peaks_to_keep);
% inhale_locations = time_in_serial_sec_from_start(inhale_indices_to_keep);
% exhale_peaks = exhale_peaks(exhale_peaks_to_keep);
% exhale_indices_to_keep = exhale_indices(exhale_peaks_to_keep);
% exhale_locations = time_in_serial_sec_from_start(exhale_indices_to_keep);
% 
% %% Find properties for each inhales and for each exhale, with corrected-times
% all_relevant_locations_indices = [inhale_indices_to_keep; exhale_indices_to_keep];
% duration_of_neigbors_for_baseline_in_minutes = Thresh_param.duration_of_neigbors_for_baseline_in_minutes;
% if ~isempty(all_relevant_locations_indices)
%     inhales_and_exhales_properties = nested_FindPeaksProperties(sampleLength, duration_of_neigbors_for_baseline_in_minutes, TimeSeries, all_relevant_locations_indices);
% else
%     inhales_and_exhales_properties=struct('PeakLocation',[], 'PeakValue',[], 'Volume',[],'Duration',[],'StartTime',[],'Latency',[],'NumberOfPeaks',[]);
% end
% %% Filter short or shallow inhales and exhales
% minimalLengthInSeconds = Thresh_param.Duration;
% inhales_and_exhales_passed_Duration_threshold = inhales_and_exhales_properties([inhales_and_exhales_properties.Duration] >= minimalLengthInSeconds);
% tmp=abs([inhales_and_exhales_passed_Duration_threshold.Volume]);
% inhales_and_exhales_properties_passed_threshold = inhales_and_exhales_passed_Duration_threshold( tmp >  Thresh_param.Volume*median(tmp));
% 
% end
% 
% function [z]= calculate_z(peaks,block_length)
% 
% only_inhales=peaks([peaks.PeakValue]>0);
% only_exhales=peaks([peaks.PeakValue]<0);
% n=fieldnames(only_inhales);
% for i=2:size(n,1)
%     x=[only_inhales.(n{i})];
%     m=mean(x,'omitnan');
%     s=std(x,'omitnan');
%     x(x>m+3*s | x<m-3*s)=nan;
%     clean_in.(n{i})=x;
% end
% 
% for i=2:size(n,1)
%     y=abs([only_exhales.(n{i})]);
%     m=mean(y,'omitnan');
%     s=std(y,'omitnan');
%     y(y>m+3*s | y<m-3*s)=nan;
%     clean_ex.(n{i})=y;
% end
% 
% z.Inhale_Volume=mean([clean_in.Volume],'omitnan');
% z.Exhale_Volume=mean(abs([clean_ex.Volume]),'omitnan');
% z.Inhale_Duration=mean([clean_in.Duration],'omitnan');
% z.Exhale_Duration=mean([clean_ex.Duration],'omitnan');
% z.Inhale_value=mean([clean_in.PeakValue],'omitnan');
% z.Exhale_value=mean(abs([clean_ex.PeakValue]),'omitnan');
% inter=diff([only_inhales.StartTime]);
% m=mean(inter,'omitnan');
% s=std(inter,'omitnan');
% inter(inter>m+3*s | inter<m-3*s)=nan;
% z.Inter_breath_interval=mean(inter,'omitnan');
% z.Rate=1./[z.Inter_breath_interval];
% z.Tidal_volume=[z.Inhale_Volume]+[z.Exhale_Volume];
% z.Minute_Ventilation=[z.Rate].*[z.Tidal_volume];
% 
% z.Duty_Cycle_inhale=mean([clean_in.Duration]./[z.Inter_breath_interval],'omitnan');
% z.Duty_Cycle_exhale=mean([clean_ex.Duration]./[z.Inter_breath_interval],'omitnan');
% 
% z.COV_InhaleDutyCycle=std([clean_in.Duration],'omitnan')./mean([clean_in.Duration],'omitnan');
% z.COV_ExhaleDutyCycle=std([clean_ex.Duration],'omitnan')./mean([clean_ex.Duration],'omitnan');
% 
% z.COV_BreathingRate=std(inter./mean(inter,'omitnan'),'omitnan');
% 
% z.COV_InhaleVolume=std([clean_in.Volume],'omitnan')./[z.Inhale_Volume];
% z.COV_ExhaleVolume=std([clean_ex.Volume],'omitnan')./[z.Exhale_Volume];
% 
% offsets=[peaks.StartTime]+[peaks.Duration];
% [~,idx_s]=sort([peaks.StartTime]);
% in=[peaks.PeakValue]>0;
% InEx_s=in(idx_s);
% offsets_sorted=offsets(idx_s);
% onsets=[peaks.StartTime];
% onsets_sorted=onsets(idx_s);
% 
% inhale_pause=[];
% exhale_pause=[];
% 
% for i=1:length(offsets)-1
%     pause=onsets_sorted(i+1)-offsets_sorted(i);
%     if InEx_s(i)==1 && InEx_s(i+1)==0 && pause>=0.05
%         inhale_pause(end+1)=pause;
%     elseif InEx_s(i)==0 && InEx_s(i+1)==1 && pause>=0.05
%         exhale_pause(end+1)=pause;
%     end
% end
% 
% inhale_pause(inhale_pause>mean(inhale_pause)+3*std(inhale_pause)| inhale_pause<mean(inhale_pause)-3*std(inhale_pause))=nan;
% exhale_pause(exhale_pause>mean(exhale_pause)+3*std(exhale_pause)| exhale_pause<mean(exhale_pause)-3*std(exhale_pause))=nan;
% 
% z.Inhale_Pause_Duration=mean(inhale_pause,'omitnan');
% z.Exhale_Pause_Duration=mean(exhale_pause,'omitnan');
% z.COV_InhalePauseDutyCycle=std(inhale_pause,'omitnan')./mean(inhale_pause,'omitnan');
% z.COV_ExhalePauseDutyCycle=std(exhale_pause,'omitnan')./mean(exhale_pause,'omitnan');
% z.Duty_Cycle_InhalePause=mean(inhale_pause./[z.Inter_breath_interval],'omitnan');
% z.Duty_Cycle_ExhalePause=mean(exhale_pause./[z.Inter_breath_interval],'omitnan');
% 
% z.PercentBreathsWithExhalePause=length(exhale_pause)*100./(size(peaks,1)-size(only_inhales,1));
% z.PercentBreathsWithInhalePause=length(inhale_pause)*100./size(only_inhales,1);

%     'Percent of Breaths With Inhale Pause'
end