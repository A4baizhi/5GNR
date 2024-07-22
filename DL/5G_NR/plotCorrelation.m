function plotCorrelation(pss_seq, sss_seq)
    % 计算自相关
    pss_autocorr = xcorr(pss_seq, 'coeff');
    sss_autocorr = xcorr(sss_seq, 'coeff');
    
    % 计算互相关
    cross_corr = xcorr(pss_seq, sss_seq, 'coeff');
    
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
