% This script is used to produce FB EEG topoplots
% 
% Here is a note for plotting windows (i.e. the window is defined as 25 ms before and after the peak) 
% obtained from the grand-average waveforms (regardless of trial types)
%
% Fz:  peak lat: 176 (window: 151 to 201 ms)
% P8:  peak lat: 161 (window: 136 to 186 ms)

%% sort files
clear 
close all
clc

initiation_params;

f1 = 4;
f2 = 8;

t1 = 2651; %for Fz window
t2 = 2701; %for Fz window

%t1 = 2636; %for P8 window
%t2 = 2686; %for P8 window

% fetch channels
fid = fopen([folders.functions,'\list_channel_VRTmaze_plot_NoFP12.txt'],'r'); %% here the list did not contain VEOG & FP1 
list_chan = textscan(fid,'%s');
list_chan = list_chan{1};
fclose(fid);

% define subject list
Subject_List = [1 3 4 5 7 8 10 11 12 13 14 15 16 17 19 20 21 22 23 24 25 28];

%% Gathering info from channels for each condition

files = {};
cd(folders.FB_TFoutput)

for ii = 1:numel(list_chan)
    filePOW = dir(char(strcat('A1_POWevoked_',cellstr(list_chan{ii}),'.mat')));
    files{ii} = [folders.FB_TFoutput, '\', filePOW.name];
end


% Reward condition 
Chr=[];
for i=1:length(files)   %% go through each channel
    load (files{i},'ePOW_All_Reward_subj'); 
    Chr(i,1) = squeeze (mean(mean(mean(ePOW_All_Reward_subj(Subject_List,f1:f2,t1:t2),1),2),3));
    clear ePOW_All_Reward_subj;
end

% Noreward condition 
Chnr=[];

for i=1:length(files)
    load (files{i},'ePOW_All_Noreward_subj');
    Chnr(i,1) = squeeze (mean(mean(mean(ePOW_All_Noreward_subj(Subject_List,f1:f2,t1:t2),1),2),3));
    clear ePOW_All_Noreward_subj;
end

% Left condition 
ChLeft=[];

for i=1:length(files)
    load (files{i},'ePOW_All_Left_subj');
    ChLeft(i,1) = squeeze (mean(mean(mean(ePOW_All_Left_subj(Subject_List,f1:f2,t1:t2),1),2),3));
    clear ePOW_All_Left_subj;
end

% Right condition 
ChRight=[];

for i=1:length(files)
    load (files{i},'ePOW_All_Right_subj');
    ChRight(i,1) = squeeze (mean(mean(mean(ePOW_All_Right_subj(Subject_List,f1:f2,t1:t2),1),2),3));
    clear ePOW_All_Right_subj;
end

%% Now plot feedback  - reward and noreward. 

scale1 = [-.05 .5];
scale2 = [-.2 .20]; % the scale for difference wave is different

figure
subplot 131;
topoplot(Chr(:,1),[folders.functions, '\Standard_map_VR_NoFP12.loc'],'colormap','jet', 'maplimits', (scale1), 'interplimits','head', 'electrodes', 'on', 'shading', 'interp','numcontour', 12);title(['reward - no FP12 ',mat2str(t1-2500), ' - ', mat2str(t2-2500), 'ms']);
colorbar;
subplot 132;
topoplot(Chnr(:,1),[folders.functions, '\Standard_map_VR_NoFP12.loc'],'colormap','jet', 'maplimits', (scale1), 'interplimits','head', 'electrodes', 'on', 'shading', 'interp','numcontour', 12);title(['noreward - no FP12 ',mat2str(t1-2500), ' - ', mat2str(t2-2500), 'ms']);
colorbar;
subplot 133;
topoplot(Chnr(:,1)-Chr(:,1),[folders.functions, '\Standard_map_VR_NoFP12.loc'],'colormap','jet', 'maplimits', (scale2), 'interplimits','head', 'electrodes', 'on', 'shading', 'interp','numcontour', 12);title(['difference wave (NR - R) - no FP12 ',mat2str(t1-2500), ' - ', mat2str(t2-2500), 'ms']);
colorbar;


%% plot left and right. Be sure to run the first section 
scale1 = [-.05 .4];
scale2 = [-.2 .3]; % the scale for difference wave is different

figure
subplot 131;
topoplot(ChLeft(:,1),[folders.functions, '\Standard_map_VR_NoFP12.loc'],'colormap','jet', 'maplimits', (scale1), 'interplimits','head', 'electrodes', 'on', 'shading', 'interp','numcontour', 12);title(['left - no FP12 ',mat2str(t1-2500), ' - ', mat2str(t2-2500), 'ms']);
colorbar;
subplot 132;
topoplot(ChRight(:,1),[folders.functions, '\Standard_map_VR_NoFP12.loc'],'colormap','jet', 'maplimits', (scale1), 'interplimits','head', 'electrodes', 'on', 'shading', 'interp','numcontour', 12);title(['right - no FP12 ',mat2str(t1-2500), ' - ', mat2str(t2-2500), 'ms']);
colorbar;
subplot 133;
topoplot(ChRight(:,1)-ChLeft(:,1),[folders.functions, '\Standard_map_VR_NoFP12.loc'],'colormap','jet', 'maplimits', (scale2), 'interplimits','head', 'electrodes', 'on', 'shading', 'interp','numcontour', 12);title(['difference wave (R - L) - no FP12 ',mat2str(t1-2500), ' - ', mat2str(t2-2500), 'ms']);
colorbar;

