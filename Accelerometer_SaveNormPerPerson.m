function Accelerometer_SaveNormPerPerson(AllSubjData,SeparateNost,WSA)

% UseSelfReportedTimings=true;
% xtrain=[];
% training_labels=[];
% xtest=[];
% testing_labels=[];

if all([strcmpi('wake',WSA)])
    for i=1:size(AllSubjData,2)
        subjData=AllSubjData(i);

        [qa.startpoint,qa.length_sessions,qa.corrupted,qa.CorruptedAccelero,DataToUse] =technical_qa(subjData);

        [~, times_vec, ~] = ParseMustahceOutput_LI(subjData);

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
        % normalize data
        NormDataToUse = DataToUse;
        % NormDataToUse(:,[6,7,8]) = zscore(NormDataToUse(:,[6,7,8]));
        [Data_wake,~]=extract_wake_sleep_raw(NormDataToUse,timings_per_subj,CutEdge,ExcludeNap);

        %Data_all=DataToUse;

        block_length_in_minutes=5;
        sliding_window_in_minutes=1;


        [raw_in_block]= data_into_blocks_acc(block_length_in_minutes,sliding_window_in_minutes,Data_wake,SeparateNost); %change here Data_wake or Data_sleep
        %     end
        raw_in_block(end,:)=[];
        labels=repmat({subjData.Name(1:4)},size(raw_in_block));
        group_labels=repmat({subjData.Group},size(raw_in_block));

        if ~exist(['Data/' subjData.Name '/full_data_acc_wake_5min_block.mat'],'file')
            if ~exist(['Data/' subjData.Name],'dir')
                mkdir(['Data/' subjData.Name])
                save(['Data/' subjData.Name '/full_data_acc_wake_5min_block.mat'],"labels","raw_in_block",'group_labels');
            else
                save(['Data/' subjData.Name '/full_data_acc_wake_5min_block.mat'],"labels","raw_in_block",'group_labels');
            end
        end
        clearvars "labels" "raw_in_block" 'group_labels'
    end
elseif  all([strcmpi('sleep',WSA)])
    for i=1:size(AllSubjData,2)
        subjData=AllSubjData(i);

        [qa.startpoint,qa.length_sessions,qa.corrupted,qa.CorruptedAccelero,DataToUse] =technical_qa(subjData);

        [~, times_vec, ~] = ParseMustahceOutput_LI(subjData);

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
        % normalize data
        NormDataToUse = DataToUse;
        NormDataToUse(:,[6,7,8]) = zscore(NormDataToUse(:,[6,7,8]));
        [~,Data_sleep]=extract_wake_sleep_raw(NormDataToUse,timings_per_subj,CutEdge,ExcludeNap);

        %Data_all=DataToUse;

        block_length_in_minutes=5;
        sliding_window_in_minutes=5;


        [raw_in_block]= data_into_blocks(block_length_in_minutes,sliding_window_in_minutes,Data_sleep,SeparateNost); %change here Data_wake or Data_sleep
        %     end
        raw_in_block(end,:)=[];
        labels=repmat({subjData.Name(1:4)},size(raw_in_block));
        group_labels=repmat({subjData.Group},size(raw_in_block));

        if ~exist(['Data/' subjData.Name '/norm_full_data_acc_sleep_5min_block.mat'],'file')
            if ~exist(['Data/' subjData.Name],'dir')
                mkdir(['Data/' subjData.Name])
                save(['Data/' subjData.Name '/norm_full_data_acc_sleep_5min_block.mat'],"labels","raw_in_block",'group_labels');
            else
                save(['Data/' subjData.Name '/norm_full_data_acc_sleep_5min_block.mat'],"labels","raw_in_block",'group_labels');
            end
        end
        clearvars "labels" "raw_in_block" 'group_labels'
    end
end