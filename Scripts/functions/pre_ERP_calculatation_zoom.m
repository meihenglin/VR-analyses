function [output_mat] = pre_ERP_calculatation_zoom (input_mat, Markers, input_list)

k=0;
for j=1:size(Markers,1)
    if find(input_list(:,1) == j) > 0  % looping through each segment(i.e. trial)
        k=k+1;
                        for m = 1:1:size(Markers,2)                                        % looping through each column of Markers (first dimension is segment, second dimension is column)
                                if Markers(j,m).Position > 2501 % if the current marker is after time 2501 (which corresponding to the time 0 on the segment)
                                         if strcmp(Markers(j,m).Description, 'S235') == 1 || strcmp(Markers(j,m).Description, 'S245') == 1 || strcmp(Markers(j,m).Description, 'S240') == 1 || strcmp(Markers(j,m).Description, 'S250') == 1
                                             fb_point = Markers(j,m).Position; % Mark the end point of the Start Section
                                             seg_start = fb_point - 2500;
                                             seg_end = fb_point + 2499;
                                             output_mat(k,:) = input_mat(j,seg_start:seg_end);
                                             break                       % move on to next trial 
                                          end
                                end
                        end
    end
end


if k ~= size(input_list,1)
    disp('number of segments does not match')
end

    
    

         