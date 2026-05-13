%% OFDM Online Demo Script
% Quick demonstration of OFDM simulation for MATLAB Online.
% Runs a single OFDM simulation with default parameters.
%
% NO TOOLBOX REQUIRED – uses local qam_mod / qam_demod helpers.

clear all; close all; clc;

fprintf('OFDM Simulation Demo - MATLAB Online\n');
fprintf('=====================================\n\n');

%% Parameters
B          = 20e6;   % Bandwidth (Hz)
N          = 256;    % FFT size
nbPilots   = 16;     % Pilot subcarriers
nbZeros    = N/8;    % Guard-band zeros
SNR_dB     = 20;     % Signal-to-Noise Ratio (dB)
M          = 4;      % Bits/symbol  (2^4 = 16-QAM)
numSymbols = 10;     % Number of OFDM symbols

fprintf('Parameters:\n');
fprintf('  Bandwidth:           %.1f MHz\n', B/1e6);
fprintf('  FFT Size:            %d\n',       N);
fprintf('  Pilot Subcarriers:   %d\n',       nbPilots);
fprintf('  Modulation:          %d-QAM (M=%d)\n', 2^M, M);
fprintf('  SNR:                 %d dB\n',    SNR_dB);
fprintf('  OFDM Symbols:        %d\n\n',     numSymbols);

%% Run single simulation
fprintf('Running simulation...\n');
[BER, debit] = OFDM_simulation(N, nbPilots, nbZeros, SNR_dB, M, numSymbols);

%% Display results
fprintf('\nResults:\n');
fprintf('  Bit Error Rate (BER):  %.4e\n',  BER);
fprintf('  Data Rate (debit):     %.2e bits/s\n', debit);
fprintf('  Throughput:            %.2f Mbps\n',   debit/1e6);

%% BER vs SNR curve
fprintf('\nGenerating BER vs SNR curve...\n');
snr_range = 0:5:30;
BER_curve = zeros(size(snr_range));
for k = 1:length(snr_range)
    BER_curve(k) = OFDM_simulation(N, nbPilots, nbZeros, snr_range(k), M, numSymbols);
end

figure;
semilogy(snr_range, max(BER_curve, 1e-6), '-o', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
title(sprintf('BER vs SNR  (%d-QAM, N=%d)', 2^M, N));
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
set(gca, 'FontSize', 12);

%% Additional metrics
fprintf('\nAdditional Metrics:\n');
Ts     = N / B;
nCycle = ceil(1e-7 * N / Ts);
fprintf('  Symbol Duration:    %.2f µs\n',   Ts*1e6);
fprintf('  Cyclic Prefix:      %d samples\n', nCycle);
fprintf('  Data Subcarriers:   %d\n',         N - nbZeros - nbPilots);

fprintf('\nDemo complete! Edit demo.m to run different scenarios.\n');
