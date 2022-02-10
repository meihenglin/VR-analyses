% this code is used to run the path analyses including feedback zoomed
% in segments using one baseline period (-1000 to -100 ms pre-trial
% baseline)
%

%%
clc 
clear
close all

initiation_params;


%% define and input a list of parameters:
SRate = 1000;   % Sampling Rate
Freq = [1:40];  % Frequency range for the analysis
n_bins = 60;    % here assign the number of bins to prepare for binning the data

chanList = textread([folders.functions,'/list_channel_VRTmaze.txt'],'%s');  % fetching a list of channels
conList_bin = textread([folders.functions,'/conList_bin.txt'],'%s');  % fetching a list of channels
conList_fb = textread([folders.functions,'/conList_fb.txt'],'%s');    % fetching a list of channels

martice_list = textread([folders.functions,'/martice_list.txt'],'%s');
POW_bin_martice_list = textread([folders.functions,'/POW_bin_martice_list.txt'],'%s');
POW_fb_martice_list  = textread([folders.functions,'/POW_fb_martice_list.txt'],'%s');

tPOW_saved_variable_list = textread([folders.functions,'/tPOW_saved_variable_list.txt'],'%s');
iPOW_saved_variable_list = textread([folders.functions,'/iPOW_saved_variable_list.txt'],'%s');
ePOW_saved_variable_list = textread([folders.functions,'/ePOW_saved_variable_list.txt'],'%s');
tPOW_saved_table_fieldnames = textread([folders.functions,'/tPOW_saved_table_fieldnames.txt'],'%s');

chanNum = length(chanList);                                              % sepcifing number of channels being analyzed (#=14)
chan = '';
TIME = 25000;                                                            % total time points for this study (-2500 to 22500)
fb_segment_time = 5000;                                           

files=dir([folders.PA_zero, '\Zeroed_EEG_*']);                            % fetching all of files from each subject that has this condition

tic; % start timing
                                     
for ci=1:chanNum                                                       % looping through each channel (chan 12 = P8; 14 = FCz)
         chanVariable=chanList{ci};                                    % fetching channel number (string characters)
         power_type = 'Total';          
         disp(strcat(power_type,' - Start processing for Channel: ',chanVariable));         % showing the progress when running analyses in real-time
         
         % create whole bunch of empty matrices: the following matrices will store the segment info
         creatematrice(martice_list,[]);
         creatematrice(POW_bin_martice_list,zeros(size(files,1), 40,n_bins*3));
         creatematrice(POW_fb_martice_list,zeros(size(files,1), 40, fb_segment_time));

         tPOW_BASE_subj_baseline = zeros(size(files,1),40,1);
         
         for fi = 1:length(files)                                           % looping through each file (i.e. subjects)
             fName = files(fi).name;                                        % fetching the specific file name (string characters => fName = Zeroed_EEG_VRTmaze0001_Left_SA.mat)
             clear Markers tmp list_* tmpchan
             load([folders.PAr, '\', files(fi).name(12:end)])                                   % load the file 

             % create a list that contains fast and slow RT trials and the nTrials
             [list_fast, list_fast_RT, list_slow, list_slow_RT, median_RT] = Compute_fast_slow_RT_list_v3 (Markers, folders.PA_RT_markers,  fName(21:22), ci);

             % create a list that contains reward and noreward trials and the nTrials
             [list_left, list_right, list_left_fast, list_left_slow, list_right_fast, list_right_slow, left_fast_RT, left_slow_RT, right_fast_RT, right_slow_RT, median_left, median_right] = Compute_direction_fast_slow_RT_list_v2 (Markers, folders.PA_RT_markers,  fName(21:22), ci);

             [list_reward, list_noreward, list_reward_fast, list_reward_slow, list_noreward_fast, list_noreward_slow, noreward_fast_RT, noreward_slow_RT, reward_fast_RT, reward_slow_RT, median_reward, median_noreward] = Compute_feedback_fast_slow_RT_list_v2 (Markers, folders.PA_RT_markers, fName(21:22), ci);

             master_list_fast_slow(fi,1:6) = [str2num(fName(21:22)), median_RT, size(list_fast,1), size(list_slow,1),mean(list_fast_RT,1),mean(list_slow_RT,1)];
             master_list_left_right(fi,1:3) = [str2num(fName(21:22)), size(list_left,1), size(list_right,1)];
             master_list_direction_speed(fi,1:11) = [str2num(fName(21:22)), size(left_fast_RT,1), size(left_slow_RT,1), size(right_fast_RT,1), size(right_slow_RT,1),mean(left_fast_RT,1), mean(left_slow_RT,1), mean(right_fast_RT,1), mean(right_slow_RT,1), median_left, median_right];
             master_list_reward_noreward(fi,1:3) = [str2num(fName(21:22)), size(list_reward,1), size(list_noreward,1)];
             master_list_feedback_speed(fi,1:11) = [str2num(fName(21:22)), size(reward_fast_RT,1), size(reward_slow_RT,1), size(noreward_fast_RT,1), size(noreward_slow_RT,1),mean(reward_fast_RT,1), mean(reward_slow_RT,1), mean(noreward_fast_RT,1), mean(noreward_slow_RT,1), median_reward, median_noreward];
             
             %%
             tmp = load ([folders.PA_zero, '\', files(fi).name]);                        
             chanData = tmp.EEG_sbj;                                       

             if size(chanData,3) ~= size(Markers,1) % sanity check
                disp('unequal number of trials for this subject to calcualte median');
             end
             
             chanVariable = chanList{ci};                                    
             tmpchan = reshape(chanData(ci,:,:),[TIME,size(chanData,3)])';   
      
             %% conduct TFT on all path analyses segments
             tPOW_unbin_un_BC_sum = zeros(40,TIME);                        % create an empty matrix (frequqncy, data points: 60*25000), this is to store the sum of the total power       
             tPOW_trial_unbin_un_BC = zeros(40,TIME,size(tmpchan,1));      % create an empty matrix to store single-trial total baseline uncorrected (3D = frequency*time*trials)
             
             clear k 
             for k = 1:size(tmpchan,1)                                     
                 COEFS = cwt (tmpchan(k,:),SRate*1.5./Freq,'cmor1-1.5');  
                 tPOW_trial_unbin_un_BC(:,:,k) = abs (COEFS(:,1:TIME)).^2; 
                 tPOW_unbin_un_BC_sum = tPOW_unbin_un_BC_sum + abs (COEFS(:,1:TIME)).^2;         % keep adding up the power to POW matrice (total power)
             end
             
             sing_trial_average = squeeze(mean(tPOW_trial_unbin_un_BC(:,:,:),3));
             baseline_avg = mean(sing_trial_average(:,1450:2350),2);  % 40*1
             tPOW_BASE_subj_baseline(fi,:,:) = baseline_avg;          % sub*40*1
             
             % same baseline period but repeat differntly base on the time or bin points
             baseline_avg_rep_bin = repmat(baseline_avg,1,n_bins*3);       %40*180
             baseline_avg_rep_fb_seg = repmat(baseline_avg,1,fb_segment_time);   %40*5000
             
             [Mx_ac_bin, Trial_bin, POW_bin, trial_list, vmean_start_mpb, vmean_turn_mpb, vmean_return_mpb ] = VRT_Interpolate_Induced_Function_v6(folders.PA_zero, folders.PAr, folders.PA_bin_data, fName, chanVariable, n_bins, tPOW_trial_unbin_un_BC);
       
             master_msperbin(fi,1:4) = [str2num(fName(21:22)), vmean_start_mpb, vmean_turn_mpb, vmean_return_mpb];

             Trial_bin_total = Trial_bin;
                
             %% conduct TFT on all feedback-related segments        
             list_all = [1:size(tmpchan,1)]';
             
             % zoom at feedback: -2500 and 2500 centered to the feedback
             clear fb_ERP_trials_all
             [fb_ERP_trials_all] = pre_ERP_calculatation_zoom (tmpchan, Markers, list_all);  %fb_ERP_trials_all = segment*time(e.g. 96*5000)

             tPOW_unbin_un_BC_sum_fb = zeros(40,fb_segment_time);                        % create an empty matrix (frequqncy, data points: 60*25000), this is to store the sum of the total power       
             tPOW_trial_unbin_un_BC_fb = zeros(40,fb_segment_time,size(tmpchan,1));      % create an empty matrix to store single-trial total baseline uncorrected (3D = frequency*time*trials)
           
             clear k 
             for k = 1:size(fb_ERP_trials_all,1)                                       % here it looping through each single trial (the first dimension of tmpchan is trial)
                 COEFS = cwt (fb_ERP_trials_all(k,:),SRate*1.5./Freq,'cmor1-1.5');   % process through the time frequency via cwt function, COEFS is 2D matrix (freq, Time, e.g. 60*15000)
                 tPOW_trial_unbin_un_BC_fb(:,:,k) = abs (COEFS(:,1:fb_segment_time)).^2; % total power matrix = (3D = frequency*time*trials)
                 tPOW_unbin_un_BC_sum_fb = tPOW_unbin_un_BC_sum_fb + abs (COEFS(:,1:fb_segment_time)).^2;         % keep adding up the power to POW matrice (total power)
             end
            
             % the following lines produce the bin data for the path analyses
             clear a* 
             
             for cl = 1:size(conList_bin,1)
                 clear output_mat conName avg_mat keymat input_list mat_name
                 conName = char(conList_bin(cl,1));
                 input_list = eval(['list_',conName]);
                 [avg_mat] = compute_condition_average_bin_power (Trial_bin_total, input_list);
                 output_mat = (avg_mat - baseline_avg_rep_bin)./baseline_avg_rep_bin;
                 mat_name = ['tPOW_BASE_subj_bin_',conName];
                 keymat = eval(mat_name);
                 keymat(fi,:,:) = output_mat;
                 assignin('base', mat_name, keymat); 
             end
             
             clear cl output_mat conName avg_mat keymat input_list
             
             for cl = 1:size(conList_fb,1)
                 clear output_mat conName avg_mat keymat input_list
                 conName = char(conList_fb(cl,1));
                 input_list = eval(['list_',conName]);
                 [avg_mat] = compute_condition_average_fb_power (tPOW_trial_unbin_un_BC_fb, input_list);
                 output_mat = (avg_mat - baseline_avg_rep_fb_seg)./baseline_avg_rep_fb_seg;
                 mat_name = ['tPOW_BASE_subj_fb_',conName];
                 keymat = eval(mat_name);
                 keymat(fi,:,:) = output_mat;
                 assignin('base', mat_name, keymat); 
             end
             
             clear baseline_avg_rep_bin baseline_avg_rep_fb_seg tmpchan
             
             disp(strcat('Total power done for suject ',fName(21:22)));                      % fName = Zeroed_EEG_VRTmaze0001_Left_SA.mat)
         
             tPOW_BASE_subj_bin_avg_fast(fi,:,:) = (tPOW_BASE_subj_bin_left_fast(fi,:,:) + tPOW_BASE_subj_bin_right_fast(fi,:,:))/2;
             tPOW_BASE_subj_bin_avg_slow(fi,:,:) = (tPOW_BASE_subj_bin_left_slow(fi,:,:) + tPOW_BASE_subj_bin_right_slow(fi,:,:))/2;
             
          
         end  

         save([folders.PA_TFoutput '\A1_tPower_', chanVariable,'.mat'], tPOW_saved_variable_list{:,1})
         
         xlsxfilename = [folders.PA_TFoutput,'\1.3_Parameters_output_v2.xlsx'];
         
         if exist([xlsxfilename],'file') ~= 2 % only saved once, doesn't have to save multiple times
            grand_master_list = [master_list_fast_slow master_list_left_right master_list_direction_speed master_list_reward_noreward master_list_feedback_speed master_msperbin];
            behavior_tables = array2table(grand_master_list, 'VariableNames',tPOW_saved_table_fieldnames);
            writetable(behavior_tables,xlsxfilename,'Sheet',1,'Range',(['A1:AL', num2str(size(behavior_tables,1)+1)]));
         end
        
         clear fi % end processing total power
         
         %% start processing induced power
  
         power_type = 'Induced';          
         disp(strcat(power_type,' - Start processing for Channel: ',chanVariable));
         
         iPOW_BASE_subj_baseline = zeros(size(files,1),40,1);
         
         for fi = 1:length(files)                                           % looping through each file (i.e. subjects)
             fName = files(fi).name;                                        % fetching the specific file name (string characters => fName = Zeroed_EEG_VRTmaze0001_Left_SA.mat)
             clear Markers 
             load([folders.PAr, '\', files(fi).name(12:end)])                                   % load the file 

             % create a list that contains fast and slow RT trials and the nTrials
             [list_fast, list_fast_RT, list_slow, list_slow_RT, median_RT] = Compute_fast_slow_RT_list_v3 (Markers, folders.PA_RT_markers,  fName(21:22), ci);

             % create a list that contains reward and noreward trials and the nTrials
             [list_left, list_right, list_left_fast, list_left_slow, list_right_fast, list_right_slow, left_fast_RT, left_slow_RT, right_fast_RT, right_slow_RT, median_left, median_right] = Compute_direction_fast_slow_RT_list_v2 (Markers, folders.PA_RT_markers,  fName(21:22), ci);

             [list_reward, list_noreward, list_reward_fast, list_reward_slow, list_noreward_fast, list_noreward_slow, noreward_fast_RT, noreward_slow_RT, reward_fast_RT, reward_slow_RT, median_reward, median_noreward] = Compute_feedback_fast_slow_RT_list_v2 (Markers, folders.PA_RT_markers, fName(21:22), ci);

             master_list_fast_slow(fi,1:6) = [str2num(fName(21:22)), median_RT, size(list_fast,1), size(list_slow,1),mean(list_fast_RT,1),mean(list_slow_RT,1)];
             master_list_left_right(fi,1:3) = [str2num(fName(21:22)), size(list_left,1), size(list_right,1)];
             master_list_direction_speed(fi,1:11) = [str2num(fName(21:22)), size(left_fast_RT,1), size(left_slow_RT,1), size(right_fast_RT,1), size(right_slow_RT,1),mean(left_fast_RT,1), mean(left_slow_RT,1), mean(right_fast_RT,1), mean(right_slow_RT,1), median_left, median_right];
             master_list_reward_noreward(fi,1:3) = [str2num(fName(21:22)), size(list_reward,1), size(list_noreward,1)];
             master_list_feedback_speed(fi,1:11) = [str2num(fName(21:22)), size(reward_fast_RT,1), size(reward_slow_RT,1), size(noreward_fast_RT,1), size(noreward_slow_RT,1),mean(reward_fast_RT,1), mean(reward_slow_RT,1), mean(noreward_fast_RT,1), mean(noreward_slow_RT,1), median_reward, median_noreward];
             
             %%
             tmp = load ([folders.PA_zero,'\', files(fi).name]);                        % going to the file directory and load that file, name the thing as "tmp". Tmp is a 1 by 1 structure. Contains EEG_sub variable (three D: channel, time points, trials (14*15000*56)
             chanData = tmp.EEG_sbj;                                         % assign the EEG_sbj variable as chanData (maybe easier to manipulate)
             
             if size(chanData,3) ~= size(Markers,1) % sanity check
                disp('unequal number of trials for this subject to calcualte median');
             end
             
             clear tmpchan induced
             chanVariable = chanList{ci};                                    % specifying channel name again
             tmpchan = reshape(chanData(ci,:,:),[TIME,size(chanData,3)])';   % organnize the matrix structure to 2D (segments, Time: e.g. 56*25000), because now we specificy the data at one single channel, this can reduce the dimension from 3D to 2D. Note there is an inverse at the end
             
             iPOW_unbin_un_BC_sum = zeros(40,TIME);                        % create an empty matrix (frequqncy, data points: 60*25000), this is to store the sum of the total power       
             iPOW_trial_unbin_un_BC = zeros(40,TIME,size(tmpchan,1));      % create an empty matrix to store single-trial total baseline uncorrected (3D = frequency*time*trials)
             
             theMean = mean(tmpchan, 1);
             
             clear k 
             for k = 1:size(tmpchan,1)                                      % here it looping through each single trial (the first dimension of tmpchan is trial)
                 induced(k,:) = tmpchan(k,:) - theMean;
                 COEFS = cwt (tmpchan(k,:),SRate*1.5./Freq,'cmor1-1.5');   % process through the time frequency via cwt function, COEFS is 2D matrix (freq, Time, e.g. 60*15000)
                 iPOW_trial_unbin_un_BC(:,:,k) = abs (COEFS(:,1:TIME)).^2; % total power matrix = (3D = frequency*time*trials)
                 iPOW_unbin_un_BC_sum = iPOW_unbin_un_BC_sum + abs (COEFS(:,1:TIME)).^2;         % keep adding up the power to POW matrice (total power)
             end
            
             sing_trial_average = squeeze(mean(iPOW_trial_unbin_un_BC(:,:,:),3));
             baseline_avg = mean(sing_trial_average(:,1450:2350),2);             % 40*1
             iPOW_BASE_subj_baseline(fi,:,:) = baseline_avg;                     % sub*40*1
             baseline_avg_rep_fb_seg = repmat(baseline_avg,1,fb_segment_time);   % 40*1300

             
             %% conduct TFT for all fb segments
             list_all = [1:size(tmpchan,1)]';
             for cl = 1:size(conList_fb,1)
                 clear induced output_mat conName avg_mat keymat input_list
                 conName = char(conList_fb(cl,1));
                 input_list = eval(['list_',conName]);
                 [output_mat] = pre_ERP_calculatation_zoom (tmpchan, Markers, input_list); % the output list here has already limited to the condition
                 theMean = mean(output_mat, 1);
                 
                 un_BC_sum_fb = zeros(40,fb_segment_time);                        % create an empty matrix (frequqncy, data points: 60*25000), this is to store the sum of the total power       
                 unbin_un_BC_fb = zeros(40,fb_segment_time,size(input_list,1));      % create an empty matrix to store single-trial total baseline uncorrected (3D = frequency*time*trials)
                      
                 for k=1:size(input_list,1)                                       % here it looping through each single trial (the first dimension of tmpchan is trial)
                         induced(k,:) = output_mat(k,:) - theMean; 
                         COEFS = cwt (induced(k,:),SRate*1.5./Freq,'cmor1-1.5');   % process through the time frequency via cwt function, COEFS is 2D matrix (freq, Time, e.g. 40*5000)
                         unbin_un_BC_fb(:,:,k) = abs (COEFS(:,1:fb_segment_time)).^2;     % total power matrix = (3D = frequency*time*trials)
                         un_BC_sum_fb = un_BC_sum_fb + abs (COEFS(:,1:fb_segment_time)).^2;         % keep adding up the power to POW matrice (total power)
                 end
                 
                 mat_name = ['iPOW_trial_unbin_un_BC_',conName];
                 assignin('base', mat_name, unbin_un_BC_fb); 
                 
                 clear induced
             end
             
             %% calculating condition average baseline                 
             % fb_zoomed_tPOW_trial = 3D frequency*time*segment
            
             % the following lines produce the bin data for the path analyses
             clear a* 
             
             list_all = [1:size(tmpchan,1)]';
             for cl = 1:size(conList_fb,1)
                 clear output_mat conName avg_mat keymat
                 conName = char(conList_fb(cl,1));
                 input_mat = eval(['iPOW_trial_unbin_un_BC_',conName]);
                 key_list = [1:size(input_mat,3)]';
                 [avg_mat] = compute_condition_average_fb_power (input_mat, key_list);
                 output_mat = (avg_mat - baseline_avg_rep_fb_seg)./baseline_avg_rep_fb_seg;
                 out_mat_name = ['iPOW_BASE_subj_fb_',conName];
                 keymat = eval(out_mat_name);
                 keymat(fi,:,:) = output_mat;
                 assignin('base', out_mat_name, keymat); 
             end
             
             clear tmpchan
             
             disp(strcat('Induced power done for suject ',fName(21:22)));                      % fName = Zeroed_EEG_VRTmaze0001_Left_SA.mat)
  
         end  %%%for each subject

         save([folders.PA_TFoutput, '\A1_iPower_', chanVariable,'.mat'], iPOW_saved_variable_list{:,1})
         

         %% the following lines calculate the evoked power
        
             for cl = 1:size(conList_fb,1)
                 clear output_mat conName S1 S2 avg_mat keymat
                 conName = char(conList_fb(cl,1));
                 S1 = eval(['tPOW_BASE_subj_fb_',conName]);
                 S2 = eval(['iPOW_BASE_subj_fb_',conName]);
                 out_mat = S1-S2;
                 out_mat_name = ['ePOW_BASE_subj_fb_',conName];
                 assignin('base', out_mat_name, out_mat); 
             end
             
             save([folders.PA_TFoutput '\A1_ePower_', chanVariable,'.mat'], ePOW_saved_variable_list{:,1})
         
             
end  %%%for each channel
  

toc
