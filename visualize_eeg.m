function visualize_eeg(EEG, EEG_data, save_folder, fig_name)
%% Plot a snippet of EEG data from the first 8 channels
figure;
for channel_i = 1:8
    subplot(8,1,channel_i)
    plot(EEG_data(channel_i,1000:2000))
    xlim([0,1000])
    ylabel(num2str(channel_i))
end
xlabel('Time(s)')
%% Plot average trace across channels
figure;
plot(EEG.times,squeeze(mean(EEG_data)),'linew',2)
title('Average trace')
xlabel('Time (s)'), ylabel('Voltage (\muV)')
xlim([0,1000])

%% Butterfly plot of different channels
figure;
plot(EEG.times./EEG.srate, EEG_data,'linew',2)
title('Prior data')
xlabel('Time (s)'), ylabel('Voltage (\muV)')
xlim([0,1000])

%%
% Use EEGLAB's spectopo() function.
[spectra1,freqs1] = spectopo(EEG_data(1,:), 0, EEG.srate, 'winsize', EEG.srate, 'nfft', EEG.srate, 'plot', 'off'); % For channel 2 (C4)
% [spectra1,freqs1] = spectopo(pre_EEG(1,:), 0, EEG.srate, 'winsize', EEG.srate, 'nfft', EEG.srate, 'plot', 'off'); % For channel 2 (C4)
% spectra1 = 10.^(spectra1/10); 
figure
plot(freqs1, spectra1); 
% plot(freqs2, spectra2)
legend({'Prior preprocess', 'After preprocess'})
title('PSD Plot')
ylabel('PSD (mV^2/Hz)')
xlabel('Frequency (Hz)')

%% Save the figures 
FolderName = save_folder;   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = strcat(fig_name, num2str(get(FigHandle, 'Number')), '_figure');
  set(0, 'CurrentFigure', FigHandle);
  savefig(fullfile(FolderName, [FigName '.fig']));
end
end

