function bits = qam_demod(symbols, M_order)
% QAM_DEMOD  Hard-decision Gray-coded square QAM demodulator (no toolbox)
%
% bits = qam_demod(symbols, M_order)
%
%   symbols  - complex column vector of received (equalised) symbols
%   M_order  - constellation size: 4, 16, 64, 256 ...
%
% Returns a column vector of bits (length = numel(symbols)*log2(M_order)).
% The constellation and normalisation must match qam_mod.

    bps  = log2(M_order);
    sqM  = sqrt(M_order);
    half = bps / 2;

    % PAM levels used in qam_mod
    levels  = (0:sqM-1).' * 2 - (sqM - 1);     % -(sqM-1) ... (sqM-1)
    avg_pwr = mean(abs(levels).^2) * 2;
    scale   = sqrt(avg_pwr);

    % Re-scale received symbols back to un-normalised grid
    symbols = symbols(:) * scale;

    % Separate I and Q
    I_vals = real(symbols);
    Q_vals = imag(symbols);

    % Nearest-neighbour decision on each PAM axis
    I_idx = pam_decide(I_vals, levels);   % 0-based indices
    Q_idx = pam_decide(Q_vals, levels);

    % Natural index -> Gray bits
    I_bits = bin2gray_vec(I_idx, half);   % nSym x half
    Q_bits = bin2gray_vec(Q_idx, half);

    % Interleave: [I_bits | Q_bits] per symbol, then unroll
    bit_matrix = [I_bits, Q_bits];        % nSym x bps
    bits = reshape(bit_matrix.', [], 1);  % column vector
end

% -------------------------------------------------------------------------
function idx = pam_decide(vals, levels)
% Nearest-neighbour slicer; returns 0-based index into levels
    sqM = length(levels);
    % Clamp to valid range
    lo = levels(1);
    hi = levels(end);
    vals = max(lo, min(hi, vals));
    % Nearest level
    step = levels(2) - levels(1);  % = 2
    idx = round((vals - lo) / step);
    idx = max(0, min(sqM-1, idx));
end

% -------------------------------------------------------------------------
function gray_bits = bin2gray_vec(nat_idx, nbits)
% Natural-binary integer (0-based) -> row of Gray-coded bits, for each element
    nSym = length(nat_idx);
    gray_bits = zeros(nSym, nbits);
    for k = 1:nbits
        bit_pos = nbits - k;          % MSB first
        gray_bits(:, k) = bitand(bitshift(nat_idx, -bit_pos), 1);
    end
    % XOR with shift to get Gray
    gray_bits(:, 2:end) = xor(gray_bits(:, 1:end-1), gray_bits(:, 2:end));
end
