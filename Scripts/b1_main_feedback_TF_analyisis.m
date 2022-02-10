%%% Run condition average TF power on FB segments

clc
clear
close all

initiation_params;

% Specify directory
pathdata = folders.FB_reorder;   
pathmarker = folders.FBr;
pathout = folders.FB_TFoutput; 

cd(pathdata);

tic

% Parameters to be set
SRate = 1000;    % Sampling Rate
Freq = [1:40];   % Frequency range for the analysis
chanList = textread(strcat(folders.functions,'/list_channel_VRTmaze.txt'),'%s');  % the files have been edited
chanNum = length(chanList);
chan = '';
TIME = 5000;
freq_cap = 40;
files = dir(strcat(pathdata,'/EEG_*','rFB_A1.mat'));
nsub = 28;

for ci = 1:chanNum
         
         chanVariable = chanList{ci};  
         
         tPOW_cBASE_sub  = zeros(nsub,freq_cap,TIME);
         tPOW_All_FB_subj  = zeros(nsub,freq_cap,TIME);
         tPOW_All_Reward_subj  = zeros(nsub,freq_cap,TIME);
         tPOW_All_Noreward_subj  = zeros(nsub,freq_cap,TIME);
         tPOW_All_Left_subj  = zeros(nsub,freq_cap,TIME);
         tPOW_All_Right_subj  = zeros(nsub,freq_cap,TIME);
         
         disp(strcat('Start processing total power for Channel:',chanVariable));
            
         for fi = 1:length (files)
             % first load the marker file
             fName = files(fi).name;
             mk_filename = fName(5:end);
             load ([pathmarker,'/', mk_filename], 'Markers');
             
             % create trial list
             [list_reward, list_noreward, list_left, list_right] = feedback_related_trial_list(Markers);

             tmp = load ([pathdata,'/', fName]);
             chanData = tmp.EEG_sbj;

             tmpchan = reshape(chanData(ci,:,:),[TIME,size(chanData,3)])'; % tmpchan= segment * time;
             tPOW = zeros(freq_cap,TIME);% freq, data points-same as above
             tPOW_single_trial = zeros(freq_cap,TIME, size(Markers,1));
             
             for k = 1:size(tmpchan,1)
                    COEFS = cwt (tmpchan(k,:),SRate*1.5./Freq,'cmor1-1.5');
                    tPOW_single_trial(:,:,k) = abs (COEFS(:,1:TIME)).^2; 
                    tPOW = tPOW + abs (COEFS(:,1:TIME)).^2; 
             end
             
             %%%% adjust of baseline
             clear tBASE
             tavg_POW = squeeze(mean(tPOW_single_trial(:,:,:),3)); %avg_POW = two dimensions, freq and datapoints
             tavg_POW_window = mean(tavg_POW(:,2200:2350),2);
             tBASE = repmat(tavg_POW_window,1,TIME);
             tPOW_cBASE_sub(fi,:,:)=tBASE;
             tPOW_All_FB_subj(fi,:,:)=(tavg_POW-tBASE)./tBASE;
             
             clear tPOW_single_reward
             %for reward condition
             k = 0;
             for i = 1:size(tPOW_single_trial,3)
                 if find(list_reward(:,1) == i) > 0
                    k = k + 1;
                    tPOW_single_reward(:,:,k) = tPOW_single_trial(:,:,i);
                 end
             end
             
             avg_tPOW_single_reward = mean(tPOW_single_reward,3);
             tPOW_All_Reward_subj(fi,:,:)=(avg_tPOW_single_reward-tBASE)./tBASE;
                 
             clear tPOW_single_noreward    
             %for noreward condition
             k = 0;
             for i = 1:size(tPOW_single_trial,3)
                 if find(list_noreward(:,1) == i) > 0
                    k = k + 1;
                    tPOW_single_noreward(:,:,k) = tPOW_single_trial(:,:,i);
                 end
             end
             
             avg_tPOW_single_noreward = mean(tPOW_single_noreward,3);
             tPOW_All_Noreward_subj(fi,:,:)=(avg_tPOW_single_noreward-tBASE)./tBASE; 

             clear tPOW_single_left
             %for left
             k = 0;
             for i = 1:size(tPOW_single_trial,3)
                 if find(list_left(:,1) == i) > 0
                    k = k + 1;
                    tPOW_single_left(:,:,k) = tPOW_single_trial(:,:,i);
                 end
             end
             
             avg_tPOW_single_left = mean(tPOW_single_left,3);
             tPOW_All_Left_subj(fi,:,:)=(avg_tPOW_single_left-tBASE)./tBASE;              
             
             clear tPOW_single_right
             %for right
             k = 0;
             for i = 1:size(tPOW_single_trial,3)
                 if find(list_right(:,1) == i) > 0
                    k = k + 1;
                    tPOW_single_right(:,:,k) = tPOW_single_trial(:,:,i);
                 end
             end
             
             avg_tPOW_single_right = mean(tPOW_single_right,3);
             tPOW_All_Right_subj(fi,:,:)=(avg_tPOW_single_right-tBASE)./tBASE;   
             
             disp(strcat('done for suject',fName));
             
         end  %%%for each subject
             
         save([pathout '/A1_POWtotal_', chanVariable,'.mat'], 'tPOW_All_Right_subj', 'tPOW_All_Left_subj', 'tPOW_All_Reward_subj',...
         'tPOW_All_Noreward_subj','tPOW_All_FB_subj','tPOW_cBASE_sub') % save complex data
         
  
         %%%%induced 
         disp(strcat('Start induced for Channel:',chanVariable));
         
         iPOW_cBASE_sub  = zeros(nsub,freq_cap,TIME);
         iPOW_All_FB_subj  = zeros(nsub,freq_cap,TIME);
         iPOW_All_Reward_subj  = zeros(nsub,freq_cap,TIME);
         iPOW_All_Noreward_subj = zeros(nsub,freq_cap,TIME);
         iPOW_All_Left_subj  = zeros(nsub,freq_cap,TIME);
         iPOW_All_Right_subj  = zeros(nsub,freq_cap,TIME);

         for fi = 1:length (files)
             % first load the marker file
             fName = files(fi).name;
             mk_filename = fName(5:end);
             load ([pathmarker,'/', mk_filename], 'Markers');
             
             % create trial list
             [list_reward, list_noreward, list_left, list_right] = feedback_related_trial_list(Markers);
             
             tmp = load ([pathdata,'/', fName]);
             chanData = tmp.EEG_sbj;
             tmpchan = reshape(chanData(ci,:,:),[TIME,size(chanData,3)])';

             theMean_all = mean(tmpchan, 1);
             theMean_reward = mean(tmpchan(list_reward(:,1),:),1); % tmpchan = segment * time
             theMean_noreward = mean(tmpchan(list_noreward(:,1),:),1); % tmpchan = segment * time
             theMean_left = mean(tmpchan(list_left(:,1),:),1); % tmpchan = segment * time
             theMean_right = mean(tmpchan(list_right(:,1),:),1); % tmpchan = segment * time
             
             iPOW = zeros(freq_cap,TIME); % freq, data points-same as above
             iPOW_single_trial = zeros(freq_cap, TIME, size(Markers,1));
              
             clear inducedC3 k
             % compute all segments
             for k = 1:size(tmpchan,1)
                 inducedC3(k,:) = tmpchan(k,:) - theMean_all; 
                 COEFS = cwt(inducedC3(k,:), SRate*1.5./Freq, 'cmor1-1.5');
                 iPOW_single_trial(:,:,k) = abs(COEFS(:,1:TIME)).^2; 
                 iPOW = iPOW + abs(COEFS(:,1:TIME)).^2; 
             end
                        
             iavg_POW = squeeze(mean(iPOW_single_trial(:,:,:),3)); %avg_POW = two dimensions, freq and datapoints
             iavg_POW_window = mean(iavg_POW(:,2200:2350),2);
             iBASE = repmat(iavg_POW_window, 1, TIME);
             iPOW_cBASE_sub(fi,:,:) = iBASE;
             iPOW_All_FB_subj(fi,:,:) = (iavg_POW - iBASE)./iBASE;
             
             clear inducedC3 k
             
              %for reward condition
              % compute all segments
             iPOW_single_trial_reward = zeros(freq_cap, TIME, size(list_reward,1));
             for k = 1:size(list_reward,1)
                 tmpchan_reward = tmpchan(list_reward(:,1),:);
                 inducedC3(k,:) = tmpchan_reward(k,:) - theMean_reward; 
                 COEFS = cwt(inducedC3(k,:), SRate*1.5./Freq, 'cmor1-1.5');
                 iPOW_single_trial_reward(:,:,k) = abs(COEFS(:,1:TIME)).^2; 
             end

             avg_iPOW_single_trial_reward = mean(iPOW_single_trial_reward,3);
             iPOW_All_Reward_subj(fi,:,:)=(avg_iPOW_single_trial_reward-iBASE)./iBASE; 
             
             clear inducedC3 k

             %for noreward condition
             % compute all segments
             iPOW_single_trial_noreward = zeros(freq_cap, TIME, size(list_noreward,1));          
             for k = 1:size(list_noreward,1)
                 tmpchan_noreward = tmpchan(list_noreward(:,1),:);
                 inducedC3(k,:) = tmpchan_noreward(k,:) - theMean_noreward; 
                 COEFS = cwt(inducedC3(k,:), SRate*1.5./Freq, 'cmor1-1.5');
                 iPOW_single_trial_noreward(:,:,k) = abs(COEFS(:,1:TIME)).^2; 
             end

             avg_iPOW_single_trial_noreward = mean(iPOW_single_trial_noreward,3);
             iPOW_All_Noreward_subj(fi,:,:)=(avg_iPOW_single_trial_noreward-iBASE)./iBASE;              
             
             clear inducedC3 k
             
             %for left condition
             % compute all segments
             iPOW_single_trial_left = zeros(freq_cap, TIME, size(list_left,1));
             
             for k = 1:size(list_left,1)
                 tmpchan_left = tmpchan(list_left(:,1),:);
                 inducedC3(k,:) = tmpchan_left(k,:) - theMean_left; 
                 COEFS = cwt(inducedC3(k,:), SRate*1.5./Freq, 'cmor1-1.5');
                 iPOW_single_trial_left(:,:,k) = abs(COEFS(:,1:TIME)).^2; 
             end

             avg_iPOW_single_trial_left = mean(iPOW_single_trial_left,3);
             iPOW_All_Left_subj(fi,:,:)=(avg_iPOW_single_trial_left - iBASE)./iBASE;                  
             
             clear inducedC3 k;
             
             % for right condition
             % compute all segments
             iPOW_single_trial_right = zeros(freq_cap, TIME, size(list_right,1));

            for k = 1:size(list_right,1)
                 tmpchan_right = tmpchan(list_right(:,1),:);
                 inducedC3(k,:) = tmpchan_right(k,:) - theMean_right; 
                 COEFS = cwt(inducedC3(k,:), SRate*1.5./Freq, 'cmor1-1.5');
                 iPOW_single_trial_right(:,:,k) = abs(COEFS(:,1:TIME)).^2; 
             end

              clear inducedC3 k;
             avg_iPOW_single_trial_right = mean(iPOW_single_trial_right,3);
             iPOW_All_Right_subj(fi,:,:)=(avg_iPOW_single_trial_right - iBASE)./iBASE;                

             disp(strcat('done for suject',fName));
         end   %%%for each subject

         save([pathout '/A1_POWinduced', '_',chanVariable,'.mat'], 'iPOW_All_Right_subj', 'iPOW_All_Left_subj', 'iPOW_All_Reward_subj',...
         'iPOW_All_Noreward_subj','iPOW_All_FB_subj','iPOW_cBASE_sub') % save complex data
         
         clear ePOW_All_Right_subj ePOW_All_Left_subj ePOW_All_Noreward_subj ePOW_All_Reward_subj ePOW_All_FB_subj

         ePOW_All_Right_subj = tPOW_All_Right_subj - iPOW_All_Right_subj;
         ePOW_All_Left_subj =  tPOW_All_Left_subj -  iPOW_All_Left_subj;
         ePOW_All_Noreward_subj = tPOW_All_Noreward_subj - iPOW_All_Noreward_subj;
         ePOW_All_Reward_subj = tPOW_All_Reward_subj - iPOW_All_Reward_subj;
         ePOW_All_FB_subj =  tPOW_All_FB_subj -  iPOW_All_FB_subj;
 
         save([pathout '/A1_POWevoked', '_',chanVariable,'.mat'], 'ePOW_All_Right_subj', 'ePOW_All_Left_subj', 'ePOW_All_Reward_subj',...
         'ePOW_All_Noreward_subj','ePOW_All_FB_subj') % save complex data
    
end  %%%for each channel


toc
