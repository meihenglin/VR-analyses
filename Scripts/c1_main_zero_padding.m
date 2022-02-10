% put zeros to data 2500ms after feedback
clear
close
clc

initiation_params;

files = dir([folders.PAr,'\VRTmaze*']);   

for file_number=1:size(files,1)                    
        subject_num = files(file_number).name(10:11);
        load([folders.PAr, '\',files(file_number).name])  
        
        [Segs, columns] = size(Markers);                % Markers is 2 D structure (segs*columns of markers)

        % go to the folder that contains files that need to be porocessed (already reordered)
        load([folders.PA_reorder, '\EEG_' files(file_number).name])          
        Target_Data = EEG_sbj;                          % EEG_sbj structure = (channels, time points, segments" eg.14*15000*XX

        for j=1:Segs                                    % looping through each trial
            if Target_Data(15,2501,j) ~= FCz(j,2501)    % sanity check (matching signal value on one datapoint between two files) make sure that the file with markers and the file being processed are the same one
                error('Error. \the segment being processed does not match the Marker files')
            end

            for m = 1:1:size(Markers,2)                 % Markers (first dimension is segment, second dimension is column)
                if strcmp(Markers(j,m).Description,'End') == 1 % because we inserted the end markers 2500 after the begining of the second trial, so here you can just find that End markers and use that as an anchor
                    if Markers(j,m).Position > 2501     
                        start_point = Markers(j,m).Position ;
                        Target_Data(1:end,start_point:end,j) = 0; 
                        Processed_Target_Data = Target_Data; 
                        break 
                    end
                end
            end
        end

        if exist('Processed_Target_Data','var') == 1
            EEG_sbj = Processed_Target_Data;
        elseif exist('Processed_Target_Data','var') ~= 1 %
            disp('there is no Processed_Target_Data variable')%
        end

        save([folders.PA_zero,'\Zeroed_EEG_' files(file_number).name],'EEG_sbj');

        clear EEG_sbj Processed_Target_Data j m
end


