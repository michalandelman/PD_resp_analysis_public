function CalculateAccPerBlock(AllSubjData,WSA)

zscored=true;
for sbj=1:size(AllSubjData,2)
    SubjectName=AllSubjData(sbj).Name;
    if all(strcmpi('wake',WSA))
        file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/full_data_acc_wake_5min_block.mat']);
    elseif  all(strcmpi('sleep',WSA))
        file=dir(['/Users/michalag/Desktop/Michal/University/PhD/Research_Subjects/Olfactory_Parkinson/Nasal_Cycle/nasal-cycle-pd/code/features_extraction/Data/' SubjectName '/full_data_acc_sleep_5min_block.mat']);
    end

    load([file.folder '/' file.name])
    % xtrain=reshape(xtrain,[size(xtrain,1)*size(xtrain,2) 1]);
    % training_labels=reshape(training_labels,[size(xtrain,1)*size(xtrain,2) 1]);
    %
    % xtest=reshape(xtest,[size(xtest,1)*size(xtest,2) 1]);
    % testing_labels=reshape(testing_labels,[size(xtest,1)*size(xtest,2) 1]);

    xtrain=raw_in_block(:,1); %no overlap
    labels=group_labels(:,1);
    %
    %  xtest=xtest(:,1);
    % testing_labels=testing_labels(:,1);


    block_length=5;

    for i=1:length(xtrain)
        TimeSeries=xtrain{i};
        % % %     figure
        % % %     plot(TimeSeries)
        % % %     hold on
        % % %     plot([peaks.PeakLocation],[peaks.PeakValue],'ko')
        [average_acceleration,sum_acceleration] = average_acc_calculation(TimeSeries);
        acc_training(i,:)=[average_acceleration,sum_acceleration];
        TimeSeries=[];

        %DataToLI=[training_L{i,1};training_R{i,1}];
        % Fs=6;
        % noiseThreshold=5;
        % if size(DataToLI,2)<1000
        %     Resp=[];
        % else
        %     [Resp,~]=hilbert24(DataToLI', Fs, noiseThreshold);
        % end
        % if size(Resp,2)<4
        %     measureResults(i).MeanLateralityIndex = nan;
        %     measureResults(i).stdLateralityIndex = nan;
        %     measureResults(i).stdAmplitudeLI = nan;
        %     measureResults(i).MeanAmplitudeLI = nan;
        %     measureResults(i).Nostril_Corr_RValue = nan;
        %     measureResults(i).Nostril_Corr_PValue = nan;
        % else
        %     % one number variables
        %     Laterality_Index=(Resp(1,:)-Resp(2,:))./(Resp(1,:)+Resp(2,:));
        %     measureResults(i).MeanLateralityIndex = mean(Laterality_Index);
        %     measureResults(i).stdLateralityIndex = std(Laterality_Index);
        %     measureResults(i).stdAmplitudeLI = std(abs(Laterality_Index));
        %     measureResults(i).MeanAmplitudeLI = mean(abs(Laterality_Index));
        %     [NostrilCorrR, NostrilCorrP] = corrcoef(Resp(1,:), Resp(2,:));
        %     measureResults(i).Nostril_Corr_RValue = NostrilCorrR(2,1);
        %     measureResults(i).Nostril_Corr_PValue = NostrilCorrP(2,1);
        % end
    end

    % for i=1:length(xtest)
    %     TimeSeries=xtest{i};
    %     peaks=peaks_from_ts(TimeSeries');
    % zelano_testing(i)=calculate_z(peaks,block_length);
    % TimeSeries=[];
    % end

    mat=acc_training(:,1); %1=average, 2=sum
    % testing_mat=struct2table(zelano_testing);

    % save('zelano_train_test_full42wake','training_mat','testing_mat','training_labels','testing_labels');
    if ~exist(['Data/' SubjectName '/' SubjectName '_average_acc_magnitude' WSA '_5min_no_overlap.mat'],'file')
        save(['Data/' SubjectName '/' SubjectName '_average_acc_magnitude' WSA '_5min_no_overlap.mat'],'mat','labels');
    end

    % save('zelano_train_test_1h_train_1h_test_97wake','training_mat','testing_mat','training_labels','testing_labels');
    clearvars training_mat training_labels measureResults zelano_training
end

end