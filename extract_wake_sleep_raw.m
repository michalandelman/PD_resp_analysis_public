function [Data_wake, Data_sleep] =extract_wake_sleep_raw(CurrentResp,timings_per_subj,CutEdge,ExcludeNap)

Start_sleep=timings_per_subj.night;
Wake_up=timings_per_subj.morning;
NapStart=timings_per_subj.nap_start;
NapEnd=timings_per_subj.nap_end;

% Start_sleep=timings_per_subj.night;
% Wake_up=timings_per_subj.morning;
% NapStart=timings_per_subj.NapStart;
% NapEnd=timings_per_subj.NapEnd;

if isnan(NapStart) && Start_sleep<Wake_up
    if size(CurrentResp,1)-Wake_up<CutEdge*60*60*6
        Data_wake=CurrentResp(1:Start_sleep,:);
    else
        Data_wake=CurrentResp([1:Start_sleep Wake_up:end],:);
    end
Data_sleep=CurrentResp(Start_sleep:Wake_up,:);
elseif ~isnan(NapStart) && Start_sleep<Wake_up  && NapEnd<Start_sleep
    Data_wake=CurrentResp([1:NapStart NapEnd:Start_sleep Wake_up:end],:);
    if ExcludeNap
 Data_sleep=CurrentResp(Start_sleep:Wake_up,:);
    else
    Data_sleep=CurrentResp([NapStart:NapEnd Start_sleep:Wake_up],:);
    end
elseif ~isnan(NapStart) && Start_sleep<Wake_up  && NapStart>Wake_up
    if length(CurrentResp)-NapEnd<CutEdge*60*60*6
            Data_wake=CurrentResp([1:Start_sleep Wake_up:NapStart],:);
    else
    Data_wake=CurrentResp([1:Start_sleep Wake_up:NapStart NapEnd:end],:);
    end
    if ExcludeNap
   Data_sleep=CurrentResp(Start_sleep:Wake_up,:);
    else
    Data_sleep=CurrentResp([Start_sleep:Wake_up NapStart:NapEnd],:);
    end
else
    fprintf('check timestamps');
end

end