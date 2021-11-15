function [filtered_signal] = laplacian_1d_filter(signal)
    laplacian_filter = [-0.5, 1, -0.5];
    filtered_signal = conv(signal, laplacian_filter);
end