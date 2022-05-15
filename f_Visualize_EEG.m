function f_Visualize_EEG(EEG_class_arr, recordingFolder, EEG_Chans, gEEG)
% Input - 
% recordingFolder - string for the recordings files
% EEG_class_arr - A 
% Output - Visualizes and saves plot from the data
% Predefine some parameters: 
figureFolder = strcat(recordingFolder, '\Figures\');
if not(isfolder(figureFolder ))
    mkdir(figureFolder );
end
% n_class = 3;
n_row = 2;
n_columns = 3;
%% Plot general ERP
figure;
subplot(1,2,1);
hold on
h = plot(gEEG.times,squeeze(gEEG.data(1,:,:)),'linew',.5);
set(h,'color',[1 1 1]*.75)
plot(gEEG.times,squeeze(mean(gEEG.data(1,:,:),3)),'k','linew',3);
xlabel('Time (ms)'), ylabel('Activity')
ylim([-100,100]);
title('ERP from channel C3')
hold off
subplot(1,2,2);
hold on
h = plot(gEEG.times,squeeze(gEEG.data(2,:,:)),'linew',.5);
set(h,'color',[1 1 1]*.75)
plot(gEEG.times,squeeze(mean(gEEG.data(2,:,:),3)),'k','linew',3);
xlabel('Time (ms)'), ylabel('Activity')
ylim([-100,100]);
title('ERP from channel C3')
hold off
%% Plot ERP Data in the time domain
figure; 
for i = 1:length(EEG_class_arr)
    subplot(n_row,n_columns,i);
    slc_EEG = EEG_class_arr(i);   
    % Plot ERP Data for C3 Channel 
    hold on
    h = plot(slc_EEG.times,squeeze(slc_EEG.data(1,:,:)),'linew',.5);
    set(h,'color',[1 1 1]*.75)
    plot(slc_EEG.times,squeeze(mean(slc_EEG.data(1,:,:),3)),'k','linew',3);
    xlabel('Time (ms)'), ylabel('Activity')
    ylim([-100,100]);
    title('ERP from channel C3')
    hold off
    subplot(n_row,n_columns,i+3);
    slc_EEG = EEG_class_arr(i);   
    % Plot ERP Data for C3 Channel 
    hold on
    h = plot(slc_EEG.times,squeeze(slc_EEG.data(2,:,:)),'linew',.5);
    set(h,'color',[1 1 1]*.75)
    plot(slc_EEG.times,squeeze(mean(slc_EEG.data(2,:,:),3)),'k','linew',3);
    ylim([-100,100]);
    xlabel('Time (ms)'), ylabel('Activity')
    title('ERP from channel C4')
    hold off
    % Plot ERP Data for C4 Channel: 
end 
saveas(gcf,strcat(figureFolder,'\ERP_Plots.png'))
%% Plot Spectograms
figure; 
for i = 1:length(EEG_class_arr)
    slc_EEG = EEG_class_arr(i);
    % Extract for channel C3
    [frex_C3,tf_C3] = f_Extract_TimeFreq(slc_EEG, 1);
    % Extract for channel C4
    [frex_C4,tf_C4] = f_Extract_TimeFreq(slc_EEG, 2);
    % show a map of the time-frequency power
    % Plot for C3:
    subplot(n_row ,n_columns,i);
    contourf(slc_EEG.times,frex_C3,tf_C3,40,'linecolor','none')
    xlabel('Time (ms)'), ylabel('Frequency (Hz)')
    title(strcat(slc_EEG.setname,' - C3 Spectogram'))
    % Plot for C4
    subplot(n_row,n_columns,i+3);
    contourf(slc_EEG.times,frex_C4,tf_C4,40,'linecolor','none')
    xlabel('Time (ms)'), ylabel('Frequency (Hz)')
    title(strcat(slc_EEG.setname,' - C4 Spectogram'))
%     ylim([20,-40]);
end
saveas(gcf,strcat(figureFolder,'\Base_spectograms.png'))
%% Plot spectogram combinations
figure;
n_columns = 3;
n_rows = 3;
n_chans = 3;
for i = 1:n_chans
    right_EEG = EEG_class_arr(1);
    left_EEG = EEG_class_arr(2);
    idle_EEG = EEG_class_arr(3);
    [frex_right,tf_right] = f_Extract_TimeFreq(right_EEG, i);
    [frex_left,tf_left] = f_Extract_TimeFreq(left_EEG, i);
    [frex_idle,tf_idle] = f_Extract_TimeFreq(idle_EEG, i);  
    title(strcat(EEG_Chans(i,:),': Right - Left'))
    subplot(n_rows ,n_columns,i);
    contourf(slc_EEG.times,frex_right,tf_right-tf_left,30,'linecolor','none')
    xlabel('Time (ms)'), ylabel('Frequency (Hz)')
    title(strcat(EEG_Chans(i,:),': Right - Idle'))
    subplot(n_rows ,n_columns,i+3);
    contourf(slc_EEG.times,frex_right,tf_right-tf_idle,30,'linecolor','none')
    xlabel('Time (ms)'), ylabel('Frequency (Hz)')
    title(strcat(EEG_Chans(i,:),': Left - Idle'))
    subplot(n_rows ,n_columns,i+6);
    contourf(slc_EEG.times,frex_right,tf_left-tf_idle,30,'linecolor','none')
    xlabel('Time (ms)'), ylabel('Frequency (Hz)')
end
saveas(gcf,strcat(figureFolder,'\Spectogram_combinations.png'))
%% Plot PSD of C4 vs C3 Channels under different epochs
% Extract all the PSD's: 
figure;
n_columns = 3;
n_rows = 2;
[C3_Arr, C4_Arr, CZ_Arr,class_names] = deal([],[],[],[]);
for i = 1:length(EEG_class_arr)
    slc_EEG = EEG_class_arr(i);
    [spectra_C3,freqs_C3] = spectopo(slc_EEG.data(1,:), 0, slc_EEG.srate, 'winsize', slc_EEG.srate, 'nfft', slc_EEG.srate, 'plot', 'off','verbose','off'); % For channel 1 (C3)
    [spectra_C4,freqs_C4] = spectopo(slc_EEG.data(2,:), 0, slc_EEG.srate, 'winsize', slc_EEG.srate, 'nfft', slc_EEG.srate, 'plot', 'off','verbose','off'); % For channel 2 (C4)
    [spectra_CZ,freqs_CZ] = spectopo(slc_EEG.data(3,:), 0, slc_EEG.srate, 'winsize', slc_EEG.srate, 'nfft', slc_EEG.srate, 'plot', 'off','verbose','off'); % For channel 1 (C3)
    subplot(n_rows,n_columns,i);
    hold on;
    plot(freqs_C3, spectra_C3);
    plot(freqs_C4, spectra_C4);
    plot(freqs_CZ, spectra_CZ);
    hold off;
    legend({'C3 Channel', 'C4 Channel','CZ Channel'})
    ylim([-30,30]) % Set the scale
    title(strcat(slc_EEG.setname,' - PSD Plot'))
    ylabel('PSD (mV^2/Hz)')
    xlabel('Frequency (Hz)')
    
    subplot(n_rows,n_columns,i+3);
    hold on;
    plot(freqs_C3, spectra_C3-spectra_C4);
    plot(freqs_C3, spectra_C4-spectra_CZ);
    plot(freqs_C3, spectra_C3-spectra_CZ);
    yline([0])
    legend({'C3-C4', 'C4-CZ ','C3-CZ','0 Line'})
    ylim([-10,10]) 
end
saveas(gcf,strcat(figureFolder,'\PSD_Channel_Diff.png'))
%% Plot classes and differences: 
figure;
n_columns = 3;
n_rows = 2;
for i = 1:length(EEG_class_arr)
    right_EEG = EEG_class_arr(1);
    left_EEG = EEG_class_arr(2);
    idle_EEG = EEG_class_arr(3);
    [spectra_right,freqs_right] = spectopo(right_EEG.data(i,:), 0, slc_EEG.srate, 'winsize', slc_EEG.srate, 'nfft', slc_EEG.srate, 'plot', 'off','verbose','off'); % For channel 1 (C3)
    [spectra_left,freqs_left] = spectopo(left_EEG.data(i,:), 0, slc_EEG.srate, 'winsize', slc_EEG.srate, 'nfft', slc_EEG.srate, 'plot', 'off','verbose','off'); % For channel 2 (C4)
    [spectra_idle,freqs_idle] = spectopo(idle_EEG.data(i,:), 0, slc_EEG.srate, 'winsize', slc_EEG.srate, 'nfft', slc_EEG.srate, 'plot', 'off','verbose','off'); % For channel 1 (C3)   
    subplot(n_rows,n_columns,i);
    hold on;
    plot(freqs_right,spectra_right);
    plot(freqs_left,spectra_left);
    plot(freqs_idle,spectra_idle);
    hold off;
    legend({'Right', 'Left','Idle'})
%     ylim([-30,30]) % Set the scale
    title(strcat('Channel ',EEG_Chans(i,:)))
    ylabel('PSD (mV^2/Hz)')
    xlabel('Frequency (Hz)')
    subplot(n_rows,n_columns,i+3);
    hold on;
    plot(freqs_right, spectra_right-spectra_left);
    plot(freqs_left, spectra_right-spectra_idle);
    plot(freqs_idle, spectra_left-spectra_idle);
    yline(0);
    legend({'R-L', 'R-I ','L-I','0 Line'})
    ylim([-10,10]) 
end
saveas(gcf,strcat(figureFolder,'\PSD_Class_Diff.png'))
%% Plot comparisons betwen
% Expectation: mu (8–12 Hz) and beta (18–26 Hz) rhythms are found to reveal 
% event-related synchronization and desynchronization (ERS/ERD) over sensorimotor cortex just like
% when one actually does the motor tasks
% spec_arr = [];
% freq_arr = [];
% 
% figure;
% for i = 1:length(EEG_class_arr)
%     subplot(1,3,1);
%     hold on;
%     slc_EEG = EEG_class_arr(i);
%     [spectra_C3,freqs_C3] = spectopo(slc_EEG.data(1,:), 0, slc_EEG.srate, 'winsize', slc_EEG.srate, 'nfft', slc_EEG.srate, 'plot', 'off','verbose','off'); % For channel 1 (C3)
%     spec_arr = [spec_arr spectra_C3];
%     freq_arr = [freq_arr freqs_C3];
%     plot(freqs_C3, spectra_C3);
%     legend({'Right', 'Left', 'Idle'})
%     title('C3 - PSD Plot Comparison')
%     ylabel('PSD (mV^2/Hz)')
%     xlabel('Frequency (Hz)')
%     hold off;
%     % For channel C4 comparison     
%     subplot(1,3,2);
%     hold on
%     [spectra_C4,freqs_C4] = spectopo(slc_EEG.data(2,:), 0, slc_EEG.srate, 'winsize', slc_EEG.srate, 'nfft', slc_EEG.srate, 'plot', 'off','verbose','off'); % For channel 2 (C4)
%     plot(freqs_C4, spectra_C4);
%     legend({'Right', 'Left', 'Idle'})
%     title('C4 - PSD Plot Comparison')
%     ylabel('PSD (mV^2/Hz)')
%     xlabel('Frequency (Hz)')
%     hold off;
%     subplot(1,3,3);
%     hold on;
%     plot(freqs_C4, spectra_C3-spectra_C4);
%     legend({'Right', 'Left', 'Idle'})
%     title('C4 - PSD Plot Comparison')
%     ylabel('PSD (mV^2/Hz)')
%     xlabel('Frequency (Hz)')
%     hold off;
% end

%%
%% Load channel location into EEG structure
n_row = 2;
figure();
% Define range of frequencies
alpha_lowerFreq  = 2; % Hz
alpha_higherFreq = 16; % Hz
beta_lowerFreq = 17;
beta_higherFreq = 25;
for i = 1:length(EEG_class_arr)
    slc_EEG = EEG_class_arr(i);
    meanPowerMicroV = zeros(slc_EEG.nbchan,1);
    for channelIdx = 1:slc_EEG.nbchan
        [psdOutDb(channelIdx,:), freq] = spectopo(slc_EEG.data(channelIdx, :), 0, slc_EEG.srate, 'plot', 'off','verbose', 'off');
        lowerFreqIdx    = find(freq==alpha_lowerFreq);
        higherFreqIdx   = find(freq==alpha_higherFreq);
        meanPowerMicroV(channelIdx) = mean(10.^((psdOutDb(channelIdx, lowerFreqIdx:higherFreqIdx))/10), 2);
    end
    subplot(n_row,3,i)
    topoplot(meanPowerMicroV, slc_EEG.chanlocs)
    title(strcat('Alpha (2-16 Hz): ',slc_EEG.setname))
    cbarHandle = colorbar;
    set(get(cbarHandle, 'title'), 'string', '(uV^2/Hz)')
    
    % Repeat for Beta
    meanPowerMicroV = zeros(slc_EEG.nbchan,1);
    for channelIdx = 1:slc_EEG.nbchan
        [psdOutDb(channelIdx,:), freq] = spectopo(slc_EEG.data(channelIdx, :), 0, slc_EEG.srate, 'plot', 'off', 'verbose', 'off');
        lowerFreqIdx    = find(freq==beta_lowerFreq);
        higherFreqIdx   = find(freq==beta_higherFreq);
        meanPowerMicroV(channelIdx) = mean(10.^((psdOutDb(channelIdx, lowerFreqIdx:higherFreqIdx))/10), 2);
    end
    subplot(n_row,3,i+3)
    topoplot(meanPowerMicroV, slc_EEG.chanlocs)
    title(strcat('Beta (17-25 Hz): ',slc_EEG.setname))
    cbarHandle = colorbar;
    set(get(cbarHandle, 'title'), 'string', '(uV^2/Hz)')
end
%%
% This example code compares PSD in dB (left) vs. uV^2/Hz (right) rendered as scalp topography (setfile must be loaded.)
end