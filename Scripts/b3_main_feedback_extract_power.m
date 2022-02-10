%%% extract the mean amplitude around peak latency obtained from FCz and P8 window
%%% across all bands and channels on FB segments


%% Setting up parameters - be sure to change line 27 based on peak latency obtained from different channels
clear 
clc

initiation_params;

% create a channel list
fid = fopen([folders.functions,'\list_channel_VRTmaze.txt'],'r'); %% here the list did not contain VEOG & FP1 and FP2
list_chan = textscan(fid,'%s');
list_chan = list_chan{1};
fclose(fid);

% creat a condition list to rotate with
power_list = {'POWevoked','POWinduced'};
power_name = {'ePOW','iPOW'};
condition_list = {'Reward','Noreward','Right','Left'}; % condition_list = 1*4 cells

% import the frequency band and its corresponding range
[num,txt,frequency_band_list] = xlsread([folders.functions, '\frequency_band_range_V3']); 

% frequency_band_list = 9*3 cell array

window = {'FCz', 155, 205; 'Fz', 151, 201;'P8', 136, 186}; % when theta is defined as 4:8 not account for pre-release

[num1,txt1,symbols] = xlsread([folders.functions, '\sympbols']); 

%% load all evoked powers
for win = 1:size(window,1)
    window_chan_name = char(window(win,1));
    
    for pl = 1:2
        power_con = char(power_list(1,pl));
            
        for band = 1:size(frequency_band_list,1) 
                
            for chan_num = 1:size(list_chan,1)
                     chan = char(list_chan(chan_num,1));
                     clear ePOW* iPOW*
                     
                     load([folders.FB_TFoutput,'\A1_',power_con,'_',chan,'.mat']);  % each variable = subject*frequency*time                 

                     for cl = 1:4   % change here from reward and noreward to left and right
                         condition_name = char(condition_list{1,cl});
                         Ave_meanPowerValByFreq = [];  
                         keyvariable = eval([char(power_name(1,pl)),'_All_',char(condition_list{1,cl}),'_subj']); 

                         for sub = 1:size(keyvariable,1)

                                    clear startFreq endFreq
                                    startFreq = frequency_band_list{band,2};  % the starting frequency of this band
                                    endFreq = frequency_band_list{band,3};    % the ending frequency of this band

                                    %% 
                                    Ave = keyvariable(sub,startFreq:endFreq,:); 
                                    Ave_m1 = squeeze(Ave);                      
                                    Ave_m2(:,sub) = mean(Ave_m1,1);             
                                   
                                    start_pts = cell2mat(window(win,2));
                                    end_pts = cell2mat(window(win,3));
                                    Ave_meanPowerValByFreq(sub) = mean(Ave_m2((start_pts+2500:end_pts+2500),sub));
                                    
                         end
                        
                    
                        xlsxfilename = [folders.FB_extract_params,'\test2_Al_Mean_Power_window_chan_',window_chan_name,'_FB_',power_con(4:end),'_theta_4_8.xlsx']; % defined the excel filename
                        sheetname = char(frequency_band_list(band,1));   % create the sheet name
                        sub_num = [1:28]';
                        asub_num = [1,2,4,5,6,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,27,28,29,30,31]';
                        table = array2table([sub_num,asub_num], 'VariableNames',{'subject_num_in_matfiles','subject_ID_num'}); % conver them into the table
                        writetable(table,xlsxfilename, 'Sheet', sheetname, 'Range',(['A2:B31']));
                        writetable(table,xlsxfilename, 'Sheet', sheetname, 'Range',(['A42:B71']));

                        xlswrite(xlsxfilename,{'Reward_type'},sheetname, 'A1');
                        xlswrite(xlsxfilename,{'Mean_Power'},sheetname, 'B1');
                        xlswrite(xlsxfilename,{'Turn'},sheetname, 'A41');
                        xlswrite(xlsxfilename,{'Mean_Power'},sheetname, 'B41');

                        objExcel = actxserver('Excel.Application');
                        objExcel.Workbooks.Open(fullfile(xlsxfilename)); % Full path is necessary!
                        objExcel.ActiveWorkbook.Worksheets.Item([sheetname]).Range('A1').Interior.ColorIndex = 40;
                        objExcel.ActiveWorkbook.Worksheets.Item([sheetname]).Range('A41').Interior.ColorIndex = 40;
                        objExcel.ActiveWorkbook.Worksheets.Item([sheetname]).Range('B1').Interior.ColorIndex = 35;
                        objExcel.ActiveWorkbook.Worksheets.Item([sheetname]).Range('B41').Interior.ColorIndex = 35;
                        objExcel.ActiveWorkbook.Save;
                        objExcel.ActiveWorkbook.Close;
                        objExcel.Quit;
                        objExcel.delete;        

                        warning( 'off', 'MATLAB:xlswrite:AddSheet' ) ;

                        if cl < 3
                                   table1 = array2table(Ave_meanPowerValByFreq', 'VariableNames',{[chan,'_',condition_name,'_Mean_Power']}); % conver them into the table
                                   writetable(table1,xlsxfilename, 'Sheet', sheetname, 'Range',([ char(symbols(chan_num*2+(cl-1)+1)),num2str(2)]));
                                   warning( 'off', 'MATLAB:xlswrite:AddSheet' ) ;
                        end

                        if cl > 2
                                   table1 = array2table(Ave_meanPowerValByFreq', 'VariableNames',{[chan,'_',condition_name,'_Mean_Power']}); % conver them into the table
                                   writetable(table1,xlsxfilename, 'Sheet', sheetname, 'Range',([ char(symbols(chan_num*2+(cl-1)-1)),num2str(42)]));
                                   warning( 'off', 'MATLAB:xlswrite:AddSheet' ) ;
                        end 
                     end
             end
        end
   end
end


    
         
