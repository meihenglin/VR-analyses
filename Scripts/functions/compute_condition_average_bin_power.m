function [avg_output] = compute_condition_average_bin_power (input_trial_bin, input_trial_list)

trial_sum_output = zeros(40,180);

for i = 1:size(input_trial_bin,2)
                  if isempty(input_trial_list) == 0
                     if find(input_trial_list(:,1) == i) > 0
                        trial_sum_output = trial_sum_output + [input_trial_bin(1,i).Start(:,:) input_trial_bin(1,i).Turn(:,:) input_trial_bin(1,i).Return(:,:)];
                     end
                  end
end
   
avg_output = trial_sum_output/size(input_trial_list,1);