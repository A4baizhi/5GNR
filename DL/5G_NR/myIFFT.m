function x = myIFFT(X)
    N = length(X);
    x = zeros(1, N);
    
    for n = 0:N-1
        sumX = 0;
        for k = 0:N-1
            sumX = sumX + X(k+1) * exp(1j * 2 * pi * k * n / N);
        end
        x(n+1) = sumX / N;
    end
end
