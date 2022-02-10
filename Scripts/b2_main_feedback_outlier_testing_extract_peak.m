%%% conduct outlier testing (+/- 3SD from the mean) and extract peak latenc
%%% latency on average power 
%% set parameters 
clear
clc

initiation_params;

time_samples2 =(-300:1:800);
data_points2 = 2200:3300;
freq1 = 4:8;

%change chan based on channel of interest
chan = 'Fz';

subject = ':';

%% load file

load([path, '\A1_POWevoked_', chan, '.mat'],'ePOW_All_FB_subj');

%% conduct outlier testing by power

figure;
        
tarvar = eval(strcat('ePOW_All_FB_subj'));
master_table = [];

for q = 1:size(tarvar,1)
    data_sub = squeeze(mean(tarvar(q,freq1,:),2));
    master_table(q,:) = data_sub(data_points2,1);
    scatter(time_samples2,master_table(q,:),1);
    hold on
    disp(q)
end

theta_1 = tarvar(:,freq1,data_points2);
ROI1 = mean(theta_1,2);
std1=std(ROI1(:,1,:));

mean_ROI = squeeze(mean(ROI1,1));
threshd1 = mean_ROI+3*squeeze(std1);
threshd2 = mean_ROI-3*squeeze(std1);
plot(time_samples2,threshd1,'k:');
plot(time_samples2,threshd2,'k:');
plot(time_samples2,mean_ROI,'k:');
legend;

title(['ePOW_All_FB_subj_', chan], 'Interpreter','none');

master_table(29,:) = mean_ROI;
master_table(30,:) = threshd1;
master_table(31,:) = threshd2;

o=0;
outlie_sub = [];

for sub = 1:(size(master_table,1)-3) % subject 
    for i = 1:size(master_table,2) % time
        dp_pow = master_table(sub,i);
        thres = master_table(30,i); %uf exceeding threshold (only upper bound is set here)
        if dp_pow > thres
            o = o + 1;
            outlie_sub(o,1) = sub;
            outlie_sub(o,2) = i-301;
        end
    end
end


master_variable_list = [];

for m = 1:1101
    master_variable_list(1,m) = -301+m;
end

master_table = cat(1, master_variable_list, master_table);

warning( 'off', 'MATLAB:xlswrite:AddSheet' ) ;           


xlsxfilename = [folders.FB_extract_params,'\OT_ePOW_',chan,'_theta_4_8.xlsx']; % defined the excel filename
table = array2table(master_table); % covnert to table
writetable(table,xlsxfilename, 'Sheet', 'ePOW_All_FB_subj', 'Range',(['C1:APK35'])); % write to excel
sub_num = [1:28]';

asub_num = [1,2,4,5,6,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,27,28,29,30,31]';
table = array2table([sub_num,asub_num], 'VariableNames',{'subject_num_in_matfiles','subject_ID_num'}); % conver them into the table
writetable(table,xlsxfilename, 'Sheet', 'ePOW_All_FB_subj', 'Range',(['A2:B36']))

[a, b] = max(mean_ROI);
peak_lat = b-301;

xlswrite(xlsxfilename,peak_lat, 'ePOW_All_FB_subj','A36')

if isempty(outlie_sub) ~= 1
    xlswrite(xlsxfilename,outlie_sub, 'ePOW_All_FB_subj','A40')
end


xlswrite(xlsxfilename,{'peak_lat (post-stim ms)'}, 'ePOW_All_FB_subj','A35')
xlswrite(xlsxfilename,{'average'}, 'ePOW_All_FB_subj','B31')
xlswrite(xlsxfilename,{'average+3SD'}, 'ePOW_All_FB_subj','B32')
xlswrite(xlsxfilename,{'average-3SD'}, 'ePOW_All_FB_subj','B33')
xlswrite(xlsxfilename,{'sub_matID'}, 'ePOW_All_FB_subj','A39')
xlswrite(xlsxfilename,{'time_pts_outlier'}, 'ePOW_All_FB_subj','B39')

savefig([[folders.FB_figures],'\OT_ePOW_',chan,'_theta_4_8.fig'])
    




