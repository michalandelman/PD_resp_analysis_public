function [z]= calculate_z(peaks,block_length)

only_inhales=peaks([peaks.PeakValue]>0);
only_exhales=peaks([peaks.PeakValue]<0);
n=fieldnames(only_inhales);
for i=2:size(n,1)
    x=[only_inhales.(n{i})];
    m=mean(x,'omitnan');
    s=std(x,'omitnan');
    x(x>m+3*s | x<m-3*s)=nan;
    clean_in.(n{i})=x;
end

for i=2:size(n,1)
    y=abs([only_exhales.(n{i})]);
    m=mean(y,'omitnan');
    s=std(y,'omitnan');
    y(y>m+3*s | y<m-3*s)=nan;
    clean_ex.(n{i})=y;
end

z.Inhale_Volume=mean([clean_in.Volume],'omitnan');
z.Exhale_Volume=mean(abs([clean_ex.Volume]),'omitnan');
z.Inhale_Duration=mean([clean_in.Duration],'omitnan');
z.Exhale_Duration=mean([clean_ex.Duration],'omitnan');
z.Inhale_value=mean([clean_in.PeakValue],'omitnan');
z.Exhale_value=mean(abs([clean_ex.PeakValue]),'omitnan');
inter=diff([only_inhales.StartTime]);
m=mean(inter,'omitnan');
s=std(inter,'omitnan');
inter(inter>m+3*s | inter<m-3*s)=nan;
z.Inter_breath_interval=mean(inter,'omitnan');
z.Rate=1./[z.Inter_breath_interval];
z.Tidal_volume=[z.Inhale_Volume]+[z.Exhale_Volume];
z.Minute_Ventilation=[z.Rate].*[z.Tidal_volume];

z.Duty_Cycle_inhale=mean([clean_in.Duration]./[z.Inter_breath_interval],'omitnan');
z.Duty_Cycle_exhale=mean([clean_ex.Duration]./[z.Inter_breath_interval],'omitnan');

z.COV_InhaleDutyCycle=std([clean_in.Duration],'omitnan')./mean([clean_in.Duration],'omitnan');
z.COV_ExhaleDutyCycle=std([clean_ex.Duration],'omitnan')./mean([clean_ex.Duration],'omitnan');

z.COV_BreathingRate=std(inter./mean(inter,'omitnan'),'omitnan');

z.COV_InhaleVolume=std([clean_in.Volume],'omitnan')./[z.Inhale_Volume];
z.COV_ExhaleVolume=std([clean_ex.Volume],'omitnan')./[z.Exhale_Volume];

offsets=[peaks.StartTime]+[peaks.Duration];
[~,idx_s]=sort([peaks.StartTime]);
in=[peaks.PeakValue]>0;
InEx_s=in(idx_s);
offsets_sorted=offsets(idx_s);
onsets=[peaks.StartTime];
onsets_sorted=onsets(idx_s);

inhale_pause=[];
exhale_pause=[];

for i=1:length(offsets)-1
    pause=onsets_sorted(i+1)-offsets_sorted(i);
    if InEx_s(i)==1 && InEx_s(i+1)==0 && pause>=0.05
        inhale_pause(end+1)=pause;
    elseif InEx_s(i)==0 && InEx_s(i+1)==1 && pause>=0.05
        exhale_pause(end+1)=pause;
    end
end

inhale_pause(inhale_pause>mean(inhale_pause)+3*std(inhale_pause)| inhale_pause<mean(inhale_pause)-3*std(inhale_pause))=nan;
exhale_pause(exhale_pause>mean(exhale_pause)+3*std(exhale_pause)| exhale_pause<mean(exhale_pause)-3*std(exhale_pause))=nan;

z.Inhale_Pause_Duration=mean(inhale_pause,'omitnan');
z.Exhale_Pause_Duration=mean(exhale_pause,'omitnan');
z.COV_InhalePauseDutyCycle=std(inhale_pause,'omitnan')./mean(inhale_pause,'omitnan');
z.COV_ExhalePauseDutyCycle=std(exhale_pause,'omitnan')./mean(exhale_pause,'omitnan');
z.Duty_Cycle_InhalePause=mean(inhale_pause./[z.Inter_breath_interval],'omitnan');
z.Duty_Cycle_ExhalePause=mean(exhale_pause./[z.Inter_breath_interval],'omitnan');

z.PercentBreathsWithExhalePause=length(exhale_pause)*100./(size(peaks,1)-size(only_inhales,1));
z.PercentBreathsWithInhalePause=length(inhale_pause)*100./size(only_inhales,1);

%     'Percent of Breaths With Inhale Pause'
end