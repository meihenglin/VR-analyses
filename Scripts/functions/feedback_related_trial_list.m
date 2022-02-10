function [list_reward, list_noreward, list_left, list_right] = feedback_related_trial_list(Markers);

% o	Reward left: S 235
% o	Reward right S 240
% o	Noreward left: S 245
% o	Noreward right: S 250

list_reward = [];
list_noreward = [];
list_left = [];
list_right = [];

reward = 0;
noreward = 0;
left = 0;
right = 0;

for j = 1:size(Markers,1)
        for m = 1:1:size(Markers,2)
            if Markers(j,m).Position > 2500 && strcmp(Markers(j,m).Description, 'S235')
                reward = reward + 1;
                left = left + 1;
                list_reward(reward,1) = j;
                list_left(left,1) = j;
                break
            elseif Markers(j,m).Position > 2500 && strcmp(Markers(j,m).Description, 'S240')
                reward = reward + 1;
                right = right + 1;
                list_reward(reward,1) = j;
                list_right(right,1) = j;
                break
            elseif Markers(j,m).Position > 2500 && strcmp(Markers(j,m).Description, 'S245')
                noreward = noreward + 1;
                left = left + 1;
                list_noreward(noreward,1) = j;
                list_left(left,1) = j;
                break                
            elseif Markers(j,m).Position > 2500 && strcmp(Markers(j,m).Description, 'S250')
                noreward = noreward + 1;
                right = right + 1;
                list_noreward(noreward,1) = j;
                list_right(right,1) = j;
                break                
             end
        end
end







             