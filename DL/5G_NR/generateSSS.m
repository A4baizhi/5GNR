function sss_sequence = generateSSS(N_ID_1, N_ID_2)
    % 生成 SSS 序列
    % N_ID_1: 小区 ID 的第1部分
    % N_ID_2: 小区 ID 的第2部分
    
    % 定义初始状态和多项式 (具体值根据5G规范确定)
    init_state_0 = [0 0 0 0 0 0 1];
    init_state_1 = [0 0 0 0 0 0 1];
    
    % 生成长度为 127 的 m 序列
    s_0 = generate_m_sequence(init_state_0, 127);
    s_1 = generate_m_sequence(init_state_1, 127);
    
    % 根据 N_ID_1 和 N_ID_2 生成 SSS 序列
    idx_0 = 15 * floor(N_ID_1/112) + 5 * N_ID_2;
    idx_1 = mod(N_ID_1 - 1, 112)+1;
    
    sss_sequence = zeros(1, 127);
    for n = 1:127
        sss_sequence(n) = (1 - 2 * s_0( mod( n + idx_0 - 1, 127) + 1)) * (1 - 2 * s_1( mod( n + idx_1 - 1, 127) + 1));
    end
end

function m_sequence = generate_m_sequence(init_state, seq_length)
    
    m_sequence = zeros(1, seq_length);
    m_sequence(1:7) = init_state;
    
    for n = 8:seq_length
        m_sequence(n) = mod(m_sequence(n-3) + m_sequence(n-7), 2);
    end
end