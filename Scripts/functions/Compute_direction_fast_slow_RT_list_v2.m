function  [list_left, list_right, list_left_fast, list_left_slow, list_right_fast, list_right_slow, left_fast_RT, left_slow_RT, right_fast_RT, right_slow_RT, median_left, median_right] = Compute_direction_fast_slow_RT_list_v2 (Markers, pathout_marker,  sbjID, ci)

list_left = [];
list_right = [];
list_left_RT = [];
list_right_RT = [];

list_left_fast = [];
list_left_slow = [];
list_right_fast = [];
list_right_slow = [];

left_fast_RT = [];
left_slow_RT = [];
right_fast_RT = [];
right_slow_RT = [];

nleft = 0;
nright = 0;
nleftfast = 0;
nleftslow = 0;
nrightfast = 0;
nrightslow = 0;

                         
             for j=1:size(Markers,1)                                                       % looping through each segment(i.e. trial)
                        for m = 1:1:size(Markers,2)                                        % looping through each column of Markers (first dimension is segment, second dimension is column)
                                if Markers(j,m).Position > 2501 % if the current marker is after time 2501 (which corresponding to the time 0 on the segment)
                                         if strcmp(Markers(j,m).Description, 'S235') == 1 || strcmp(Markers(j,m).Description, 'S245') == 1 
                                             nleft = nleft+1;           
                                             list_left(nleft,1) = j;   % add the trial number to the trial list here
                                             start_point = 2501;                % Mark the beginning point of the Start Section
                                             end_point = Markers(j,m).Position; % Mark the end point of the Start Section
                                             RT_on_trial = end_point - start_point; 
                                             list_left_RT(nleft,1) = RT_on_trial;
                                             break                       % move on to next trial 
                                          elseif strcmp(Markers(j,m).Description, 'S240') == 1 || strcmp(Markers(j,m).Description, 'S250') == 1 
                                             nright = nright+1;          % count that as the gear 3
                                             list_right(nright,1) = j;   % add the trial number to the trial list here
                                             start_point = 2501;                % Mark the beginning point of the Start Section
                                             end_point = Markers(j,m).Position; % Mark the end point of the Start Section
                                             RT_on_trial = end_point - start_point; 
                                             list_right_RT(nright,1) = RT_on_trial;
                                             break                       % move on to next trial 
                                          end
                                end
                        end
             end
             
             clear j m start_point end_point RT_on_trial
             
             median_left = median(list_left_RT,1);
             median_right = median(list_right_RT,1);
             
             
             for j=1:size(Markers,1)                                                       % looping through each segment(i.e. trial)
                     if find(list_left(:,1) == j) > 0       
                            for m = 1:1:size(Markers,2)                                        % looping through each column of Markers (first dimension is segment, second dimension is column)
                                    if Markers(j,m).Position > 2501 % if the current marker is after time 2501 (which corresponding to the time 0 on the segment)
                                             if strcmp(Markers(j,m).Description, 'S235') == 1 || strcmp(Markers(j,m).Description, 'S245') == 1 
                                                 start_point = 2501;                % Mark the beginning point of the Start Section
                                                 end_point = Markers(j,m).Position; % Mark the end point of the Start Section
                                                 RT_on_trial = end_point - start_point; 
                                                 if RT_on_trial > median_left
                                                     nleftslow = nleftslow+1;
                                                     left_slow_RT(nleftslow,1) = RT_on_trial;
                                                     list_left_slow(nleftslow,1) = j; 
                                                     break
                                                 else 
                                                     nleftfast = nleftfast+1;
                                                     left_fast_RT(nleftfast,1) = RT_on_trial;
                                                     list_left_fast(nleftfast,1) = j; 
                                                     break
                                                 end
                                             end
                                    end
                            end

                     elseif find(list_right(:,1) == j) > 0                        
                             for m = 1:1:size(Markers,2)                                        % looping through each column of Markers (first dimension is segment, second dimension is column)
                                        if Markers(j,m).Position > 2501 % if the current marker is after time 2501 (which corresponding to the time 0 on the segment)
                                                 if strcmp(Markers(j,m).Description, 'S240') == 1 || strcmp(Markers(j,m).Description, 'S250') == 1 
                                                     start_point = 2501;                % Mark the beginning point of the Start Section
                                                     end_point = Markers(j,m).Position; % Mark the end point of the Start Section
                                                     RT_on_trial = end_point - start_point; 
                                                     if RT_on_trial > median_right
                                                         nrightslow = nrightslow+1;
                                                         right_slow_RT(nrightslow,1) = RT_on_trial;
                                                         list_right_slow(nrightslow,1) = j; 
                                                         break
                                                     else 
                                                         nrightfast = nrightfast+1;
                                                         right_fast_RT(nrightfast,1) = RT_on_trial;
                                                         list_right_fast(nrightfast,1) = j; 
                                                         break
                                                     end
                                                 end
                                        end
                             end
                     end
             end
            
if ci == 1            
    save([pathout_marker '\RT_Marker_sub_' sbjID], 'left_fast_RT', 'left_slow_RT', 'right_fast_RT', 'right_slow_RT', 'list_left_fast', 'list_left_slow','list_right_fast','list_right_slow');
end

             
             
             
             
             