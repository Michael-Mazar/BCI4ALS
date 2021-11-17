function [EEG_afterLap] = laplacian_1d_filter(EEG)
    %% Returns laplacian 1d filtered EEG data
    laplacian_filter = [-0.5, 1, -0.5];
    EEG_afterLap = EEG.data;
    for chan_i=1:EEG.nbchan
        if chan_i == 3 || chan_i == 4
            signal = EEG_afterLap(chan_i,:);
            filtered_signal = conv(signal, laplacian_filter);
            filtered_signal = filtered_signal(2:end);
            filtered_signal = filtered_signal(1:end-1);  
            EEG_afterLap(chan_i,:) = filtered_signal;
        end
    end 
end 
