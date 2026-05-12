% OFDM Performance Tests - MATLAB Online Version
% This script performs batch simulations with various parameters
% and saves results in MATLAB Online-compatible format

clear all;
close all;
clc;

% Suppress warnings
w = warning('query', 'last');
warning('off', w.identifier);

% Initialize parameters
init;

fprintf('Starting OFDM Performance Analysis\n');
fprintf('==================================\n\n');

% Results storage
all_results = {};
result_index = 1;

% Simulation parameters
B = 20e6;
delayMax = 1e-7;

% Loop over modulation schemes
modulations = [2, 3, 4, 5, 6, 7, 8];  % M values (QPSK, 8PSK, 16QAM, 32QAM, 64QAM, 128QAM, 256QAM)
numSymbols = 5;  % Reduced for faster simulation (online constraint)

for M = modulations
    QAM = 2^M;
    fprintf('Processing %d-QAM Modulation...\n', QAM);
    
    result = [];
    sim_count = 1;
    
    % Loop over FFT sizes
    N_values = [32, 64, 128, 256, 512, 1024, 2048];  % Reduced from original for faster runs
    
    for N = N_values
        nbZeros = N/8;
        
        % Pilot values (powers of 2)
        powersOfTwo = 2.^(1:floor(log2(N/4)));
        
        for nbPilots = powersOfTwo
            % SNR values
            for SNR_ = [10, 15, 20, 25, 30]
                try
                    % Set parameters
                    setMyParams(B, N, nbPilots, nbZeros, SNR_, delayMax, M);
                    
                    % Run simulation
                    [BER, debit] = OFDM_simulation(N, nbPilots, nbZeros, SNR_, M, numSymbols);
                    
                    % Store results
                    result = [result; N, nbPilots, SNR_, BER, debit];
                    
                    % Display progress
                    if mod(sim_count, 5) == 0
                        progression = (sim_count / 100) * 100;  % Approximate progression
                        fprintf('   N=%d, pilots=%d, SNR=%ddB, BER=%.4e, debit=%.2e (%.0f%% of batch)\n', ...
                            N, nbPilots, SNR_, BER, debit, progression);
                    end
                    
                    sim_count = sim_count + 1;
                    
                catch ME
                    fprintf('   Warning: Simulation failed for N=%d, pilots=%d, SNR=%d\n', ...
                        N, nbPilots, SNR_);
                    fprintf('   Error: %s\n', ME.message);
                end
            end
        end
    end
    
    % Store results for this modulation
    all_results{result_index}.modulation = QAM;
    all_results{result_index}.result = result;
    result_index = result_index + 1;
    
    fprintf('Completed %d-QAM with %d simulations\n\n', QAM, size(result, 1));
end

fprintf('\nSimulation Complete!\n');
fprintf('====================\n');

% Save results (MATLAB Online compatible)
try
    % Save as MAT file
    save('OFDM_results.mat', 'all_results');
    fprintf('Results saved to: OFDM_results.mat\n');
    
    % Export to table format for easy viewing
    fprintf('\nResults Summary:\n');
    for idx = 1:length(all_results)
        mod_name = sprintf('%d-QAM', all_results{idx}.modulation);
        fprintf('  %s: %d simulations\n', mod_name, size(all_results{idx}.result, 1));
    end
    
catch ME
    fprintf('Note: Could not save files - typical for MATLAB Online\n');
    fprintf('Results stored in memory (all_results variable)\n');
end

% Clear warnings
warning('on', w.identifier);
fprintf('\nDone!\n');
