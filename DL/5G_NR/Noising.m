function noisy_x = Noising(x, SNR_dB, sigma_n)
    % 添加噪声
    noisy_x = x + myAWGN(SNR_dB, size(x)) + x .* myMultN(sigma_n, size(x));

end

function noise = myAWGN(SNR_dB, length)

    SNR = 10^(SNR_dB / 10);  % 转换为线性信噪比
    noise = sqrt(0.5 / SNR) * (randn(length) + 1j * randn(length));

end

function M_noise = myMultN(sigma_n, length)

    M_noise = zeros(length);

    if sigma_n > 0
        % 生成复数乘性噪声序列
        real_part = sigma_n * randn(length);
        imag_part = sigma_n * randn(length);
        M_noise = real_part + 1i * imag_part;
    end
    
end