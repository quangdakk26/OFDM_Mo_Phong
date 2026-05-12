%% OFDM Online Demo Script
% Quick demonstration of OFDM simulation for MATLAB Online
% This script runs a single OFDM simulation with default parameters

clear all; close all; clc;

fprintf('OFDM Simulation Demo - MATLAB Online\n');
fprintf('=====================================\n\n');

%% Parameters
B = 20e6;           % Bandwidth (Hz)
N = 256;            % FFT size
nbPilots = 16;      % Pilot subcarriers
nbZeros = N/8;      % Guard band zeros
SNR_dB = 20;        % Signal-to-Noise Ratio (dB)
M = 4;              % Modulation order (2^4 = 16-QAM)
numSymbols = 10;    % Number of OFDM symbols

fprintf('Parameters:\n');
fprintf('  Bandwidth: %.1f MHz\n', B/1e6);
fprintf('  FFT Size: %d\n', N);
fprintf('  Pilot Subcarriers: %d\n', nbPilots);
fprintf('  Modulation: %d-QAM (M=%d)\n', 2^M, M);
fprintf('  SNR: %d dB\n', SNR_dB);
fprintf('  OFDM Symbols: %d\n\n', numSymbols);

%% Run simulation
fprintf('Running simulation...\n');
[BER, debit] = OFDM_simulation(N, nbPilots, nbZeros, SNR_dB, M, numSymbols);

%% Display results
fprintf('\nResults:\n');
fprintf('  Bit Error Rate (BER): %.4e\n', BER);
fprintf('  Data Rate (debit): %.2e bits/sec\n', debit);
fprintf('  Throughput: %.2f Mbps\n', debit/1e6);

%% Additional analysis
fprintf('\nAdditional Metrics:\n');
Ts = N / B;
nCycle = ceil(1e-7 * N / Ts);
fprintf('  Symbol Duration: %.2f µs\n', Ts*1e6);
fprintf('  Cyclic Prefix Length: %d samples\n', nCycle);
fprintf('  Data Subcarriers: %d\n', N - nbZeros - nbPilots);

fprintf('\nDemo complete! Customize parameters in demo.m to run different scenarios.\n');
