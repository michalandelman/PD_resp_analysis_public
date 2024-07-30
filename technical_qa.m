%% technical qa
function[startpoint,N_sessions,corrupted,CorruptedAccelero,DataToUse] =technical_qa(subjData)

  File = importdata(subjData.RawDataFilePath);
    Data=File.data(:,:);
    
    [sessions,idx_sessions] =unique(File.data(:,end));
    sessions_lengths=diff([idx_sessions' length(File.data)]);
    sessions_to_use_indices = find(sessions_lengths > 1200);
    if numel(sessions_to_use_indices) == 1
        selected_session_rows = idx_sessions(sessions_to_use_indices);
        DataToUse = Data(selected_session_rows:end, :);
        startpoint=selected_session_rows(1);
    else
        startpoint=idx_sessions(sessions_lengths > 1200);
        DataToUse = Data(startpoint(1):end,:);
    end
N_sessions=sessions_lengths(sessions_lengths>1200);
    %% is the data corrupted
    iscor=unique(diff(DataToUse(:,end-1)));
if ~sum(iscor)==-255+1 
fprintf('check if the data for subject %s is coruppted \n' , subjData.Name)
corrupted=NaN;
else
    corrupted=false;
end
    %% is accelerometer has coruppted parts

    if sum(sum(DataToUse(:,6:8)<-1999 | DataToUse(:,6:8)>1999))>1000
        fprintf('check if the accelerometer data for subject %s is coruppted \n' , subjData.Name)
        CorruptedAccelero=NaN;
    else
        CorruptedAccelero=false;
    end

    DataToUse(:,4)=-DataToUse(:,4);
end
