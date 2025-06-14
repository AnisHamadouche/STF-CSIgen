function load_and_plot_sample(filename, set_type)
%LOAD_AND_PLOT_SAMPLE Loads a CSI dataset and visualizes a random sample.
%
%   load_and_plot_sample('D1_csi.mat', 'train')
%   load_and_plot_sample('D1_csi.mat', 'val')
%   load_and_plot_sample('D1_csi.mat', 'test')
%
% Inputs:
%   filename  - Name of .mat file (e.g., 'D1_csi.mat')
%   set_type  - 'train', 'val', or 'test'
%
% This function will display:
%   - Amplitude [dB] for a random time frame of a random sample
%   - (Optional) Amplitude evolution over time for a random (antenna, subcarrier) pair

    if nargin < 2
        set_type = 'train'; % Default
    end

    % Load the file
    S = load(filename);
    switch lower(set_type)
        case 'train'
            csi = S.train_csi;
        case 'val'
            csi = S.val_csi;
        case 'test'
            csi = S.test_csi;
        otherwise
            error('Unknown set_type: %s', set_type);
    end

    [nAnt, K, T, N] = size(csi);

    % Select a random sample and time frame
    s = randi(N);
    t = randi(T);

    % Extract the sample
    H = csi(:, :, :, s); % [nAnt, K, T]
    H_frame = H(:, :, t); % [nAnt, K]
    H_amp_dB = 20*log10(abs(H_frame) + 1e-9); % Avoid log(0)

    % Plot 1: Heatmap of amplitude for a time frame
    figure('Name', sprintf('%s: sample %d, frame %d', filename, s, t), ...
           'NumberTitle','off');
    imagesc(H_amp_dB);
    xlabel('Subcarrier index');
    ylabel('Antenna index');
    colorbar;
    title(sprintf('Amplitude [dB]: %s, %s set, sample %d, frame %d', filename, set_type, s, t));
    set(gca, 'YDir', 'normal');

    % Plot 2: Amplitude vs time for a random antenna and subcarrier
    rand_ant = randi(nAnt);
    rand_k = randi(K);
    H_time = squeeze(H(rand_ant, rand_k, :)); % [T, 1]
    H_time_dB = 20*log10(abs(H_time) + 1e-9);

    figure('Name', sprintf('%s: Amp vs Time, ant %d, sc %d', filename, rand_ant, rand_k), ...
           'NumberTitle','off');
    plot(1:T, H_time_dB, 'o-');
    xlabel('Time index');
    ylabel('Amplitude [dB]');
    title(sprintf('Amplitude vs Time: %s, %s set, sample %d, ant %d, sc %d', ...
        filename, set_type, s, rand_ant, rand_k));
    grid on;

    % Optionally print statistics
    fprintf('\nLoaded %s | set: %s | sample: %d/%d | nAnt = %d, K = %d, T = %d\n', ...
        filename, set_type, s, N, nAnt, K, T);
end

