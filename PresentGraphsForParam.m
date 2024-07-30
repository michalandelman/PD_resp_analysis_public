function PresentGraphsForParam(allAnalysisFields,Table_param_PD,Table_param_control,type_of_graph)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% Colors
[cb] = cbrewer('qual', 'Set3', 12, 'pchip'); % set colors
cl(1, :) = cb(4, :);
cl(2, :) = cb(1, :);

%Define Parameters and Groups
param = {'Inhale_Volume','Exhale_Volume','Inhale_Duration','Exhale_Duration',...
    'Inhale_value','Exhale_value','Inter_breath_interval','Rate','Tidal_volume',...
    'Minute_Ventilation','Duty_Cycle_inhale','Duty_Cycle_exhale',...
    'COV_InhaleDutyCycle','COV_ExhaleDutyCycle','COV_BreathingRate',...
    'COV_InhaleVolume','COV_ExhaleVolume','Inhale_Pause_Duration',...
    'Exhale_Pause_Duration','COV_InhalePauseDutyCycle','COV_ExhalePauseDutyCycle',...
    'Duty_Cycle_InhalePause','Duty_Cycle_ExhalePause','PercentBreathsWithExhalePause',...
    'PercentBreathsWithInhalePause'};
num_param = length(param);
chosen_param = ["Duty_Cycle_inhale","COV_BreathingRate","Duty_Cycle_InhalePause"];
%Groups = categorical({allAnalysisFields.Group});
group_type = categorical({'PD','Healthy'});
% compute total number of patients of PD group
num_PD = sum(strcmp({allAnalysisFields.Group},'PD'));
num_control = sum(strcmp({allAnalysisFields.Group},'control'));

% Simple Boxplot
if strcmp(type_of_graph,'SimpleBoxPlot')
    Groups = categorical({allAnalysisFields.Group});
    p = zeros(1,num_param);
    for i = 1:num_param
        figure;
        boxplot([Table_param_PD.(param{i})',Table_param_control.(param{i})'],Groups);
        [~,p(i)] = ttest2(Table_param_PD.(param{i}),Table_param_control.(param{i}));
        title([param{i}, num2str(p(i))],'FontSize',20,'Interpreter', 'none');
        disp([param{i}, ' ,ttest, p=' num2str(p(i))]);
    end

    % Nice Box plot
elseif strcmp(type_of_graph,'NiceBoxPlot')
    for i = 1:length(chosen_param)
        param_PD = Table_param_PD.(chosen_param(i));
        param_control = Table_param_control.(chosen_param(i));
        ratings = [{param_control} {param_PD}];
        %group = categorical([repmat(1,1,num_control),repmat(2,1,num_PD)]);
        figure;
        hold on
        colors = [5 4];
        for m = 1:2
            b = boxchart(categorical(repmat(m,size(ratings{m},1),1)),ratings{m});
            b.MarkerStyle = 'none';
            b.LineWidth = 2;
            b.BoxFaceAlpha = 0.5;
            b.BoxFaceColor = cb(colors(m),:);
        end
        xticklabels({'Control','PD'});
        ax = gca;
        ax.YAxis.FontSize = 30;
        ax.XAxis.FontSize = 30;
        ax.LineWidth = 4;
        %ylim([0 0.5]);
        %yticks([0 100]);
        box on
        xlabel('Group','FontSize', 30);
        ylabel(chosen_param(i),'Interpreter', 'none','Fontsize',30);
        [p_U,h_U,stats_U] = ranksum(param_PD,param_control);
        Effect = meanEffectSize(param_PD,param_control,Effect="Cliff");
        disp([chosen_param(i),' ,U test, p Bonf = ',num2str(p_U*3)]);
        disp(stats_U);
        disp(Effect);
        disp(['mean PD: ',num2str(mean(param_PD)), 'mean_control:', num2str(mean(param_control))]);
        disp(['STD PD: ',num2str(std(param_PD)), 'STD_control:', num2str(std(param_control))]);
    end

    % bar graph
elseif strcmp(type_of_graph,'BarPlot')
    p = zeros(1,num_param);
    for i = 1:length(chosen_param)
        param_PD = Table_param_PD.(chosen_param(i));
        %women_PD = param_PD([10,24]);
        param_control = Table_param_control.(chosen_param(i));
        %women_control = param_control([10,14,22,32]);
        %[mean(param_PD) std(param_PD) mean(param_control) std(param_control)]
        %[h,p(i),ci,stats] = ttest2(param_PD,param_control);
        [p_U,h_U,stats_U] = ranksum(param_PD,param_control);
        Effect = meanEffectSize(param_PD,param_control,Effect="Cliff");
        %disp(p_U*5);
        %stats_U
        %Effect
        figure;
        hold on
        b1 = bar(group_type,[mean(param_PD,'omitnan'), mean(param_control,'omitnan')],'Facecolor','flat','EdgeColor','none');
        b1.CData(1,:) = cb(5,:);
        b1.CData(2,:) = cb(4,:);
        scatter(group_type(1),param_PD,'o','k','SizeData',75,'jitter','on', 'jitterAmount', 0.07);
        %scatter(group_type(1),women_PD,'o','r','SizeData',75,'jitter','on', 'jitterAmount', 0.07);
        scatter(group_type(2),param_control,'o','k','SizeData',75,'jitter','on', 'jitterAmount', 0.07);
        %scatter(group_type(2),women_control,'o','r','SizeData',75,'jitter','on', 'jitterAmount', 0.07);
        title([chosen_param(i), num2str(p(i))],'FontSize',20,'Interpreter', 'none'); %mean(param_PD),std(param_PD), mean(param_control),std(param_control),stats.tstat
        e = errorbar(group_type, [mean(param_PD,'omitnan'), mean(param_control,'omitnan')], ...
            [std(param_PD,'omitnan'), std(param_control,'omitnan')]./sqrt([length(param_PD) length(param_control)]),'.k', 'LineWidth', 3);
        e.CapSize = 12;
        ax = gca;
        %ylim([p-1 1])
        ax.YAxis.FontSize = 20;
        ax.XAxis.FontSize = 20;
        xlabel('Group')
        ylabel(chosen_param(i),'Interpreter', 'none')
        hold off
        disp([chosen_param(i),' ,U test, p Bonf = ',num2str(p_U*5)]);
    end

    %violin plot
elseif strcmp(type_of_graph,'ViolinPlot')
    group_healthy = cell(num_control,1);
    group_healthy(:) = {'Healthy'};
    group_PD = cell(num_PD,1);
    group_PD(:) = {'PD'};
    all_groups = [group_healthy;group_PD];
    for i = 1:length(chosen_param)
        param_PD = Table_param_PD.(chosen_param(i));
        param_control = Table_param_control.(chosen_param(i));
        figure;
        violinplot([param_PD; param_control],all_groups);
        ax = gca;
        ax.YAxis.FontSize = 20;
        ax.XAxis.FontSize = 20;
        xlabel('Group')
        ylabel(chosen_param(i),'Interpreter', 'none')
        hold off
    end

end
end