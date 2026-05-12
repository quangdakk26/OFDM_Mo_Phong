function [BER_result, debit_result] = OFDM_simulation(N, nbPilots, nbZeros, SNR_dB, M, numSymbols)
    % OFDM Simulation Engine
    % Simulates OFDM transmission with channel estimation using pilots
    % 
    % Inputs:
    %   N           - FFT size
    %   nbPilots    - Number of pilot subcarriers
    %   nbZeros     - Number of guard band zeros
    %   SNR_dB      - Signal-to-Noise Ratio (dB)
    %   M           - Modulation order (2^M symbols)
    %   numSymbols  - Number of OFDM symbols to transmit
    %
    % Outputs:
    %   BER_result  - Bit Error Rate
    %   debit_result - Data rate (bits/sec)
    
    if nargin < 6
        numSymbols = 10;  % Default: 10 OFDM symbols
    end
    
    % Parameters
    B = 20e6;                    % Bandwidth
    Ts = N / B;                  % Symbol duration
    delayMax = 1e-7;             % Maximum channel delay
    nCycle = ceil(delayMax * N / Ts);  % Cyclic prefix length
    
    % Useful subcarriers
    nUtile = N - (nbZeros + nbPilots);
    nTotal = N + nCycle;
    
    % Data rate
    debit_result = M * nUtile / Ts;
    
    % Modulation parameters
    M_symbols = 2^M;
    nbBits = N * numSymbols * M;
    
    % Generate random binary data
    bits = randi([0 1], nbBits, 1);
    
    % QAM Modulation
    symbols = qammod(bits, M_symbols, 'InputType', 'bit', 'UnitAveragePower', true);
    
    % Reshape for OFDM processing
    symbols_matrix = reshape(symbols, nUtile, numSymbols);
    
    % Initialize outputs
    RX_bits = [];
    
    % OFDM Transmission and Reception
    for symIdx = 1:numSymbols
        % ---- TRANSMITTER ----
        
        % Get data symbols for this OFDM symbol
        data_subcarriers = symbols_matrix(:, symIdx);
        
        % Create pilot subcarriers (known symbols)
        pilot_indices = round(linspace(1, N-nbZeros, nbPilots));
        pilot_symbols = ones(nbPilots, 1);  % Use ones as known pilots
        
        % Create frequency domain signal
        freq_signal = zeros(N, 1);
        freq_signal(1:nUtile) = data_subcarriers;
        
        % Add pilots (for channel estimation)
        for p = 1:nbPilots
            freq_signal(pilot_indices(p)) = pilot_symbols(p);
        end
        
        % IFFT to time domain
        time_signal = ifft(freq_signal) * sqrt(N);
        
        % Add cyclic prefix
        tx_signal = [time_signal(end-nCycle+1:end); time_signal];
        
        % ---- CHANNEL ----
        
        % Rayleigh fading channel with delay
        channel_delay = round(rand() * (nCycle - 1)) + 1;  % Delay within CP
        h_fading = (randn() + 1j*randn()) / sqrt(2);       % Rayleigh coefficient
        
        % Channel impulse response
        channel_response = zeros(nCycle + 1, 1);
        channel_response(channel_delay) = h_fading;
        
        % Convolve with channel (simplified - no circular convolution)
        rx_signal = conv(tx_signal, channel_response, 'same');
        
        % ---- ADD NOISE ----
        
        SNR_linear = 10^(SNR_dB/10);
        signal_power = mean(abs(rx_signal).^2);
        noise_power = signal_power / SNR_linear;
        noise = sqrt(noise_power/2) * (randn(length(rx_signal), 1) + 1j*randn(length(rx_signal), 1));
        rx_signal = rx_signal + noise;
        
        % ---- RECEIVER ----
        
        % Remove cyclic prefix
        rx_signal_no_cp = rx_signal(nCycle+1:end);
        
        % FFT
        freq_received = fft(rx_signal_no_cp) / sqrt(N);
        
        % Simple 1-tap channel estimation using pilot symbols
        pilot_received = freq_received(pilot_indices);
        channel_est = mean(pilot_received ./ pilot_symbols);  % Average channel estimate
        
        % Channel equalization
        freq_equalized = freq_received(1:nUtile) / channel_est;
        
        % QAM Demodulation
        rx_symbols = freq_equalized;
        demod_bits = qamdemod(rx_symbols, M_symbols, 'OutputType', 'bit', 'UnitAveragePower', true);
        
        RX_bits = [RX_bits; demod_bits];
    end
    
    % Calculate BER
    BER_result = sum(abs(bits(1:length(RX_bits)) - RX_bits)) / length(RX_bits);
    
end
