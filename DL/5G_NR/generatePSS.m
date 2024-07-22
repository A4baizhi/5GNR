function pss_sequence = generatePSS(N_ID_2)
    seq_length = 127;
    % 生成 PSS 序列
    % N_ID_2: 小区 ID 的第2部分 (0, 1, 2)
    
    % 定义初始状态和多项式 (具体值根据5G规范确定)
    init_state = [1 1 1 0 1 1 0];
    
    % 生成长度为 127 的 m 序列
    m_sequence = generate_m_sequence(init_state, seq_length);
    
    % 根据 N_ID_2 进行循环移位 (5G规范中的要求)
    pss_sequence = zeros(1, seq_length);
    for n = 1:126
        %disp(mod(n + 43*N_ID_2, 127))
        pss_sequence(n) = 1 - 2 * m_sequence(mod(n + 43*N_ID_2 -1, 127) + 1);
    end
end


function m_sequence = generate_m_sequence(init_state, seq_length)
    
    m_sequence = zeros(1, seq_length);
    m_sequence(1:7) = init_state;
    
    for n = 8:seq_length
        m_sequence(n) = mod(m_sequence(n-3) + m_sequence(n-7), 2);
    end
end






