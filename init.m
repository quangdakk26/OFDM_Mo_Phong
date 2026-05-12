% OFDM Online - Initialization Script
% Compatible with MATLAB Online

% Global parameters
global B N nbPilots nbZeros SNR_ delayMax M
global Ts nUtile nCycle nTotal W debit

B = 20e6;           % Bandwidth
N = 2048;           % FFT size
nbPilots = 32;      % Number of pilot subcarriers
nbZeros = N/8;      % Guard band (zeros)
SNR_ = 20;          % Signal-to-Noise Ratio (dB)
delayMax = 1e-7;    % Maximum delay
M = 3;              % Modulation order (2^M = 8 symbols)

% Derived parameters
Ts = N/B;           % Symbol duration

nUtile = N - (nbZeros + nbPilots);  % Useful data subcarriers
nCycle = delayMax * N / Ts;         % Cyclic prefix length
nTotal = N + nCycle;                % Total symbols (FFT + CP)

W = (nUtile + nbPilots) / nTotal^2; % Power normalization
debit = M * nUtile / Ts;            % Data rate (bits/sec)
