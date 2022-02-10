%%% reordering and cleaning the data for feedback and path segments
clear
close
clc

initiation_params;

rdir = folders.PAr; % first clean FB data, then PA data. % change here to "folder.PAr" to run the data on path analyses files

cd(rdir)

FileNameList = dir('VRTmaze0001*');                  % for the new analyses (01162020-only two conditions-Left and Right) for this aim, each subject has 14 matlab files with different conditions

for i=1:size(FileNameList,1)                         % looping through different conditions
    
    Targetcondition = FileNameList(i).name(13:end);      % for given trial type condition
    files = dir(strcat('*',Targetcondition));            % fetching all the subjects for this specific trial type condition

    for file_number=1:size(files,1)                      % looping through each subject 
        
        subject_num = files(file_number).name(10:11);
        disp([Targetcondition(1:end-4),'_subject_',subject_num]) % omit the ";" to display the current progress 
        load([rdir '\' files(file_number).name])                    % this loads the target file 
        
        for j=1:size(Channels,2)                         % reordering the data
            temp=eval(Channels(j).Name);     
            EEG_sbj(j,:,:)=temp';                        % EEG sub = 3D (channel, time, segs 14*15000*11)
            clear temp
        end

        save([rdir '\reordered\EEG_' files(file_number).name],'EEG_sbj');
        clear EEG_sbj
    end

    %EEG_sub: three dimension (channel, time points, # of segments)
    clearvars -except i FileNameList folders 
end


