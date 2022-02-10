%%% Outlier testing on all PA segments (blind to conditions)
clc
clear

initiation_params;

%% set parameters;

chan = 'P8';
fre_range = [4:8];
section_bin = {'Start',1,60;'Turn',61,120;'Return',121,180};

filename = ['A1_tPower_',chan,'.mat'];

load([folders.PA_TFoutput, '\',filename]);

Target_dataset1 = tPOW_BASE_subj_bin_all; % sub*fre*bins

targettitle1 = 'all_segs';

figure;

outlier_mat = zeros(size(Target_dataset1,1),3);

for section = 1:size(section_bin,1)

    s_start_bin = cell2mat(section_bin(section,2));
    s_end_bin = cell2mat(section_bin(section,3));
    s_Target_dataset1 = Target_dataset1(:,:,s_start_bin:s_end_bin); %s_Target_dataset1= 26*40*60
    master_table = [];
    
    theta_1 = s_Target_dataset1(:,fre_range,:);
    ROI1 = mean(theta_1,2);
    std1 = std(ROI1(:,1,:));
    mean_ROI = squeeze(mean(ROI1,1));
    threshd_1 = mean_ROI+3*squeeze(std1);
    threshd_2 = mean_ROI-3*squeeze(std1);
    t_threshold_1 = threshd_1';
    t_threshold_2 = threshd_2';
    
    for q = 1:size(s_Target_dataset1,1)
        data_sub = squeeze(mean(s_Target_dataset1(q,fre_range,:),2));
        master_table(q,:) = data_sub(:,1)';
        k=0;
        for i = 1:size(mean_ROI,1)
            if data_sub(i)>threshd_1(i)
                k=k+1;
            end
        end
        
        outlier_mat(q,section) = k;
        
        subplot(1,size(section_bin,1),section)
        plot((1:60),data_sub(:,1),'-o','MarkerSize',2.5)
        hold on
    end
 
    master_table(29,:) = mean_ROI;
    master_table(30,:) = t_threshold_1;
    master_table(31,:) = t_threshold_2;

    plot((1:60),t_threshold_1,'-kx');
    hold on;
    plot((1:60),t_threshold_2,'-kx');
    hold on;
    plot((1:60),mean_ROI,'-kx');
    grid on;
    title(char(section_bin(section,1)));
    ylim([-2 4])
    xlabel('Bins')
    ylabel('theta power')
    
    for m = 1:60
        master_variable_list(1,m) = {[char(section_bin(section,1)),'_Bin_',num2str(m)]};
    end
  
    xlsxfilename = [folders.PA_extract_params,'\OT_PA_A1_',chan,'_theta_4_8.xlsx']; % defined the excel filename
    sheetname = [chan,'_',char(section_bin(section,1))];% defined the excel 
    table = array2table(master_table,'VariableNames',master_variable_list); % covnert to table
    writetable(table,xlsxfilename, 'Sheet', sheetname, 'Range',(['C1:BJ33'])); % write to excel
    warning( 'off', 'MATLAB:xlswrite:AddSheet' ) ;  
    
    sub_num = [1:28]';
    asub_num = [1,2,4,5,6,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,27,28,29,30,31]';
    table = array2table([sub_num,asub_num], 'VariableNames',{'subject_num_in_matfiles','subject_ID_num'}); % conver them into the table
    writetable(table,xlsxfilename, 'Sheet', sheetname, 'Range',(['A1:B33'])); % write to excel
    
end

legend;
savefig([folders.PA_figures,'\PA_OT_',chan,'.fig']);
 
sheetname = [chan,'_outlier_summary'];% defined the excel 
table = array2table(outlier_mat,'VariableNames',section_bin(1:3,1)); % covnert to table
writetable(table,xlsxfilename, 'Sheet', sheetname, 'Range',(['C1:E33'])); % write to excel
warning( 'off', 'MATLAB:xlswrite:AddSheet' ) ;  
  
sub_num = [1:28]';
asub_num = [1,2,4,5,6,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,27,28,29,30,31]';
table = array2table([sub_num,asub_num], 'VariableNames',{'subject_num_in_matfiles','subject_ID_num'}); % conver them into the table
writetable(table,xlsxfilename, 'Sheet', sheetname, 'Range',(['A1:B33'])); % write to excel
     
