%% WiFo 3D CSI Dataset Generator (CPU Version)
close all; clearvars; clc;

addpath('/home/anis/Documents/QuaDriGa_2023.12.13_v2.8.1-0/quadriga_src/'); % <--- Edit your path!

% ---- Dataset Table ----
dataset_info = {...
% D   fC   K  df   T  dt   UPA     Scenario        vmin vmax
  1,  1.5,128, 90, 24, 1,  [1,4],  'UMi+NLoS',     3,   50;
  2,  1.5,128,180, 24,0.5, [2,4],  'RMa+NLoS',     120, 300;
  3,  1.5, 64, 90, 16, 1,  [1,8],  'Indoor+LoS',   0,   10;
  4,  1.5, 32,180, 16,0.5, [4,8],  'UMa+LoS',      30,  100;
  5,  2.5, 64,180, 24,0.5, [2,2],  'RMa+NLoS',     120, 300;
  6,  2.5,128, 90, 24, 1,  [2,4],  'UMi+LoS',      3,   50;
  7,  2.5, 32,360, 16,0.5, [4,8],  'UMa+LoS',      30,  100;
  8,  2.5, 64, 90, 16, 1,  [4,4],  'Indoor+NLoS',  0,   10;
  9,  4.9,128,180, 24, 1,  [1,4],  'UMi+NLoS',     3,   50;
 10,  4.9, 64,180, 24,0.5, [2,4],  'RMa+LoS',      120, 300;
 11,  4.9, 64, 90, 16,0.5, [4,4],  'UMa+NLoS',     30,  100;
 12,  4.9, 32,180, 16, 1,  [4,8],  'Indoor+LoS',   0,   10;
 13,  5.9, 64, 90, 24,0.5, [2,8],  'RMa+LoS',      120, 300;
 14,  5.9,128,180, 24, 1,  [2,4],  'UMi+NLoS',     3,   50;
 15,  5.9, 64, 90, 16, 1,  [4,4],  'Indoor+LoS',   0,   10;
 16,  5.9, 32,360, 16,0.5, [4,8],  'UMa+NLoS',     30,  100;
 17,  3.5, 32,180, 16,0.5, [4,8],  'UMa+NLoS',     30,  100;
 18,  6.7, 64,180, 24, 1,  [4,4],  'UMi+LoS',      3,   50;
 19, 28.0, 32,360, 16,0.25,[4,8],  'UMa+LoS',      30,  100;
};
N_DATASETS = size(dataset_info,1);

% ---- Split indices ----
N_SAMPLES = 12000;
train_idx = 1:9000; val_idx = 9001:10000; test_idx = 10001:12000;

% for d = 1:N_DATASETS
for d = 11:N_DATASETS 
    fprintf('\n==== Generating Dataset D%d ====\n',d);
    % ---- Extract config ----
    fC = dataset_info{d,2}*1e9;
    K  = dataset_info{d,3};
    df = dataset_info{d,4}*1e3;
    T  = dataset_info{d,5};
    dt = dataset_info{d,6}*1e-3;
    upa= dataset_info{d,7};
    sc = getScenarioName(dataset_info{d,8});
    vmin=dataset_info{d,9}/3.6;
    vmax=dataset_info{d,10}/3.6;
    nAnt = prod(upa);  % Number of antennas (single polarization)

    % ---- Preallocate ----
    csi_data = zeros(nAnt, K, T, N_SAMPLES, 'single');
    
    % ---- Generate Samples (CPU, sequential) ----
     for s = 1:N_SAMPLES
        % -- Random initial position --
        x0 = rand*400-200; y0 = rand*400-200; z0 = 1.5;
        % -- Random speed and direction --
        v = vmin + rand*(vmax-vmin);
        phi = rand*2*pi;
        % -- Track Setup --
        total_length = v * dt * (T-1);
        track = qd_track('linear', total_length, phi);
        track.no_snapshots = T;
        track.initial_position = [x0; y0; z0];
        
        % -- Compute Rx positions for all timesteps --
        rx_positions = zeros(T,3);
        for t = 1:T
            rx_positions(t,:) = [x0 + v*dt*(t-1)*cos(phi), ...
                                 y0 + v*dt*(t-1)*sin(phi), z0];
        end
    
        % --- Display info (first 3 samples, and every 1000th) ---
        if s<=3 || mod(s,1000)==1
            fprintf('\n[Dataset D%d] Sample %d/%d\n', d, s, N_SAMPLES);
            fprintf('  fC = %.2f GHz, K = %d, df = %d kHz, T = %d, dt = %.3f ms\n', ...
                fC/1e9, K, df/1e3, T, dt*1e3);
            fprintf('  Init Rx position: [%.2f, %.2f, %.2f] (m), speed = %.2f m/s, angle = %.1f deg\n', ...
                x0, y0, z0, v, phi*180/pi);
            disp('  Rx positions at first three timesteps:');
            disp(rx_positions(1:min(3,T),:));
            if T>3, fprintf('  ... (%d total steps)\n', T); end
        end
    
        % -- QuaDRiGa Layout --
        sparam = qd_simulation_parameters;
        sparam.center_frequency = fC;
        sparam.sample_density = 4;
        l = qd_layout(sparam);
        l.no_rx = 1;
        l.rx_track = track;
        l.tx_position = [0; 0; 25];
        l.tx_array = qd_arrayant('3gpp-3d', upa(1), upa(2), fC, 2, 8);  % 2 polarizations, 8 deg tilt
        l.rx_array = qd_arrayant('omni');
        l.set_scenario(sc);
        % -- Generate Channel --
        c = l.get_channels;
        H = c(1,1).fr(df*K, K);   % [1, nAnt_total, K, T]
        H = squeeze(H);           % [nAnt_total, K, T]
    
        % --- Only use the first polarization ---
        nAnt_total = size(H,1);
        if nAnt_total == prod(upa)*2
            H = H(1:2:end, :, :); % Keep only one pol (vertical)
        end
    
        % --- Robust shape check ---
        if ~isequal(size(H), [nAnt, K, T])
            error('After squeeze, H shape is [%s] but expected [%d %d %d]', ...
                num2str(size(H)), nAnt, K, T);
        end
        
        csi_data(:,:,:,s) = single(H);
    
        if mod(s,1000)==0, fprintf('.'); end
    end

    fprintf(' done\n');
    
    % ---- Standardize + Add Noise ----
    data_mean = mean(csi_data, 4, 'omitnan');
    data_std  = std(csi_data, 0, 4, 'omitnan');
    for s = 1:N_SAMPLES
        x = (csi_data(:,:,:,s) - data_mean) ./ (data_std + 1e-6);
        % Add complex Gaussian noise, 20 dB SNR
        sig_pow = mean(abs(x(:)).^2);
        noise_pow = sig_pow/10^(20/10);
        noise = sqrt(noise_pow/2)*(randn(size(x)) + 1j*randn(size(x)));
        csi_data(:,:,:,s) = x + noise;
    end

    % ---- Split & Save ----
    train_csi = csi_data(:,:,:,train_idx);
    val_csi   = csi_data(:,:,:,val_idx);
    test_csi  = csi_data(:,:,:,test_idx);
    
    % Ensure ./data/ exists!
    if ~exist('./data', 'dir'), mkdir('./data'); end
    dataset_name = sprintf('./data/D%d_csi.mat', d);
     
    save(dataset_name, 'train_csi', 'val_csi', 'test_csi', 'data_mean', 'data_std', '-v7.3');
    fprintf('Saved %s\n', dataset_name);
end

%% Helper: scenario string mapping
function scenario_name = getScenarioName(scenestr)
    if contains(scenestr,'UMi')
        if contains(scenestr,'NLoS'), scenario_name = '3GPP_38.901_UMi_NLOS';
        else, scenario_name = '3GPP_38.901_UMi_LOS'; end
    elseif contains(scenestr,'UMa')
        if contains(scenestr,'NLoS'), scenario_name = '3GPP_38.901_UMa_NLOS';
        else, scenario_name = '3GPP_38.901_UMa_LOS'; end
    elseif contains(scenestr,'RMa')
        if contains(scenestr,'NLoS'), scenario_name = '3GPP_38.901_RMa_NLOS';
        else, scenario_name = '3GPP_38.901_RMa_LOS'; end
    elseif contains(scenestr,'Indoor')
        if contains(scenestr,'NLoS'), scenario_name = '3GPP_38.901_Indoor_NLOS';
        else, scenario_name = '3GPP_38.901_Indoor_LOS'; end
    else
        scenario_name = '3GPP_38.901_UMi_LOS';
    end
end

