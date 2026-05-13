function setMyParams(b, n, nbpilots, nbzeros, snr, delaymax, m)
% SETMYPARAMS  Configure global OFDM parameters and expose them to base
%              workspace.  No toolbox required.
%
%   setMyParams(B, N, nbPilots, nbZeros, SNR_dB, delayMax, M)

    global Ts nUtile nCycle nTotal W debit

    Ts     = n / b;                          % Symbol duration (s)
    nUtile = n - (nbzeros + nbpilots);       % Useful data subcarriers
    nCycle = delaymax * n / Ts;              % Cyclic prefix length
    nTotal = n + nCycle;                     % Total samples per symbol

    W     = (nUtile + nbpilots) / nTotal^2; % Power normalisation factor
    debit = m * nUtile / Ts;                % Data rate (bits/s)

    % Push derived values to base workspace so scripts can access them
    assignin('base', 'Ts',     Ts);
    assignin('base', 'nUtile', nUtile);
    assignin('base', 'nCycle', nCycle);
    assignin('base', 'nTotal', nTotal);
    assignin('base', 'W',      W);
    assignin('base', 'debit',  debit);
end
