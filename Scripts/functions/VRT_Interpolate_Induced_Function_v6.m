function [Mx_ac_bin, Trial_bin, POW_bin, trial_list, vmean_start_mpb, vmean_turn_mpb, vmean_return_mpb ] = VRT_Interpolate_Induced_Function_v6 (pathdata, pathdata_marker,pathout_bins, fName, chan_name, n_bins, tPOW_trial_unbin_un_BC)

cd(pathdata_marker)
%Targetcondition = conName(1:end-3); % for the given condition (e.g. Left_AR)
     
load(fName(12:end)) % this loads the target file with markers
subject_num = fName(21:22);

%disp([Targetcondition,'_sub_',subject_num]) %this display the current progress 

[Segs, columns] = size(Markers);           % assign number of segments and the total columns of the Markers

list_Start = [];           % create a list to store the trial number that has complete Start section
list_Turn = [];            % create a list to store the trial number that has complete Turn section
list_Return = [];          % create a list to store the trial number that has complete Return section

mean_start_mpb = [];
mean_turn_mpb = [];
mean_return_mpb = [];

                Trial_un_bin    =  struct;                   % create a structure to store the unbin data
                Trial_bin       =  struct;                   % create a structure to store the   bin data
                
                      clear j m
                            k = 0;
                                for j=1:Segs                 % looping through each segment
                                        for m = 1:1:size(Markers,2) % looping through each column of Markers (first dimension is segment, second dimension is column)
                                            if Markers(j,m).Position > 2501 % if the current marker is after time 2501 (which corresponding to the time 0 on the segment)
                                                if strcmp(Markers(j,m).Description, 'aRTurn') == 1 || strcmp(Markers(j,m).Description, 'aLTurn') == 1 %V if this Marker equals to "aRTurn" (e.g.)
                                                        k = k+1;                           % increase my trial counter by 1
                                                        start_point = 2501;                % Mark the beginning point of the Start Section
                                                        end_point = Markers(j,m).Position; % Mark the end point of the Start Section
                                                        Trial_un_bin(k).Start = tPOW_trial_unbin_un_BC(:,start_point:end_point,j); % freq, time, seg
                                                        list_Start(k) = j;                 % assign the trial number to the list, list of Start would be 1*12
                                                        mean_start_mpb(k) = (end_point-start_point)/60;
                                                        break
                                                end
                                            end
                                        end
                                end
                                disp(['done with Start Section'])  
                                % sansity check if all segments have Start section markers defined
                                if k ~= Segs    % if number of trials being processed is not equal to total number of segments (meaning there might be segments that did not have enough markers to define a intact Start Section)
                                    disp(['# of segments in Start for sub ' ,subject_num, ' did not match total #Segs'])
                                end

                         
                            clear j m
                            k = 0;
                                for j=1:Segs                    %% looping through segments
                                    for m = 1:1:size(Markers,2) %% Markers (first dimension is segment, second dimension is column)
                                        if Markers(j,m).Position > 2501  %% 
                                             if strcmp(Markers(j,m).Description, 'aRTurn') == 1 || strcmp(Markers(j,m).Description, 'aLTurn') == 1 %V if this Marker equals to "aRTurn" (e.g.)
                                                if strcmp(Markers(j,m).Description, 'aRTurn') == 1
                                                    for r = 1:1:(size(Markers,2)-m)                             % then find the feedback (which is the end boundary of the Turn Section)
                                                         if strcmp(Markers(j,m+r).Description,'S240') == 1 || strcmp(Markers(j,m+r).Description,'S250') == 1 %% V end of the Turn section is the feedback
                                                            k = k+1;
                                                            start_point = Markers(j,m).Position;
                                                            end_point = Markers(j,m+r).Position; 
                                                            Trial_un_bin(k).Turn = tPOW_trial_unbin_un_BC(:,start_point:end_point,j); % freq, time, segs
                                                            list_Turn(k) = j;
                                                            mean_turn_mpb(k) = (end_point-start_point)/60;
                                                            break
                                                         end
                                                    end
                                                    break
                                                elseif strcmp(Markers(j,m).Description, 'aLTurn') == 1
                                                      for r = 1:1:(size(Markers,2)-m)                             % then find the feedback (which is the end boundary of the Turn Section)
                                                         if strcmp(Markers(j,m+r).Description,'S235') == 1 || strcmp(Markers(j,m+r).Description,'S245') == 1 %% V end of the Turn section is the feedback
                                                            k = k+1;
                                                            start_point = Markers(j,m).Position;
                                                            end_point = Markers(j,m+r).Position; 
                                                            Trial_un_bin(k).Turn = tPOW_trial_unbin_un_BC(:,start_point:end_point,j); % freq, time, segs
                                                            list_Turn(k) = j;
                                                            mean_turn_mpb(k) = (end_point-start_point)/60;
                                                            break
                                                         end
                                                      end
                                                      break
                                                 end
                                            end
                                        end   
                                    end
                                end
                                
                                disp(['done with Turn Section'])
                                if k ~= Segs
                                    disp(['# of segments in Turn for sub ' ,subject_num, ' did not match total #Segs'])
                                end
                          
                          clear j m
                                k = 0;
                                for j=1:Segs                    %% looping through segments
                                    for m = 1:1:size(Markers,2) %% Markers (first dimension is segment, second dimension is column)
                                        if Markers(j,m).Position > 2501   
                                            if strcmp(Markers(j,m).Description, 'S235') == 1 || strcmp(Markers(j,m).Description, 'S240') == 1 || strcmp(Markers(j,m).Description, 'S245') == 1 || strcmp(Markers(j,m).Description, 'S250') == 1
                                                for r = 1:1:(size(Markers,2)-m)
                                                     if strcmp(Markers(j,m+r).Description, 'aLStarti') == 1 || strcmp(Markers(j,m+r).Description,'aRStarti') == 1 || strcmp(Markers(j,m+r).Description, 'aRStart') == 1 || strcmp(Markers(j,m+r).Description, 'aLStart') == 1  || strcmp(Markers(j,m+r).Description,'aStart'   ) == 1 
                                                        k = k+1;
                                                        start_point = Markers(j,m).Position;
                                                        end_point = Markers(j,m+r).Position; 
                                                        Trial_un_bin(k).Return = tPOW_trial_unbin_un_BC(:,start_point:end_point,j); % freq, time, segs
                                                        list_Return(k) = j;
                                                        mean_return_mpb(k) = (end_point-start_point)/60;
                                                        break
                                                     end
                                                end
                                                break
                                            end
                                        end
                                    end   
                                end
                                
                                disp(['done with Return Section'])
                                if k ~= Segs
                                    disp(['# of segments in Return for sub ' ,subject_num, ' did not match total #Segs'])
                                end
                       
            
         
                fn = fieldnames(Trial_un_bin);      % fn = 3*1 cells (Start,  Turn, Return)
                
                for s=1:numel(fn)                   % rotate through the section 
                    for tt = 1:size(Trial_un_bin,2) % rotate through the segments 
                        if isempty(Trial_un_bin(1,tt).(fn{s})) ~= 1 % if the Trial_un_bin(first dimension*can be ignored, tt=trial).Section correspondinh to fn(s) is not empty
                           [freq,length] = size(Trial_un_bin(1,tt).(fn{s})); % assign the frequency and the length of that cell's size (e.g. 60*1028)
                           [N, edges] = histcounts(1:length,n_bins,'BinLimits',[1,length]);  %% calculate the amount of ms within a bin, and the edge for each bin, now N is 1*20 double, contains the ms for each bin
                        
                            for b = 1:size(N,2)            % rotate through each bin, this is to calculate how to grab the accurate start and end point for each bin.
                                    if b == 1                   % first bin  - special treatment
                                        left_edge = 1;          % left  edge - starting from 1ms
                                        right_edge = N(1,b);    % right edge - end of the right end
                                    elseif b > 1                % if the bins are greater than 1
                                        left_edge = sum(N(1,1:(b-1)))+1;    % accumulating all the prior ms as the left edge
                                        right_edge = sum(N(1,(1:b)));       % calculate the right end
                                    end
                                    Trial_bin(1,tt).(fn{s})(:,b) = mean(Trial_un_bin(1,tt).(fn{s})(:,left_edge:right_edge),2); % compute the mean within that given left and right edge for that bin
                            end
                        end
                    end
                end
                
                vmean_start_mpb = mean(mean_start_mpb,2);
                vmean_turn_mpb = mean(mean_turn_mpb,2);
                vmean_return_mpb = mean(mean_return_mpb,2);

                trial_list = list_Start;  % assign the trial list, when there is no markers missing, list_Start, list_Turn, and list_Return should be the same
                
                fn = fieldnames(Trial_bin);   % fn = 3*1 cells (Start,  Turn, Return)
                
                sum_start=zeros(freq,n_bins); % create an empty matrix to store the binned data in the Start Section

                bin_data_start=zeros(size(Trial_un_bin,2),freq,n_bins);
                ff = 0;
                
                for sg = 1:size(Trial_un_bin,2) 
                    if isempty(Trial_bin(1,sg).(fn{1}(:,:))) ~= 1
                        ff=ff+1;
                        bin_data_start(ff,:,:) = Trial_bin(1,sg).(fn{1})(:,:);
                        sum_start = sum_start + Trial_bin(1,sg).(fn{1})(:,:); % accumulating the binned power in the Start Section for each bin
                    end
                end
            
                clear sg
                
                bin_data_turn=zeros(size(Trial_un_bin,2),freq,n_bins);
                sum_turn=zeros(freq,n_bins);
                gg = 0;
                for sg = 1:size(Trial_un_bin,2)
                    if isempty(Trial_bin(1,sg).(fn{2}(:,:))) ~= 1
                        gg = gg+1;
                        sum_turn = sum_turn + Trial_bin(1,sg).(fn{2})(:,:); % accumulating the binned power in the Turn Section for each bin
                        bin_data_turn(gg,:,:) =  Trial_bin(1,sg).(fn{2})(:,:);
                    end
                end
            
                clear sg
                sum_return=zeros(freq,n_bins);
                bin_data_return  =zeros(size(Trial_un_bin,2),freq,n_bins);
                hh = 0;
                for sg = 1:size(Trial_un_bin,2)
                    if isempty(Trial_bin(1,sg).(fn{3}(:,:))) ~= 1
                        hh = hh+1;
                        sum_return = sum_return + Trial_bin(1,sg).(fn{3})(:,:); % accumulating the binned power in the Return Section for each bin
                        bin_data_return(hh,:,:) = Trial_bin(1,sg).(fn{3})(:,:);
                    end
                end                
  
                Master = [sum_start sum_turn sum_return]; % concatnate the data and assign as Master
                Mx_ac_bin= cat(3,bin_data_return,bin_data_start);
                Mx_ac_bin=cat(3,Mx_ac_bin,bin_data_return);
               % save([pathout_bins 'A6_ICA_Master_' chan_name '_Sub_' subject_num],'Master','Trial_bin');

POW_bin = Master;

end




