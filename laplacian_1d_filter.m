function [EEG_afterLap] = laplacian_1d_filter(EEG_data, main_chan_ind, neighbors_arry)
    %% Returns laplacian 1d filtered EEG data
    EEG_afterLap = EEG_data;
    weighted = 1/length(neighbors_arry);
    EEG_After_laplace = EEG_data(main_chan_ind,:) - weighted.*(sum(EEG_data(neighbors_arry,:)));
    EEG_afterLap(main_chan_ind,:)=EEG_After_laplace;
end
