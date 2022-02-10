function creatematrice(inputlist,output_m)
         for m = 1:size(inputlist,1)
             varname = [inputlist(m,1)];  
             assignin('base', char(varname), output_m); 
         end
         clear m  