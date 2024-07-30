function [raw_in_block]= data_into_blocks(block_length_in_minutes,sliding_window,Data_wake,SeparateNost,StartPoint,how_long)

if exist('how_long','var')
    X=how_long;
else
    StartPoint=1;
    X=length(Data_wake);
end

if SeparateNost
    raw_data=Data_wake(StartPoint:end,[2 4]);
else
    raw_data=Data_wake(StartPoint:end,2)+Data_wake(StartPoint:end,4);
end
% respirationData=Data_wake(:,2)+Data_wake(:,4);
data_idx=1:length(Data_wake);

N = block_length_in_minutes*60*6; % window size

if block_length_in_minutes<=1
    gap=0;
else
    Na=sliding_window*60*6;
    for i=1:block_length_in_minutes/sliding_window-1
        gap(i)=i*Na;
    end
    gap=[0 gap];
end

if block_length_in_minutes<1
    Ysum=cumsum([0 N*ones(1,fix(X/N)),1+rem(X,N)]);
    i=1;
    for ii=1:length(Ysum)-1
        block_ind= data_idx<Ysum(ii+1) & data_idx>(Ysum(ii)+1);
        raw_in_block{ii,i}=raw_data(block_ind,:);
    end

else
    for i=1:block_length_in_minutes
        Ysum=cumsum([gap(i) N*ones(1,fix(X/N)),1+rem(X,N)]);
        for ii=1:length(Ysum)-1
            block_ind= data_idx<=Ysum(ii+1) & data_idx>=(Ysum(ii)+1);
            raw_in_block{ii,i}=raw_data(block_ind,:)';
        end

    end

end
end