function PCanalysis(Table_param,num_PD,num_control,num_param)

% PCA analysis
% PCA for everyone
[~,score_zelano,~,~,~,~]...
    = pca(table2array(Table_param(:,1:num_param)));

% Plot everyone
pc1_healthy = score_zelano((num_PD+1):(num_PD+num_control),1);
pc2_healthy = score_zelano((num_PD+1):(num_PD+num_control),2);
%pc3_healthy = score_zelano((num_PD+1):(num_PD+num_control),3);

pc1_PD = score_zelano(1:num_PD,1);
pc2_PD = score_zelano(1:num_PD,2);
%pc3_PD = score_zelano(1:num_PD,3);

%Plot
figure;
scatter(pc1_healthy,pc2_healthy);
hold on
scatter(pc1_PD,pc2_PD);
hold on
% scatter(pc1_Smellspace,pc2_Smellspace);
title('PCA Analysis of PD vs. healthy control');
xlabel('PC1');
ylabel('PC2');
legend('healthy','PD');