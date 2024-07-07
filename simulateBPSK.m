function [bpsk_error_rate, bpsk_signal, noisy_modulated_signal, bpsk_error] = simulateBPSK(bpsk_original_signal, bpsk_symbol_rate, bpsk_carrier_frequency, bpsk_SNR_dB)
sampling_rate =  2000*bpsk_symbol_rate;%计算采样率
samples_per_symbol = sampling_rate / bpsk_symbol_rate;% 计算每个符号的采样数
bpsk_length = length(bpsk_original_signal);%为减少传入参数，重新计算序列长度
% 创建时间向量
time = 0:(1/sampling_rate):(bpsk_length/bpsk_symbol_rate - 1/sampling_rate);


bpsk_signal = zeros(1, length(time));                % 初始化调制信号


for i = 1:bpsk_length
    % 对应二进制为1的情况，产生调制信号
    if bpsk_original_signal(i) == 1
        bpsk_signal(((i-1)*samples_per_symbol + 1):(i*samples_per_symbol)) = cos(2*pi*bpsk_carrier_frequency*time(((i-1)*samples_per_symbol + 1):(i*samples_per_symbol)));
    else
    % 对应二进制为0的情况，产生调制信号
        bpsk_signal(((i-1)*samples_per_symbol + 1):(i*samples_per_symbol)) = -cos(2*pi*bpsk_carrier_frequency*time(((i-1)*samples_per_symbol + 1):(i*samples_per_symbol)));
    end
end


% 生成高斯白噪声
signal_power = sum(abs(bpsk_signal).^2) / length(bpsk_signal);
noise_power = signal_power / (10^(bpsk_SNR_dB / 10)); % 将信噪比转换为噪声功率
noise = sqrt(noise_power) * randn(size(bpsk_signal));

% 将噪声添加到调制信号中
noisy_modulated_signal = bpsk_signal + noise;

%绘图部分
% 绘制原始信号的波形
% subplot(5, 1, 1);
% stem(time(1:length(bpsk_original_signal)), bpsk_original_signal, 'LineWidth', 1);
% title('原始信号波形');
% xlabel('时间');
% ylabel('幅度');
% 
% % 绘制调制信号加入噪声前的波形
% subplot(5, 1, 2);
% plot(time, bpsk_signal, 'LineWidth', 1);
% title('调制信号波形（加入噪声前）');
% xlabel('时间');
% ylabel('幅度');
% 
% % 绘制调制信号加入噪声后的波形
% subplot(5, 1, 3);
% plot(time, noisy_modulated_signal, 'r', 'LineWidth', 1);
% title('调制信号波形（加入噪声后）');
% xlabel('时间');
% ylabel('幅度');
% 
% % 绘制调制信号加入噪声前的频谱
% subplot(5, 1, 4);
% fft_modulated_signal = fft(bpsk_signal);
% frequencies = linspace(-sampling_rate/2, sampling_rate/2, length(bpsk_signal));
% plot(frequencies, fftshift(abs(fft_modulated_signal)), 'LineWidth', 1);
% title('调制信号频谱（加入噪声前）');
% xlabel('频率');
% ylabel('幅度');
% 
% % 绘制调制信号加入噪声后的频谱
% subplot(5, 1, 5);
% fft_noisy_signal = fft(noisy_modulated_signal);
% plot(frequencies, fftshift(abs(fft_noisy_signal)), 'r', 'LineWidth', 1);
% title('调制信号频谱（加入噪声后）');
% xlabel('频率');
% ylabel('幅度');


% 创建匹配滤波器
matched_filter = fliplr(cos(2*pi*bpsk_carrier_frequency*(0:(1/sampling_rate):(1/bpsk_symbol_rate - 1/sampling_rate))));

% 对接收信号进行匹配滤波
filtered_signal = conv(noisy_modulated_signal, matched_filter, 'same');

% 采样并比较阈值
received_signal = zeros(1, bpsk_length);
for i = 1:bpsk_length
    % 采样
    sample = filtered_signal(round((i-0.5)*samples_per_symbol));
    % 比较阈值
    if sample > 0
        received_signal(i) = 1;
    else
        received_signal(i) = 0;
    end
end

% 计算误码数
bpsk_error = sum(abs(bpsk_original_signal - received_signal));

% 计算误码率
bpsk_error_rate = bpsk_error / bpsk_length;
% disp(['不匹配的比特数: ' num2str(bpsk_error)]);
% disp(['原始信号长度: ' num2str(bpsk_length)]);
% disp(['误码率: ' num2str(bpsk_error_rate)]);
end
