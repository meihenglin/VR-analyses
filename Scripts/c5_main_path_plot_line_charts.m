% plot line charts

clear
clc
initiation_params;

%% where to find TF data:

time_samples =(1:1:150);
data_points = 1:150;

freq = 4:8; % this define the fre range in the average line plot

con1 = 'fast';
con2 = 'slow';

chan = 'Cz';

sub_list = [1 3 4 5 7 8 10 11 12 13 14 15 16 17 19 20 21 22 23 24 25 28];

%% Plot average lines - be sure run the first section (line 22-52) before you run this section
figure;
condition = {con1,con2};
clear ePOW* iPOW* tPOW*

load([folders.PA_TFoutput,'\A1_tPower', '_',chan,'.mat'],'tPOW_BASE_subj_bin*');

data = [];

for c = 1:2
    clear theta_m1 ROI1 err
            target_con = char(condition(1,c));
            target_variable_name = strcat(['tPOW_BASE_subj_bin_',target_con]);
            target_mat = eval([target_variable_name]);
            theta = target_mat(sub_list,freq,data_points); %subject, frequency, time : means all  theta = 26*5*1001
            theta_m1 = squeeze(mean(theta,1)); % average across all subjects  m1 = 5*1001
            theta_m2 = mean(theta_m1,1);       % m2 = 1*1001
            
            ROI1 = mean(theta,2);
            std1 = std(ROI1(:,1,:));
            err = std1/(sqrt(size(theta,1)));
       
            if c == 1
                if strcmp(con1,'fast') == 1
                    [h1,p1] = boundedline(time_samples, theta_m2, squeeze(err), 'cmap',[0 1 1],'alpha');
                elseif strcmp(con1,'left') == 1
                    [h1,p1] = boundedline(time_samples, theta_m2, squeeze(err), 'cmap',[0.08,0.52,0.09],'alpha');
                end
               hold on;
               data(1,:) = theta_m2; 
               data(2,:) = (squeeze(err)');
              
            elseif c == 2
                if strcmp(con2,'slow') == 1
                    [h2,p2] = boundedline(time_samples, theta_m2, squeeze(err), 'cmap',[0.9290 0.6940 0.1250],'alpha');
                elseif strcmp(con2,'right') == 1
                    [h2,p2] = boundedline(time_samples, theta_m2, squeeze(err), 'cmap',[0.74,0.23,0.84],'alpha');
                end
                
                set(h1,'LineWidth',1.5)
                set(h2,'LineWidth',1.5)
                legend([h1 h2],{con1,con2},'Orientation','vertical','Location','northeast');
                title(['Channel ' chan ': ' con1 ' vs. ' con2 ])
                data(3,:) = theta_m2; 
                data(4,:) = (squeeze(err)');
                xlabel 'Bin'
                ylabel 'Theta Power'
                ylim([-0.4 0.8])
                xlim([0 150])
                yticks([-0.4:0.1:0.8])
                xticks([0:10:150])
                grid on
            end
 
          
                   
end

filename = [chan '_' con1 '_' con2];

saveas(gcf,[folders.PA_figures '\' filename '.fig'])
saveas(gcf,[folders.PA_figures '\' filename '.tif'])




