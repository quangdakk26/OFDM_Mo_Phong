% OFDM Online - Initialization Script
% Compatible with MATLAB Online (no toolbox required)

% Global parameters
global B N nbPilots nbZeros SNR_ delayMax M
global Ts nUtile nCycle nTotal W debit

B        = 20e6;    % Bandwidth (Hz)
N        = 2048;    % FFT size
nbPilots = 32;      % Number of pilot subcarriers
nbZeros  = N/8;     % Guard band (zero) subcarriers
SNR_     = 20;      % Signal-to-Noise Ratio (dB)
delayMax = 1e-7;    % Maximum multipath delay (s)
M        = 3;       % Modulation order (2^M -QAM  =>  8-QAM)

% Derived parameters
Ts     = N / B;                      % OFDM symbol duration (s)
nUtile = N - (nbZeros + nbPilots);   % Useful data subcarriers
nCycle = delayMax * N / Ts;          % Cyclic prefix length (samples)
nTotal = N + nCycle;                 % Total samples per symbol

W     = (nUtile + nbPilots) / nTotal^2;  % Power normalisation factor
debit = M * nUtile / Ts;                 % Data rate (bits/s)
