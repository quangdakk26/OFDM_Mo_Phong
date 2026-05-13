% OFDM Performance Tests - MATLAB Online Version
% Batch simulations across modulation orders, FFT sizes, pilot counts, and
% SNR levels.  Results are saved to OFDM_results.mat.
%
% NO TOOLBOX REQUIRED – uses local qam_mod / qam_demod helpers.

clear all; close all; clc;

% Suppress any stray warnings (e.g., from randi with small seeds)
ws = warning('off', 'all');

% Initialise global parameters
init;

fprintf('Starting OFDM Performance Analysis\n');
fprintf('==================================\n\n');

%% Simulation settings
B          = 20e6;   % Bandwidth (Hz)
delayMax   = 1e-7;   % Max multipath delay (s)
numSymbols = 5;      % Symbols per run (keep small for MATLAB Online speed)

% Modulation orders to sweep  (M = bits/symbol -> 2^M -QAM)
modulations = [2, 3, 4, 5, 6, 7, 8];

% FFT sizes to sweep
N_values = [32, 64, 128, 256, 512, 1024, 2048];

% SNR values (dB)
SNR_values = [10, 15, 20, 25, 30];

%% Storage
all_results  = {};
result_index = 1;

%% Main sweep
for M = modulations
    QAM = 2^M;
    fprintf('Processing %d-QAM (M=%d)...\n', QAM, M);

    result    = [];
    sim_count = 0;

    for N = N_values
        nbZeros = N / 8;

        % Pilot counts: powers of two up to N/4
        powersOfTwo = 2 .^ (1 : floor(log2(N/4)));

        for nbPilots = powersOfTwo

            % Skip degenerate configurations
            nUtile = N - nbZeros - nbPilots;
            if nUtile <= 0
                continue;
            end

            for SNR_ = SNR_values
                try
                    % Update derived parameters
                    setMyParams(B, N, nbPilots, nbZeros, SNR_, delayMax, M);

                    % Run simulation
                    [BER, debit] = OFDM_simulation(N, nbPilots, nbZeros, ...
                                                   SNR_, M, numSymbols);

                    % Accumulate  [N, nbPilots, SNR, BER, debit]
                    result    = [result; N, nbPilots, SNR_, BER, debit]; %#ok<AGROW>
                    sim_count = sim_count + 1;

                    % Progress report every 5 simulations
                    if mod(sim_count, 5) == 0
                        fprintf('   N=%4d | pilots=%3d | SNR=%2d dB | BER=%.3e | debit=%.2e bps\n', ...
                            N, nbPilots, SNR_, BER, debit);
                    end

                catch ME
                    fprintf('   [WARN] Skipped N=%d, pilots=%d, SNR=%d dB: %s\n', ...
                        N, nbPilots, SNR_, ME.message);
                end
            end  % SNR loop
        end  % pilot loop
    end  % N loop

    % Store this modulation's results
    all_results{result_index}.modulation = QAM;   %#ok<AGROW>
    all_results{result_index}.result     = result; %#ok<AGROW>
    result_index = result_index + 1;

    fprintf('  -> Completed %d-QAM: %d simulations\n\n', QAM, sim_count);
end

%% Save results
fprintf('Simulation Complete!\n');
fprintf('====================\n');

try
    save('OFDM_results.mat', 'all_results');
    fprintf('Results saved to: OFDM_results.mat\n');
catch
    fprintf('Note: Could not write file (normal on some MATLAB Online configurations).\n');
    fprintf('Results available in workspace variable: all_results\n');
end

%% Summary table
fprintf('\nResults Summary:\n');
fprintf('  %-12s  %s\n', 'Modulation', '# Simulations');
fprintf('  %s\n', repmat('-', 1, 30));
for idx = 1:length(all_results)
    fprintf('  %-12s  %d\n', ...
        sprintf('%d-QAM', all_results{idx}.modulation), ...
        size(all_results{idx}.result, 1));
end

% Restore warning state
warning(ws);
fprintf('\nDone!\n');
