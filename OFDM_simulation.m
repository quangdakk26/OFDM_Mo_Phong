function [BER_result, debit_result] = OFDM_simulation(N, nbPilots, nbZeros, SNR_dB, M, numSymbols)
% OFDM_SIMULATION  OFDM transceiver simulation (no toolbox required)
%
% [BER_result, debit_result] = OFDM_simulation(N, nbPilots, nbZeros,
%                                               SNR_dB, M, numSymbols)
%
% Inputs:
%   N          - FFT size
%   nbPilots   - Number of pilot subcarriers
%   nbZeros    - Number of guard-band (zero) subcarriers
%   SNR_dB     - Signal-to-Noise Ratio (dB)
%   M          - Bits per symbol  (2^M -QAM, e.g. M=2 -> 4-QAM/QPSK)
%   numSymbols - Number of OFDM symbols to transmit
%
% Outputs:
%   BER_result   - Bit Error Rate
%   debit_result - Spectral data-rate (bits/s)
%
% NOTE: Uses local qam_mod / qam_demod helpers instead of Communications
%       Toolbox so the script runs on MATLAB Online without extra licences.

    if nargin < 6
        numSymbols = 10;
    end

    %% ------------------------------------------------------------------ %%
    %% Derived parameters                                                   %%
    %% ------------------------------------------------------------------ %%
    B        = 20e6;                          % System bandwidth (Hz)
    Ts       = N / B;                         % OFDM symbol duration (s)
    delayMax = 1e-7;                          % Max multipath delay (s)
    nCycle   = ceil(delayMax * N / Ts);       % Cyclic prefix length (samples)

    nUtile       = N - (nbZeros + nbPilots);  % Data subcarriers per symbol
    debit_result = M * nUtile / Ts;           % Data rate (bits/s)

    M_order = 2^M;                            % Constellation size

    %% ------------------------------------------------------------------ %%
    %% Bit generation                                                       %%
    %% ------------------------------------------------------------------ %%
    nbBits = nUtile * numSymbols * M;         % Total transmitted bits
    tx_bits = randi([0 1], nbBits, 1);

    %% ------------------------------------------------------------------ %%
    %% QAM modulation (no toolbox)                                          %%
    %% ------------------------------------------------------------------ %%
    tx_symbols = qam_mod(tx_bits, M_order);            % length = nUtile*numSymbols
    symbols_mat = reshape(tx_symbols, nUtile, numSymbols);

    %% ------------------------------------------------------------------ %%
    %% Pilot indices (evenly spread across non-zero subcarriers)            %%
    %% ------------------------------------------------------------------ %%
    pilot_indices  = round(linspace(1, N - nbZeros, nbPilots));
    pilot_symbols  = ones(nbPilots, 1);       % Known pilot values

    %% ------------------------------------------------------------------ %%
    %% Per-symbol OFDM loop                                                 %%
    %% ------------------------------------------------------------------ %%
    rx_bits_all = zeros(nbBits, 1);

    for symIdx = 1:numSymbols

        %% ---------- TRANSMITTER ---------- %%

        % Build frequency-domain frame
        freq_tx = zeros(N, 1);
        freq_tx(1:nUtile) = symbols_mat(:, symIdx);

        % Insert pilots (overwrite any data positions that coincide)
        freq_tx(pilot_indices) = pilot_symbols;

        % OFDM modulation: IFFT -> time domain
        time_tx = ifft(freq_tx) * sqrt(N);

        % Add cyclic prefix
        tx_cp = [time_tx(end - nCycle + 1 : end); time_tx];

        %% ---------- CHANNEL ---------- %%

        % Single-tap Rayleigh fading with random delay inside the CP
        ch_delay = randi([1, max(1, nCycle)]);
        h_ray    = (randn() + 1j * randn()) / sqrt(2);

        h_ir = zeros(nCycle + 1, 1);
        h_ir(ch_delay) = h_ray;

        % Linear convolution (same length as tx_cp)
        rx_cp = conv(tx_cp, h_ir, 'same');

        %% ---------- AWGN ---------- %%
        SNR_lin   = 10^(SNR_dB / 10);
        sig_pwr   = mean(abs(rx_cp).^2);
        noise_pwr = sig_pwr / SNR_lin;
        noise     = sqrt(noise_pwr / 2) * ...
                    (randn(length(rx_cp), 1) + 1j * randn(length(rx_cp), 1));
        rx_cp     = rx_cp + noise;

        %% ---------- RECEIVER ---------- %%

        % Remove cyclic prefix
        rx_no_cp = rx_cp(nCycle + 1 : end);

        % FFT -> frequency domain
        freq_rx = fft(rx_no_cp) / sqrt(N);

        % Channel estimation: least-squares on pilots (averaged 1-tap)
        pilot_rx   = freq_rx(pilot_indices);
        ch_est_avg = mean(pilot_rx ./ pilot_symbols);   % scalar estimate

        % Equalisation (1-tap zero-forcing)
        freq_eq = freq_rx(1:nUtile) / ch_est_avg;

        % QAM demodulation (no toolbox)
        rx_bits_sym = qam_demod(freq_eq, M_order);

        % Accumulate
        bit_start = (symIdx - 1) * nUtile * M + 1;
        bit_end   = symIdx * nUtile * M;
        rx_bits_all(bit_start : bit_end) = rx_bits_sym(1 : nUtile * M);
    end

    %% ------------------------------------------------------------------ %%
    %% BER calculation                                                      %%
    %% ------------------------------------------------------------------ %%
    BER_result = sum(tx_bits ~= rx_bits_all) / nbBits;

end
