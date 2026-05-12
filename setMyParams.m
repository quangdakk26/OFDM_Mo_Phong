function setMyParams(b, n, nbpilots, nbzeros, snr, delaymax, m)
    % Set OFDM parameters
    % Function to configure global parameters for simulations
    
    global Ts nUtile nCycle nTotal W debit
    
    Ts = n / b;                          % Symbol duration
    nUtile = n - (nbzeros + nbpilots);   % Useful subcarriers
    nCycle = delaymax * n / Ts;          % Cyclic prefix
    nTotal = n + nCycle;                 % Total duration
    W = (nUtile + nbpilots) / nTotal^2;  % Power normalization
    debit = m * nUtile / Ts;             % Data rate
    
    % Assign to base workspace for access in other functions
    assignin('base', 'Ts', Ts);
    assignin('base', 'nUtile', nUtile);
    assignin('base', 'nCycle', nCycle);
    assignin('base', 'nTotal', nTotal);
    assignin('base', 'W', W);
    assignin('base', 'debit', debit);
end
