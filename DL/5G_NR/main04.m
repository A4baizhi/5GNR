clc;
clear;

%——————————————————————————————————————————————————————%
% 载波频率
carrier_frequency = 3.5e9; % 3.5 GHz

% 子载波间隔
subcarrier_spacing = 15e3; % 15 kHz

% 符号间隔
symbol_duration = 1 / subcarrier_spacing; % 1 / 15 kHz = 66.7 µs

% PSS/SSS配置
N_ID_1 = 0; 
N_ID_2 = 0; 

% 设定仿真时使用的序列长度
sign_length = 127;
%——————————————————————————————————————————————————————%

% 生成PSS序列
pss_seq = generatePSS(N_ID_2);
plot(pss_seq)

% 生成SSS序列 
sss_seq = generateSSS(N_ID_1, N_ID_2);

plotSyncSignals(pss_seq, sss_seq);

plotCorrelation(pss_seq, sss_seq);

% 初始化SSB (4个OFDM符号，每个符号有sign_length个子载波)
SSB_NUM_SYMBOLS = 4;
ssb = zeros(SSB_NUM_SYMBOLS, sign_length);

% 映射PSS和SSS到SSB
ssb(1, :) = pss_seq;
ssb(2, :) = sss_seq;

% 生成PBCH和PBCH DMRS
pbch = randn(1, sign_length) + 1i * randn(1, sign_length);
pbch_dmrs = randn(1, sign_length) + 1i * randn(1, sign_length);

% 将PBCH和PBCH DMRS映射到SSB
ssb(3, :) = pbch;
ssb(4, :) = pbch_dmrs;

%——————————————————————————————————————————————————————%
% 参数设置
num_symbols = SSB_NUM_SYMBOLS;
cp_length = 32;  % 循环前缀长度，可以根据需求调整


%——————————————————————————————————————————————————————%
% 参数设置
SNR_dB_range = -10:2:30;  % 信噪比范围
sigmaN_values = [0, 0.2, 0.5, 1, 2, 10];  % 噪声方差设置
num_trials = 10000;  % 仿真次数
threshold = 106;    %阈值

% 初始化成功率数组
success_rate_pss = zeros(length(SNR_dB_range), length(sigmaN_values));
success_rate_sss = zeros(length(SNR_dB_range), length(sigmaN_values));

% 循环测试不同的信噪比和sigma_n值
for idx_sigma = 1:length(sigmaN_values)
    sigmaN = sigmaN_values(idx_sigma);
    
    for idx_snr = 1:length(SNR_dB_range)
        SNR_dB = SNR_dB_range(idx_snr);
        num_success_pss = 0;
        num_success_sss = 0;
        
        % 多次运行仿真
        for trial = 1:num_trials
            % 调用测试函数
            success = test(SNR_dB, sigmaN, pss_seq, sss_seq, ssb, threshold, cp_length, num_symbols, sign_length);
            
            % 统计成功次数
            num_success_pss = num_success_pss + success(1);
            num_success_sss = num_success_sss + success(2);
        end
        
        % 计算成功率
        success_rate_pss(idx_snr, idx_sigma) = num_success_pss / num_trials;
        success_rate_sss(idx_snr, idx_sigma) = num_success_sss / num_trials;
    end
end

% 绘制性能曲线
figure;
hold on;
colors = ['b', 'r', 'g', 'm', 'c', 'k'];
markers = ['o', 's', 'd', '^', 'v', 'h'];
for idx_sigma = 1:length(sigmaN_values)
    plot(SNR_dB_range, success_rate_pss(:, idx_sigma), [colors(idx_sigma) markers(idx_sigma) '-'], 'LineWidth', 2);
end
grid on;
xlabel('SNR (dB)');
ylabel('Success Rate');
title('PSS Detection Performance with Different \sigma_n');
legend(arrayfun(@(x) ['\sigma_n = ' num2str(x)], sigmaN_values, 'UniformOutput', false));

figure;
hold on;
for idx_sigma = 1:length(sigmaN_values)
    plot(SNR_dB_range, success_rate_sss(:, idx_sigma), [colors(idx_sigma) markers(idx_sigma) '-'], 'LineWidth', 2);
end
grid on;
xlabel('SNR (dB)');
ylabel('Success Rate');
title('SSS Detection Performance with Different \sigma_n');
legend(arrayfun(@(x) ['\sigma_n = ' num2str(x)], sigmaN_values, 'UniformOutput', false));


%——————————————————————————————————————————————————————%
disp('Finish')
%——————————————————————————————————————————————————————%

function success = test(SNR_dB, sigmaN, pss_seq, sss_seq, ssb, threshold, cp_length, num_symbols, sign_length)
    num_subcarriers = sign_length;

    % OFDM调制
    ofdm_symbols = zeros(num_symbols, num_subcarriers + cp_length);
    for i = 1:num_symbols
        % IFFT
        time_domain_symbol = ifft(ssb(i, :), num_subcarriers);
        % 添加循环前缀
        ofdm_symbols(i, :) = [time_domain_symbol(end-cp_length+1:end), time_domain_symbol];
    end

    % 合并所有OFDM符号为一个连续的时域信号
    tx_signal = ofdm_symbols(:);
    %——————————————————————————————————————————————————————%
    rx_signal = Noising(tx_signal, SNR_dB, sigmaN);  % 添加噪声

    % 接收端处理
    % 去除循环前缀
    rx_ofdm_symbols = reshape(rx_signal, [num_symbols, num_subcarriers + cp_length]);
    rx_ofdm_symbols_no_cp = rx_ofdm_symbols(:, cp_length+1:end);

    % FFT解调
    rx_freq_domain_symbols = fft(rx_ofdm_symbols_no_cp, num_subcarriers, 2);

    % 提取PSS和SSS序列
    rx_pss = rx_freq_domain_symbols(1, :);
    rx_sss = rx_freq_domain_symbols(2, :);

    %——————————————————————————————————————————————————————%

    % 计算PSS和SSS序列与预知序列的互相关
    pss_corr = max(xcorr(rx_pss, pss_seq));
    sss_corr = max(xcorr(rx_sss, sss_seq));

    pss_c = pss_corr > threshold;
    sss_c = sss_corr > threshold;

    success = [pss_c, sss_c];
end

function plotCorrelation(pss_seq, sss_seq)
    % 计算自相关
    pss_autocorr = xcorr(pss_seq);
    sss_autocorr = xcorr(sss_seq);
    
    % 计算互相关
    cross_corr = xcorr(pss_seq, sss_seq);
    
    % 绘制自相关和互相关图
    figure;
    
    % 绘制PSS自相关图
    subplot(3, 1, 1);
    plot(-length(pss_seq)+1:length(pss_seq)-1, pss_autocorr);
    title('PSS 自相关');
    xlabel('延时');
    ylabel('相关系数');
    
    % 绘制SSS自相关图
    subplot(3, 1, 2);
    plot(-length(sss_seq)+1:length(sss_seq)-1, sss_autocorr);
    title('SSS 自相关');
    xlabel('延时');
    ylabel('相关系数');
    
    % 绘制PSS与SSS互相关图
    subplot(3, 1, 3);
    plot(-length(pss_seq)+1:length(pss_seq)-1, cross_corr);
    title('PSS 与 SSS 互相关');
    xlabel('延时');
    ylabel('相关系数');
end