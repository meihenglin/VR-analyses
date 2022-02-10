function [list_fast, list_fast_RT, list_slow, list_slow_RT, median_RT] = Compute_fast_slow_RT_list_v3 (Markers, pathout_marker,  sbjID, ci)
k = 0;
list_fast = [];
list_slow = [];
list_fast_RT = [];
list_slow_RT = [];
nfast = 0;
nslow = 0;
             
RT_trial_subject =[];

for j=1:size(Markers,1)                                                % looping through each segment(i.e. trial)
    for m = 1:1:size(Markers,2)                                        % looping through each column of Markers (first dimension is segment, second dimension is column)
        if Markers(j,m).Position > 2501                                % if the current marker is after time 2501 (which corresponding to the time 0 on the segment)
            if strcmp(Markers(j,m).Description, 'S235') == 1 || strcmp(Markers(j,m).Description, 'S240') == 1 || strcmp(Markers(j,m).Description, 'S245') == 1 || strcmp(Markers(j,m).Description, 'S250') == 1 
                  k = k+1;                           % increase my trial counter by 1
                  start_point = 2501;                % Mark the beginning point of the Start Section
                  end_point = Markers(j,m).Position; % Mark the end point of the Start Section
                  RT_on_trial = end_point - start_point; % calculate the RT on that given trial
                  if RT_on_trial > 0
                     RT_trial_subject(j,1) = RT_on_trial;
                     break
                  end
             end
         end
    end
end

% calcualte the median
median_RT = median(RT_trial_subject,1);

% this is doing the sanity check
if k~=j
   disp('unequal number of trials for this subject to calcualte median');
end

clear k j m

k = 0;
for j=1:size(Markers,1)                                                       % looping through each segment(i.e. trial)
                        for m = 1:1:size(Markers,2)                                        % looping through each column of Markers (first dimension is segment, second dimension is column)
                                if Markers(j,m).Position > 2501 % if the current marker is after time 2501 (which corresponding to the time 0 on the segment)
                                         if strcmp(Markers(j,m).Description, 'S235') == 1 || strcmp(Markers(j,m).Description, 'S240') == 1 || strcmp(Markers(j,m).Description, 'S245') == 1 || strcmp(Markers(j,m).Description, 'S250') == 1 
                                                        k = k+1;                           % increase my trial counter by 1
                                                        start_point = 2501;                % Mark the beginning point of the Start Section
                                                        end_point = Markers(j,m).Position; % Mark the end point of the Start Section
                                                        RT_on_trial = end_point - start_point; % calculate the RT on that given trial
                                                            
                                                        if RT_on_trial <=  median_RT % if the RT on this trial is not greater than median
                                                               nfast = nfast+1;          % count that as the fast
                                                               list_fast(nfast,1) = j;   % add the trial number to the trial list here
                                                               list_fast_RT(nfast,1) = RT_on_trial;
                                                               break                     % move on to next trial 
                                                        elseif RT_on_trial > median_RT   % if the RT on this trial is greater than median
                                                               nslow = nslow+1;          % count that as slow
                                                               list_slow(nslow,1) = j;   % add the trial number to the trial list here
                                                               list_slow_RT(nslow,1) = RT_on_trial;
                                                               break                       % move on to next trial 
                                                        end
                                          end
                                end
                        end
end
   
if k~=j
   disp('unequal number of trials for this subject to calcualte median');
end

if ci == 1            
    save([pathout_marker '\RT_Marker_sub_' sbjID '_fast_slow'], 'RT_trial_subject', 'list_slow', 'list_slow_RT', 'list_fast', 'list_fast_RT' , 'median_RT');
end
