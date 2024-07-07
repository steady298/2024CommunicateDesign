function [ask_error_rate, ask_signal, noisy_modulated_signal, ask_error] = simulateASK(ask_original_signal, ask_symbol_rate, ask_carrier_frequency, ask_SNR_dB)
    ask_binary_length = length(ask_original_signal); % 计算原始二进制信号的长度
    T = 1 / ask_symbol_rate; % 计算一个符号的持续时间
    fs = 2 * ask_carrier_frequency; % 采样频率
    t = 0:1/fs:ask_binary_length*T-1/fs; % 时间向量
    ask_signal = []; % 初始化调制信号

    % 生成调制信号
    for i = 1:ask_binary_length
        if ask_original_signal(i) == 1
            signal = cos(2*pi*ask_carrier_frequency*t((i-1)*fs*T+1:i*fs*T)); % 对应二进制为1的情况，产生调制信号
        else
            signal = zeros(1, fs*T); % 对应二进制为0的情况，信号置零
        end
        ask_signal = [ask_signal signal]; % 将生成的信号添加到调制信号序列中
    end

    % 计算信号功率和噪声功率
    signal_power = rms(ask_signal)^2;
    noise_power = signal_power / (10^(ask_SNR_dB/10));
    noise = sqrt(noise_power) * randn(1, length(ask_signal));
    noisy_modulated_signal = ask_signal + noise; % 添加高斯白噪声到调制信号中

%     % 绘制图形
%     figure;
%     subplot(2, 2, 1);
%     plot(t, ask_signal);
%     xlabel('时间');
%     ylabel('幅度');
%     title('2ASK调制波形图（无噪声）');
%     grid on;
% 
%     % 绘制频谱图
%     subplot(2, 2, 3);
%     n = length(ask_signal);
%     f = (0:n-1)*(fs/n);
%     fft_signal = fft(ask_signal);
%     magnitude_spectrum = abs(fft_signal);
%     plot(f, magnitude_spectrum);
%     xlabel('频率');
%     ylabel('幅度');
%     title('2ASK调制频谱图（无噪声）');
%     grid on;
% 
%     % 绘制带噪声的波形图和频谱图
%     subplot(2, 2, 2);
%     plot(t, noisy_modulated_signal);
%     xlabel('时间');
%     ylabel('幅度');
%     title('2ASK调制波形图（带噪声）');
%     grid on;
% 
%     subplot(2, 2, 4);
%     n = length(noisy_modulated_signal);
%     f = (0:n-1)*(fs/n);
%     fft_signal = fft(noisy_modulated_signal);
%     magnitude_spectrum = abs(fft_signal);
%     plot(f, magnitude_spectrum);
%     xlabel('频率');
%     ylabel('幅度');
%     title('2ASK调制频谱图（带噪声）');
%     grid on;

    % 解调信号
    recovered_signal = [];
    for i = 1:ask_binary_length
        symbol = noisy_modulated_signal((i-1)*fs*T+1:i*fs*T); % 提取一个符号的信号
        demodulated = symbol .* cos(2*pi*ask_carrier_frequency*t((i-1)*fs*T+1:i*fs*T)); % 解调
        integral_demod = trapz(demodulated); % 求解调信号的积分
        if abs(integral_demod) > 0.8 % 根据积分结果判断解调后的信号值
            recovered_signal = [recovered_signal 1];
        else
            recovered_signal = [recovered_signal 0];
        end
    end

    % 计算误码率
    ask_error = sum(ask_original_signal ~= recovered_signal);
    ask_error_rate = ask_error / ask_binary_length;

    % 显示误码率和不匹配的比特数
%     disp(['不匹配的比特数: ' num2str(ask_error)]);
%     disp(['原始信号长度: ' num2str(ask_binary_length)]);
%     disp(['误码率: ' num2str(ask_error_rate)]);

    % 返回值
    ask_error_rate = ask_error_rate;
    ask_signal = ask_signal;
    noisy_modulated_signal = noisy_modulated_signal;
end
