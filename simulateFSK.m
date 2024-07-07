function [fsk, noisy_signal, fsk_error, fsk_error_rate,t,st1,st2,F1,F2,fft_fsk,f,fsk_f_noisy] = simulateFSK(fsk_original_signal, fsk_signal_length, frequency_for_0, frequency_for_1, SNR_dB,symbol_rate)
%     fsk_original_signal = fsk_original_signal;
    
    j = symbol_rate * fsk_signal_length;
    t = linspace(0, fsk_signal_length / SNR_dB, j); % 时间向量
    symbol_duration = j / fsk_signal_length;
    st1 = zeros(1, j); % 初始化信号 1
    
    
   

    % 根据原始二进制信号生成 st1
    for n = 1:fsk_signal_length
        if fsk_original_signal(n) == 1
            st1((n - 1) * symbol_duration + 1 : n * symbol_duration) = 1;
        end
    end

    % 求反得到 st2
    st2 = 1 - st1;

    % 根据 0 和 1 选择对应的载波频率
    s1 = zeros(1, j);
    for n = 1:j
        if st1(n) == 1
            s1(n) = cos(2 * pi * frequency_for_1 * t(n));
        else
            s1(n) = cos(2 * pi * frequency_for_0 * t(n));
        end
    end

    % 进行调制
    F1 = st1 .* s1; % 调制信号 1
    F2 = st2 .* s1; % 调制信号 2

    % 生成 2FSK 信号
    fsk = F1 + F2;

    % 计算频谱
    N = length(fsk);
    f = (-N/2:N/2-1) * (1/(N * (t(2) - t(1))));
    fft_fsk = abs(fftshift(fft(fsk)));

    % 计算信号功率
    signal_power = rms(fsk)^2;

    % 计算噪声功率
    noise_power = signal_power / (10^(SNR_dB/10));

    % 生成高斯白噪声
    noise = sqrt(noise_power) * randn(size(fsk));

    % 将噪声添加到信号中
    noisy_signal = fsk + noise;

    % 计算添加高斯白噪声后的频谱
    fsk_N_noisy = length(noisy_signal);
    fsk_f_noisy = (-fsk_N_noisy/2:fsk_N_noisy/2-1) * (1/(fsk_N_noisy * (t(2) - t(1))));
    E_noisy = abs(fftshift(fft(noisy_signal)));

    % 进行信号解调
    fsk_demodulated_signal = zeros(1, fsk_signal_length);
    for n = 1:fsk_signal_length
        segment = noisy_signal((n - 1) * symbol_duration + 1 : n * symbol_duration);
        correlation_for_0 = sum(segment .* cos(2 * pi * frequency_for_0 * t((n - 1) * symbol_duration + 1 : n * symbol_duration)));
        correlation_for_1 = sum(segment .* cos(2 * pi * frequency_for_1 * t((n - 1) * symbol_duration + 1 : n * symbol_duration)));
        if correlation_for_0 < correlation_for_1
            fsk_demodulated_signal(n) = 1;
        else
            fsk_demodulated_signal(n) = 0;
        end
    end

    % 计算误码率
    fsk_error = sum(fsk_original_signal ~= fsk_demodulated_signal);
    fsk_error_rate = fsk_error / fsk_signal_length;

    disp(['误码元数为：', num2str(fsk_error)]);
    disp(['原始序列长度为：', num2str(fsk_signal_length)]);
    disp(['误码率为：', num2str(fsk_error_rate)]);

%     % 绘图
%     figure;
% 
%     % 原始信号波形
%     subplot(5, 1, 1);
%     plot(t, st1);
%     title('原始信号波形');
% 
%     % 调制后的完整波形
%     subplot(5, 1, 2);
%     plot(t, F1 + F2);
%     title('调制后的完整波形');
% 
%     % 幅度谱
%     subplot(5, 1, 3);
%     plot(f, fft_fsk);
%     title('2FSK 信号幅度谱');
%     xlabel('频率');
%     ylabel('幅度');
% 
%     % 添加高斯白噪声后的完整波形
%     subplot(5, 1, 4);
%     plot(t, noisy_signal);
%     title('添加高斯白噪声后的完整波形');
%     xlabel('时间');
%     ylabel('幅度');
% 
%     % 添加高斯白噪声后的信号频谱
%     subplot(5, 1, 5);
%     plot(fsk_f_noisy, abs(fftshift(fft(noisy_signal))));
%     title('添加高斯白噪声后的信号频谱');
%     xlabel('频率');
%     ylabel('幅度');
end
