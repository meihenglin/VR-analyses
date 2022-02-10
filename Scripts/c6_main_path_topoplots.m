% This script is used to produce PA EEG topoplots - Figure 3

%% sort files
clear
clc

initiation_params;

%load channel info: here the list did not contain VEOG & FP2
fid=fopen([folders.functions, '\list_channel_VRTmaze_plot_NoFP12.txt'],'r'); 
list_chan=textscan(fid,'%s');
list_chan=list_chan{1};
fclose(fid);

Subject_List = [1 3 4 5 7 8 10 11 12 13 14 15 16 17 19 20 21 22 23 24 25 28];

%% Create a list of files for each condition (Left version Right)

files = {};
cd(folders.PA_TFoutput)


for ii=1:numel(list_chan)
    filePOW=dir(char(strcat('A1_tPower_', cellstr(list_chan{ii}),'.mat')));
    files{ii}=[folders.PA_TFoutput filesep filePOW.name];
end

s_name = 'S1b';

fre_name = 'Delta';

scale1 = [-0.2 0.25];
scale2 = [-0.1 0.2];
scale_t = [-1.96 1.96];

%% ROI total power 
if strcmp(s_name,'S1a') == 1
    b1 = 1;
    b2 = 30;
elseif strcmp(s_name,'S1b') == 1
    b1 = 31;
    b2 = 60;     
elseif strcmp(s_name,'S2a') == 1
    b1 = 61;
    b2 = 90;    
elseif strcmp(s_name,'S2b') == 1
    b1 = 91;
    b2 = 120;
elseif strcmp(s_name,'S3a') == 1
    b1 = 121;
    b2 = 150;    
elseif strcmp(s_name,'S3b') == 1
    b1 = 151;
    b2 = 180; 
else
    disp('bin range undefined')
end

if strcmp(fre_name,'Delta') == 1
    f1 = 1;
    f2 = 3;
elseif strcmp(fre_name,'Theta') == 1
    f1 = 4;
    f2 = 8;
else
    disp('frequency range undefined')
end

figure;
        
        for i=1:length(files)    
            load (files{i});
            target1 = eval(['tPOW_BASE_subj_bin_all']);
            Ch1(i,1) = squeeze(mean(mean(mean(target1(Subject_List,f1:f2,b1:b2),1),2),3)); 
        end
        
        topoplot(Ch1(:,1),[folders.functions,'\Standard_map_VR_noFP12.loc'], 'colormap','jet', 'maplimits', (scale1), 'interplimits','head', 'electrodes', 'on', 'shading', 'interp','numcontour', 12); 
        colorbar('southoutside') 
   
        sgtitle([fre_name,' ', s_name,' ' ,'bin ',  num2str(b1), ' : ', num2str(b2) ])



