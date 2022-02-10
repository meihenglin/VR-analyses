% run t-tests and permutation

clear
clc
initiation_params;

%% Section A - set params and load data

%variables
cond1 = 'left';
cond2 = 'right';
chan = 'FCz';

freq_range = 1:12;
time = 1:120; % in bins

numconseq_dpts = 2;  % width - number of consecutive points that must be sig along time (e.g. 11 = 1.1ms when fs = 1024 Hz)
numconseq_freq = 2;  % tall - number of consecutive points that must be sig along the freq (e.g. 11 = 1.1ms when fs = 1024 Hz)

alphalevel = 0.05; 

rawPowScale = [-.5 1.0];

sub_list = [1 3 4 5 7 8 10 11 12 13 14 15 16 17 19 20 21 22 23 24 25 28];

ynPermute = '2'; %options: '1', '2', or 'no'
    % there are two types of permutations to run - choose one manually by
    % 1 = threshold based off p-value, run permutation on summed Tvalues in cluster
    % 2 = threshold based off permutation null distribution

nPermutations = 1000;

% create variables
nFreq = length(freq_range);
nTime = length(time);

datapoints = (0 + time(1)) : (0 + time(end));

%grab num subjects

load([folders.PA_TFoutput, '\A1_tPower_',chan,'.mat'],['tPOW_BASE_subj_bin_', cond1], ['tPOW_BASE_subj_bin_', cond2])
D1 = eval(['tPOW_BASE_subj_bin_', cond1]);
D2 = eval(['tPOW_BASE_subj_bin_', cond2]);

Dataset1 = D1(sub_list,freq_range,time);
Dataset2 = D2(sub_list,freq_range,time);

nSub =  numel(sub_list);

%Preallocate
tempData = NaN(nSub, nFreq, nTime);
powConds = NaN(nFreq, nTime, 2); %the 2 is number of conditions

Dataset1_m = squeeze(mean(Dataset1,1)); %avg across subjects
Dataset2_m = squeeze(mean(Dataset2,1)); %freq*bin

clear i k T P t_val p_val tvals

%T-test parameters

t_val =  NaN([nFreq nTime]);
p_val =  NaN([nFreq nTime]);
accept = NaN([nFreq nTime]);

%% Validate inputs
validPermute = {'1', '2', 'no'};
%% Section B-1 (v1) conduct the t test

for iFreq = 1 : nFreq
    for iTime = 1 : nTime
        if Dataset1_m(iFreq,iTime) > 0 && Dataset2_m(iFreq,iTime) > 0 % make sure it's not zero (i.e. make sure both conditions are increasing power)
            if strcmp(ynPermute, '1')
                [accept(iFreq,iTime), p_val(iFreq,iTime), ci, stats] = ttest(Dataset1(:,iFreq,iTime) - Dataset2(:,iFreq,iTime), 0, alphalevel);
                t_val(iFreq,iTime) = stats.tstat;  % size: freq*datapoints
            elseif strcmp(ynPermute, '2')
                [~, ~, ~, stats] = ttest(Dataset1(:,iFreq,iTime) - Dataset2(:,iFreq,iTime), 0);
                t_val(iFreq,iTime) = stats.tstat;  % size: freq*datapoints
            end
        end
    end
end

clear i k
%% Section C-1 (v1) identifying clusers by sig t values

% Impose the consecutive points rule to restrict t-values to significant only data
T = NaN(size(t_val)); %T = freq*bin
P = NaN(size(p_val)); %P = freq*bin

for iFreq = 1:nFreq     % at any given frequency
    for iTime = 1:nTime % for bins
        if ((iFreq+numconseq_freq-1) <= size(p_val,1)) && ((iTime+numconseq_dpts-1) <= size(p_val,2)) % make sure the range does not exceed the size of matrix
            
            if p_val((iFreq:iFreq+numconseq_freq-1),(iTime:iTime+numconseq_dpts-1)) ~= 0
                if p_val((iFreq:iFreq+numconseq_freq-1),(iTime:iTime+numconseq_dpts-1)) < alphalevel
                    T((iFreq:iFreq+numconseq_freq-1),(iTime:iTime+numconseq_dpts-1)) = t_val((iFreq:iFreq+numconseq_freq-1),(iTime:iTime+numconseq_dpts-1));
                    P((iFreq:iFreq+numconseq_freq-1),(iTime:iTime+numconseq_dpts-1)) = p_val((iFreq:iFreq+numconseq_freq-1),(iTime:iTime+numconseq_dpts-1));
                end
            end
            
        end
    end
end

%% Section C-2 (v1) Run permutation on p-val identified clusters
% Runs permutations to see if pre-identified cluster existance is sig

% identify individual clusters if more than one in the plot... the image processing toolbox has a function 

% for now, make sure your freq/time range only contain one cluster,
% otherwise this script will take all sig pixels and treat them as one
% cluster
freqCluster = 5:7;
timeCluster = 59:64;
testCluster = T(freqCluster, timeCluster);

testCond1 = D1(sub_list,freqCluster, timeCluster); 
testCond2 = D2(sub_list,freqCluster, timeCluster); 

if strcmp(ynPermute, '1')
        clusterT = sum(testCluster,'all', 'omitnan');
        clusterLocation = testCluster;
        clusterLocation(isnan(testCluster)) = 0;
        [clusterFreq, clusterTime] = find(clusterLocation);
        clusterPixel = [clusterFreq clusterTime];

        nullDistribution = NaN(nPermutations,1);

        %permute
        disp('Starting permutation calculations')
        tic
        for iPrmt = 1:nPermutations
            nullClusterTVals = NaN(length(clusterPixel),1); % clear this var out with every loop
            if iPrmt == round(nPermutations/2)
                disp('Completed half the total permutations.')
            end
            for iPixel = 1:length(clusterPixel)
                shuffleSubIdx = logical(randi([0 1], nSub, 1)); %create random logical array to determine which subjects to shuffle between conditions
                %Shuffle within-subjects power between groups
                nullCond1 = [testCond1(shuffleSubIdx, clusterFreq(iPixel), clusterTime(iPixel)); testCond2(~shuffleSubIdx,clusterFreq(iPixel), clusterTime(iPixel))] ;
                nullCond2 = [testCond1(~shuffleSubIdx, clusterFreq(iPixel), clusterTime(iPixel)); testCond2(shuffleSubIdx,clusterFreq(iPixel), clusterTime(iPixel))] ;
                %Run t-test for this "pixel" in the cluster
                [~, ~,~, stats] = ttest(nullCond1, nullCond2);
                nullClusterTVals(iPixel,1) = stats.tstat;
            end %end for cluster
            nullDistribution(iPrmt,1) = sum(nullClusterTVals, 'all');
        end %end permutation
        toc

        %Visualize null distribution
        figure;
        histogram(nullDistribution,'Normalization','pdf')
        xlabel 'Cluster T-Value (sum)'
        ylabel '#permutations'
        title 'Null Distribution'

        %plot cummulative distribution, so you can visualize what values are on the edges
        figure;
        histogram(nullDistribution,'Normalization','cdf')
        xlabel 'Cluster T-value (sum) comparing across conditions'
        ylabel '#permutations'
        ylim([0 1])
        hold on
        line(xlim,[0.025 0.025],'Color','r','LineStyle',':') %indicates boundary for lower 2.5% of null distribution
        line(xlim,[0.975 0.975],'Color','g','LineStyle',':') %indicates boundary for upper 2.5% of null distribution
        nrBins = 100;
        [cdf,edges] = histcounts(nullDistribution,100,'Normalization','cdf'); %100 is for the number of bins
        hold on
        plot([clusterT clusterT],ylim,'m') %plot your cluster t-value in relation to the null distribution - magenta line

        %calculate P-value
        Pabove    = mean(nullDistribution >= clusterT);
        twosidedP = mean(abs(nullDistribution) >= abs(clusterT));

        if Pabove <= 0.05
            issig = ' an ';
        elseif Pabove > 0.05
            issig = ' no ';
        end

        if twosidedP <= 0.05
            issig2 = ' an ';
        elseif twosidedP > 0.05
            issig2 = ' no ';
        end

        disp(['The nonparametric cluster-based analysis indicated' issig2 'effect of condition when a two-tailed p-value was calculated (p = ' num2str(twosidedP) ').'])
        disp(['The same analysis indicated' issig 'effect of condition 1 being greater than condition 2 (p = ' num2str(Pabove) ', one-tailed).'])


% Section D Now plot the data
    %Graph parameters
    %rawPowScale = [-.2 1.2];
    pValScale = [0 alphalevel];
    tValScale = [0 3];

    %grab condition name from filename
    cond1Title = char(extractBetween(cond1,1,strlength(cond1),'Boundaries','inclusive'));
    cond2Title = char(extractBetween(cond2,1,strlength(cond2),'Boundaries','inclusive'));

    %make graph
    figure;
    sgtitle([cond1Title ' vs ' cond2Title ' (total power) at channel ' chan])

    raw1plot = subplot(4,1,1);
    range = [time(1) time(end) freq_range(1) freq_range(end)]; % range of x axis first and y axis
    surfc(time, freq_range, Dataset1_m)
    colormap(raw1plot, jet);
    shading interp;
    view([0 90]);
    axis(range);
    caxis(rawPowScale);
    raw1bar = colorbar;
    title(raw1bar, 'Power');
    subplotT1 = strrep(cond1, '_', ' ');
    title(subplotT1)

    raw2plot =subplot(4,1,2) ;
    range = [time(1) time(end) freq_range(1) freq_range(end)]; % range of x axis first and y axis
    surfc(time, freq_range, Dataset2_m);
    colormap(raw2plot, jet);
    shading interp;
    view([0 90]);
    axis(range);
    caxis(rawPowScale);
    raw2bar = colorbar;
    title(raw2bar, 'Power');
    subplotT2 = strrep(cond2, '_', ' ');
    title(subplotT2)

    %tvalplot = figure(2);
    tvalplot = subplot(4,1,3);
    contourf(time, freq_range, T)
    yAxisTicks = ceil(logspace(log10(freq_range(1)),log10(freq_range(end)),5))  ;
    title('t value')
    colormap(tvalplot, jet)
    view(2)
    tvalbar = colorbar;
    title(tvalbar, 'T-Value');
    caxis(tValScale);
    shading interp;

    pvalplot = subplot(4,1,4);
    contourf(time, freq_range, P)
    title('p value')
    colormap(pvalplot, hot)
    view(2)
    caxis(pValScale);
    shading(pvalplot, 'interp')
    xlabel('Time (ms)')
    pvalbar = colorbar;
    title(pvalbar, 'P-Value')

    elseif strcmpi(ynPermute, 'no')
        disp('Neither permutation test will not be run')
    elseif ~strcmpi(ynPermute, validPermute)
        disp('Invalid input for ynPermute (options: ''1''. ''2'', or ''no''). Therefore, permutation will not be run.')
end

%% Section C (v2) Run permutation to identify clusters/pixels
% Uses pixel-based multiple comparisons
% Based on script written by Mike X Cohen
if strcmp(ynPermute, '2')
    nullDistribution = NaN(nPermutations,2);

    %permute
    disp('Starting permutation calculations')
    tic
    
    for iPrmt = 1:nPermutations
        tempNullTF = NaN(nFreq, nTime);
        if iPrmt == round(nPermutations/2)
            disp('Completed half the total permutations.')
        end

        for iFreq = 1:nFreq     % at any given frequency
            for iTime = 1:nTime
                shuffleSubIdx = logical(randi([0 1], nSub, 1)); %create random logical array to determine which subjects to shuffle between conditions
                %Shuffle within-subjects power between groups
                nullCond1 = [Dataset1(shuffleSubIdx, iFreq, iTime); Dataset2(~shuffleSubIdx,iFreq, iTime)] ;
                nullCond2 = [Dataset1(~shuffleSubIdx, iFreq, iTime); Dataset2(shuffleSubIdx,iFreq, iTime)] ;
                %Run t-test for this "pixel" in the cluster
                [~, ~,~, stats] = ttest(nullCond1, nullCond2);
                tempNullTF(iFreq, iTime) = stats.tstat;
            end
        end %end for pixel
        %Find largest and smallest t-value in entire matrix for this permuation
        nullDistribution(iPrmt,1) = max(tempNullTF,[], 'all');
        nullDistribution(iPrmt,2) = min(tempNullTF,[], 'all');
    end %end permutation
    
    toc

    %identify which tvalues are in upper and lower range of null distribution 
    %AKA two-sided test
    lowerLimit = prctile(nullDistribution(:,2), 100*(alphalevel/2)); %of the distribution in the min values, find cutoff for lower 2.5%
    upperLimit = prctile(nullDistribution(:,1), 100-(100*(alphalevel/2))); %same as lower limit but for upper 2.5% of max values 
    %one sided
    testUpLimit = prctile(nullDistribution(:,1), 100-(100*alphalevel));
    testLowLimit = prctile(nullDistribution(:,2), 100*alphalevel);

    threshTVals = t_val;
    threshTVals(threshTVals > lowerLimit & threshTVals < upperLimit) = 0; %remove non-sig pixels


    % Graph results
        %Section D (v2) Plot results
    %Visualize null distribution
    figure;
    histogram(nullDistribution,'Normalization','pdf') %should be binomial due to taking min and max t-values
    xlabel 'Min and Max T-values'
    ylabel '#permutations'
    title 'Null Distribution'
    hold on
    plot([upperLimit upperLimit], ylim, 'Color', 'g', 'Linestyle', ':')
    hold on
    plot([lowerLimit lowerLimit], ylim, 'Color', 'r', 'Linestyle', ':')

    if ~any(threshTVals, 'all') %if the result is all 0's, AKA no sig pixels
        disp('There are no significant pixels found after correction.')

        tvalplot = figure;
        surfc(time, freq_range, t_val)
        view([0 90]);
        shading interp
        title('Raw T-values')
        xlabel('Time (ms)')
        ylabel('Frequency (Hz)')
        colormap(tvalplot, jet)
        threshtbar = colorbar;
        title(threshtbar, 'T-Value');
        caxis([min(t_val, [], 'all') max(t_val, [], 'all')]);

    elseif any(threshTVals, 'all') %if there is at least one sig pixel
        [~,~, sigVals] = find(threshTVals);
        nSigVals = numel(sigVals);
        disp(['There are ' num2str(nSigVals) ' significant pixels.'])

        %visualize results
        threshtplot = figure;
        surfc(time, freq_range, threshTVals)
        view([0 90]);
        shading flat
        title('Thresholded T-values')
        xlabel('Time (ms)')
        ylabel('Frequency (Hz)')
        colormap(threshtplot, jet)
        threshtbar = colorbar;
        title(threshtbar, 'T-Value');
        caxis([upperLimit max(threshTVals, [], 'all')]);

    end

end %for permutation 2