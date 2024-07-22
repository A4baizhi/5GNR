function X = myFFT(x)
    % x: 输入信号
    
    % 计算信号长度
    N = length(x);
    
    % 检查输入信号长度是否是2的幂，如果不是，进行零填充使其长度成为最接近的2的幂
    nextpow2_N = nextpow2(N);
    if nextpow2_N > 0
        x = [x, zeros(1, 2^nextpow2_N - N)];
        N = 2^nextpow2_N;
    end
    
    % 初始化变量
    X = zeros(1, N);
    
    % 计算FFT
    for k = 0:N-1
        X(k+1) = 0;
        for n = 0:N-1
            X(k+1) = X(k+1) + x(n+1) * exp(-1i*2*pi*k*n/N);
        end
    end
end
