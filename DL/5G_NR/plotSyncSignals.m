function plotSyncSignals(pss_seq, sss_seq)
    % 确定子载波数量
    num_subcarriers = length(pss_seq);
    
    % 生成时间轴
    time_axis = (0:num_subcarriers-1);
    
    % 计算频域PSS和SSS（假设它们已经在频域）
    freq_axis = (0:num_subcarriers-1);
    
    % 绘制PSS时域图和频域图
    figure;
    subplot(2, 2, 1);
    stem(time_axis, pss_seq, 'filled');
    title('PSS 时域图');
    xlabel('子载波索引');
    ylabel('幅度');
    
    subplot(2, 2, 2);
    stem(freq_axis, fft(pss_seq), 'filled');
    title('PSS 频域图');
    xlabel('频率索引');
    ylabel('幅度');
    
    % 绘制SSS时域图和频域图
    subplot(2, 2, 3);
    stem(time_axis, sss_seq, 'filled');
    title('SSS 时域图');
    xlabel('子载波索引');
    ylabel('幅度');
    
    subplot(2, 2, 4);
    stem(freq_axis, fft(sss_seq), 'filled');
    title('SSS 频域图');
    xlabel('频率索引');
    ylabel('幅度');
end
