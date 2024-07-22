N_ID_2_list = [0, 1, 2]; % 可选的N_ID_2参数列表

% 生成所有可能的PSS序列
pss_seqs = cell(length(N_ID_2_list), 1);
for i = 1:length(N_ID_2_list)
    N_ID_2 = N_ID_2_list(i);
    pss_seqs{i} = generatePSS(N_ID_2);
end

% 计算自相关函数并绘图
figure;
ax = gobjects(length(N_ID_2_list), length(N_ID_2_list)); % 存储子图的句柄
for i = 1:length(N_ID_2_list)
    N_ID_2 = N_ID_2_list(i);
    pss_seq = pss_seqs{i};
    
    % 计算自相关函数
    auto_corr = xcorr(pss_seq, pss_seq);
    
    % 绘制自相关函数图像
    ax(i, i) = subplot(length(N_ID_2_list), length(N_ID_2_list), (i-1)*(length(N_ID_2_list)) + i);
    stem(abs(auto_corr));
    xlabel('Delay');
    ylabel('Magnitude');
    title(sprintf('Auto-correlation of N_{ID}^2=%d', N_ID_2));
    grid on;
    
    % 计算互相关函数并绘图
    for j = i+1:length(N_ID_2_list)
        N_ID_2_other = N_ID_2_list(j);
        pss_seq_other = pss_seqs{j};
        
        % 计算互相关函数
        cross_corr = xcorr(pss_seq, pss_seq_other);
        
        % 绘制互相关函数图像
        ax(i, j) = subplot(length(N_ID_2_list), length(N_ID_2_list), (i-1)*(length(N_ID_2_list)) + j);
        stem(abs(cross_corr));
        xlabel('Delay');
        ylabel('Magnitude');
        title(sprintf('Cross-correlation between N_{ID}^2=%d and N_{ID}^2=%d', N_ID_2, N_ID_2_other));
        grid on;
        
        % 对称位置的互相关函数图像（因为互相关是对称的）
        ax(j, i) = subplot(length(N_ID_2_list), length(N_ID_2_list), (j-1)*(length(N_ID_2_list)) + i);
        stem(abs(cross_corr));
        xlabel('Delay');
        ylabel('Magnitude');
        title(sprintf('Cross-correlation between N_ID_2=%d and N_{ID}^2=%d', N_ID_2_other, N_ID_2));
        grid on;
    end
end

% 统一子图的坐标轴刻度
linkaxes(ax, 'xy');