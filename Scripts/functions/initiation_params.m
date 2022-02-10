
%%% Initiate parameters in prep for the analyses
% folder structure
% VR analyses:
%       1.Scripts
%               -> functions    
%       2.EEG Data
%               -> FB raw matlab files exported from Analzyer
%                    -> cleaned and reordered data
%                            -> TF power output
%                                   -> extract params
%                                   -> figures
%               -> Path raw matlab files exported from Analzyer
%                    -> cleaned and reordered data
%                            -> zero-padded data
%                                   -> TF power output
%                                           -> extract params
%                                           -> figures
%                                           -> RT markers
%                                           -> bin data

clear
clc

basepath = 'D:\VR analyses\';

folders.functions = fileparts(which('initiation_params.m'));    % the folder contains functions & files

addpath(folders.functions);

% set up folders for FB analyses
folders.FBr = fullfile(basepath,'FB');  
folders.FB_reorder = fullfile(folders.FBr,'reordered'); % the folder contains EEG FB files exported from matlab
folders.FB_TFoutput = fullfile(folders.FB_reorder,'TF_output'); % the folder contains EEG FB files exported from matlab
folders.FB_extract_params = fullfile(folders.FB_TFoutput,'extract_params'); % the folder contains EEG FB files exported from matlab
folders.FB_figures = fullfile(folders.FB_TFoutput,'figures'); % the folder contains EEG FB files exported from matlab

% set up folders for PA analyses
folders.PAr = fullfile(basepath,'PA'); % the folder contains EEG PA files exported from matlab
folders.PA_reorder = fullfile(folders.PAr,'reordered'); % the folder contains EEG FB files exported from matlab
folders.PA_zero = fullfile(folders.PA_reorder,'zero');  % the folder contains EEG FB files exported from matlab
folders.PA_TFoutput = fullfile(folders.PA_zero,'TF_output'); % the folder contains EEG FB files exported from matlab
folders.PA_extract_params = fullfile(folders.PA_TFoutput,'extract_params');  % the folder contains EEG FB files exported from matlab
folders.PA_figures = fullfile(folders.PA_TFoutput,'figures'); % the folder contains EEG FB files exported from matlab
folders.PA_RT_markers = fullfile(folders.PA_TFoutput,'RT_markers'); % the folder contains EEG FB files exported from matlab
folders.PA_bin_data = fullfile(folders.PA_TFoutput,'binned_data'); % the folder contains EEG FB files exported from matlab


fn = fieldnames(folders);
master_list = sortrows([find(contains(fn ,'FB')); find(contains(fn ,'PA'))]);

for i = 1:size(master_list,1)
    if ~exist(folders.(char(fn(master_list(i)))),'dir')
       mkdir(folders.(char(fn(master_list(i)))))
    end
end

addpath(genpath('VR analyses'));

