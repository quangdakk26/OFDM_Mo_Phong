function symbols = qam_mod(bits, M_order)
% QAM_MOD  Gray-coded square QAM modulator (no toolbox required)
%
% symbols = qam_mod(bits, M_order)
%
%   bits    - column vector of bits (length must be divisible by log2(M_order))
%   M_order - constellation size: 4, 16, 64, 256 ...  (must be a perfect square)
%
% Returns unit-average-power complex symbols.

    bps = log2(M_order);          % bits per symbol
    sqM = sqrt(M_order);          % side length of square grid

    % Reshape bits into rows of bps bits
    bits = bits(:);
    nSym = length(bits) / bps;
    bit_matrix = reshape(bits, bps, nSym).';   % nSym x bps

    % Split into I and Q halves
    half = bps / 2;
    I_bits = bit_matrix(:, 1:half);            % nSym x half
    Q_bits = bit_matrix(:, half+1:end);

    % Gray-code index -> natural index -> PAM level
    I_idx = gray2bin_vec(I_bits);   % 0-based index  [0 .. sqM-1]
    Q_idx = gray2bin_vec(Q_bits);

    % PAM levels: -(sqM-1), -(sqM-3), ... , (sqM-3), (sqM-1)
    levels = (0:sqM-1).' * 2 - (sqM - 1);   % column vector

    I_vals = levels(I_idx + 1);   % +1 for MATLAB 1-based
    Q_vals = levels(Q_idx + 1);

    symbols_raw = I_vals + 1j * Q_vals;

    % Normalise to unit average power
    avg_pwr = mean(abs(levels).^2) * 2;   % E[|I|^2] + E[|Q|^2]
    symbols = symbols_raw / sqrt(avg_pwr);
end

% -------------------------------------------------------------------------
function nat = gray2bin_vec(gray_bits)
% Convert rows of Gray-coded bits to natural binary integers (0-based)
    [nSym, nbits] = size(gray_bits);
    nat = zeros(nSym, 1);
    msb = gray_bits(:, 1);
    nat = nat + msb * 2^(nbits-1);
    cur = msb;
    for k = 2:nbits
        cur = xor(cur, gray_bits(:, k));
        nat = nat + cur * 2^(nbits-k);
    end
end
