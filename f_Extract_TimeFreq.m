function [frex,tf] = f_Extract_TimeFreq(EEG, chan)
%% Time-frequency analysis
% frequencies in Hz (hard-coded to 2 to 30 in 40 steps)
frex  = linspace(5,30,40);

% number of wavelet cycles (hard-coded to 3 to 10)
waves = 2*(linspace(3,10,length(frex))./(2*pi*frex)).^2;

% setup wavelet and convolution parameters
wavet = -2:1/EEG.srate:2;
halfw = floor(length(wavet)/2)+1;
nConv = EEG.pnts*EEG.trials + length(wavet) - 1;

% initialize time-frequency matrix
tf = zeros(length(frex),EEG.pnts);

% spectrum of data
dataX = fft(reshape(EEG.data(chan,:,:),1,[]),nConv);

% loop over frequencies
for fi=1:length(frex)
    
    % create wavelet
    waveX = fft( exp(2*1i*pi*frex(fi)*wavet).*exp(-wavet.^2/waves(fi)),nConv );
    waveX = waveX./max(waveX); % normalize
    
    % convolve
    as = ifft( waveX.*dataX );
    % trim and reshape
    as = reshape(as(halfw:end-halfw+1),[EEG.pnts EEG.trials]);
    
    % power
    tf(fi,:) = mean(abs(as),2);
end

end