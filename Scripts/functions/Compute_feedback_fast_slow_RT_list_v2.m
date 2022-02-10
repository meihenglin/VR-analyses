function [list_reward, list_noreward, list_reward_fast, list_reward_slow, list_noreward_fast, list_noreward_slow, noreward_fast_RT, noreward_slow_RT, reward_fast_RT, reward_slow_RT, median_reward, median_noreward] = Compute_feedback_fast_slow_RT_list_v2 (Markers, pathout_marker, sbjID, ci)

i= 0;
list_reward = [];
list_noreward = [];

list_reward_fast = [];
list_reward_slow = [];
list_noreward_fast = [];
list_noreward_slow = [];

reward_fast_RT = [];
reward_slow_RT = [];
noreward_fast_RT = [];
noreward_slow_RT = [];

nreward = 0;
nnoreward = 0;
nrewardfast = 0;
nrewardslow = 0;
nnorewardfast = 0;
nnorewardslow = 0;

            
                        
             for j=1:size(Markers,1)                                                       % looping through each segment(i.e. trial)
                        for m = 1:1:size(Markers,2)                                        % looping through each column of Markers (first dimension is segment, second dimension is column)
                                if Markers(j,m).Position > 2501 % if the current marker is after time 2501 (which corresponding to the time 0 on the segment)
                                         if strcmp(Markers(j,m).Description, 'S235') == 1 || strcmp(Markers(j,m).Description, 'S240') == 1 
                                             nreward = nreward+1;           
                                             list_reward(nreward,1) = j;   % add the trial number to the trial list here
                                             start_point = 2501;                % Mark the beginning point of the Start Section
                                             end_point = Markers(j,m).Position; % Mark the end point of the Start Section
                                             RT_on_trial = end_point - start_point; 
                                             list_reward_RT(nreward,1) = RT_on_trial;
                                             break                       % move on to next trial 
                                          elseif strcmp(Markers(j,m).Description, 'S245') == 1 || strcmp(Markers(j,m).Description, 'S250') == 1 
                                             nnoreward = nnoreward+1;          % count that as the gear 3
                                             list_noreward(nnoreward,1) = j;   % add the trial number to the trial list here
                                             start_point = 2501;                % Mark the beginning point of the Start Section
                                             end_point = Markers(j,m).Position; % Mark the end point of the Start Section
                                             RT_on_trial = end_point - start_point; 
                                             list_noreward_RT(nnoreward,1) = RT_on_trial;
                                             break                       % move on to next trial 
                                          end
                                end
                        end
             end
             
             clear j m start_point end_point RT_on_trial
             
             median_reward = median(list_reward_RT,1);
             median_noreward = median(list_noreward_RT,1);
             
             
             for j=1:size(Markers,1)                                                       % looping through each segment(i.e. trial)
                     if find(list_reward(:,1) == j) > 0       
                            for m = 1:1:size(Markers,2)                                        % looping through each column of Markers (first dimension is segment, second dimension is column)
                                    if Markers(j,m).Position > 2501 % if the current marker is after time 2501 (which corresponding to the time 0 on the segment)
                                             if strcmp(Markers(j,m).Description, 'S235') == 1 || strcmp(Markers(j,m).Description, 'S240') == 1 
                                                 start_point = 2501;                % Mark the beginning point of the Start Section
                                                 end_point = Markers(j,m).Position; % Mark the end point of the Start Section
                                                 RT_on_trial = end_point - start_point; 
                                                 if RT_on_trial > median_reward
                                                     nrewardslow = nrewardslow+1;
                                                     reward_slow_RT(nrewardslow,1) = RT_on_trial;
                                                     list_reward_slow(nrewardslow,1) = j; 
                                                     break
                                                 else 
                                                     nrewardfast = nrewardfast+1;
                                                     reward_fast_RT(nrewardfast,1) = RT_on_trial;
                                                     list_reward_fast(nrewardfast,1) = j; 
                                                     break
                                                 end
                                             end
                                    end
                            end

                     elseif find(list_noreward(:,1) == j) > 0                        
                             for m = 1:1:size(Markers,2)                                        % looping through each column of Markers (first dimension is segment, second dimension is column)
                                        if Markers(j,m).Position > 2501 % if the current marker is after time 2501 (which corresponding to the time 0 on the segment)
                                                 if strcmp(Markers(j,m).Description, 'S245') == 1 || strcmp(Markers(j,m).Description, 'S250') == 1 
                                                     start_point = 2501;                % Mark the beginning point of the Start Section
                                                     end_point = Markers(j,m).Position; % Mark the end point of the Start Section
                                                     RT_on_trial = end_point - start_point; 
                                                     if RT_on_trial > median_noreward
                                                         nnorewardslow = nnorewardslow+1;
                                                         noreward_slow_RT(nnorewardslow,1) = RT_on_trial;
                                                         list_noreward_slow(nnorewardslow,1) = j; 
                                                         break
                                                     else 
                                                         nnorewardfast = nnorewardfast+1;
                                                         noreward_fast_RT(nnorewardfast,1) = RT_on_trial;
                                                         list_noreward_fast(nnorewardfast,1) = j; 
                                                         break
                                                     end
                                                 end
                                        end
                             end
                     end
             end
            
if ci == 1            
    save([pathout_marker '\RT_Marker_sub_' sbjID '_fb_speed'], 'reward_fast_RT', 'reward_slow_RT', 'noreward_fast_RT', 'noreward_slow_RT', 'list_reward_fast', 'list_reward_slow','list_noreward_fast','list_noreward_slow' , 'median_reward', 'median_noreward');
end

             
             
             
             
             