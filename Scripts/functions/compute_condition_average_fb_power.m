function [avg_output] = compute_condition_average_fb_power (input_trial_fb_seg, input_trial_list)

% input = frequency, time, seg

trial_sum_output = zeros(40,5000);

for i = 1:size(input_trial_fb_seg,3)
                  if isempty(input_trial_list) == 0
                     if find(input_trial_list(:,1) == i) > 0
                        trial_sum_output = trial_sum_output + input_trial_fb_seg(:,:,i);
                     end
                  end
end
   
avg_output = trial_sum_output/size(input_trial_list,1);