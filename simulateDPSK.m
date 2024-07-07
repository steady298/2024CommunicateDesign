function [dpsk_error_rate, dpsk_signal, noisy_modulated_signal, dpsk_error] = simulateDPSK(dpsk_original_signal, dpsk_symbol_rate, dpsk_carrier_frequency, dpsk_SNR_dB)


M = 1000;
code_smapling = M;                                     % 每码元复制L次,每个码元采样次数
code_T = 1 / dpsk_symbol_rate;                           % 码元周期                
sampling_t = code_T / M;% 采样间隔
dpsk_length = length(dpsk_original_signal);
absolute_t = dpsk_length * code_T;                       % 绝对码总时间
t = 0:sampling_t:absolute_t - sampling_t;                % 时间1
relatively_t = (dpsk_length + 1) * code_T;               % 相对码总时间
t2 = 0:sampling_t:relatively_t - sampling_t;             % 时间2
Fs = 1 / sampling_t;                                     % 采样频率
%% 产生绝对码
absolute_dpsk_original_signal = ones(1, dpsk_length + 1);       
for i = 2:dpsk_length+1
    absolute_dpsk_original_signal(i) = xor(dpsk_original_signal(i-1), absolute_dpsk_original_signal(i-1));   % 生成相对码
end

%% 产生基带信号
dpsk_origin_signal = kron(absolute_dpsk_original_signal, ones(1, code_smapling));% 绝对码
%% 单极性变为双极性
for n = 1:length(dpsk_origin_signal)
    if dpsk_origin_signal(n) == 1
        dpsk_origin_signal(n) = 1;
    else
        dpsk_origin_signal(n) = -1;
    end
end

%% DPSK调制
carrier = sin(2 * pi * dpsk_carrier_frequency * t2);            % 载波
dpsk_signal = dpsk_origin_signal .* carrier;                                       % DPSK的模拟调制 




% 添加高斯白噪声

noisy_modulated_signal = awgn(dpsk_signal, dpsk_SNR_dB, 'measured');
%% 绘图
%figure;

% subplot(411);
% plot(t2, dpsk_origin_signal, 'LineWidth', 2);
% title('基带信号波形');
% xlabel('时间/s');
% ylabel('幅度');
% axis([0, relatively_t, -1.1, 1.1]);
% 
% subplot(412);
% plot(t2, dpsk_signal, 'LineWidth', 2);
% title('DPSK信号波形');
% xlabel('时间/s');
% ylabel('幅度');
% axis([0, relatively_t, -1.1, 1.1]);
% 
% 
% 
% 
% % 绘制加了噪声后的波形
% subplot(413);
% plot(t2, noisy_modulated_signal, 'LineWidth', 2);
% title('加入高斯白噪声后的DPSK信号波形');
% xlabel('时间/s');
% ylabel('幅度');
% axis([0, relatively_t, -1.5, 1.5]);


% 计算频谱
N = length(dpsk_origin_signal); % 信号的长度
Fs = 1 / sampling_t; % 采样频率

% 计算频谱
dpsk_origin_spectrum = fftshift(abs(fft(dpsk_origin_signal)) / N);
noisy_modulated_spectrum = fftshift(abs(fft(noisy_modulated_signal)) / N);

% 频率轴
f = (-N/2:N/2-1) * Fs / N;

% 绘图
% figure;
% subplot(211);
% plot(f, dpsk_origin_spectrum);
% title('调制后信号 频谱');
% xlabel('频率 (Hz)');
% ylabel('幅度');
% xlim([-Fs/2, Fs/2]);
% grid on;
% 
% subplot(212);
% plot(f, noisy_modulated_spectrum);
% title('加入噪声后 频谱');
% xlabel('频率 (Hz)');
% ylabel('幅度');
% xlim([-Fs/2, Fs/2]);
% grid on;

%% 解调部分
noisy_dpsk_f=noisy_modulated_signal.*carrier;      
% 相干解调，乘以相干载波
% subplot(414);              
% plot(t2,noisy_modulated_signal,'LineWidth',1)    
% axis([0,relatively_t,-1.5,1.5]);  
% title("乘以相干载波后的信号")
% xlabel('时间/s');           
% ylabel('幅度');             

fp=2*dpsk_symbol_rate;                      % 低通滤波器截止频率，乘以2是因为下面要将模拟频率转换成数字频率wp=Rb/(Fs/2)
b=fir1(30, fp/Fs, boxcar(31));              % 生成fir滤波器系统函数中分子多项式的系数
                                            % fir1函数三个参数分别是阶数，数字截止频率，滤波器类型
                                            % 这里是生成了30阶(31个抽头系数)的矩形窗滤波器
[h,w]=freqz(b, 1,512);                      % 生成fir滤波器的频率响应
                                            % freqz函数的三个参数分别是滤波器系统函数的分子多项式的系数，分母多项式的系数(fir滤波器分母系数为1)和采样点数(默认)512
filtered_sginal=fftfilt(b,noisy_dpsk_f);               % 对信号进行滤波，tz是等待滤波的信号，b是fir滤波器的系统函数的分子多项式系数

% plot(t2,lvbo,'LineWidth',2);% 绘制经过低通滤波器后的信号
% axis([0,relatively_t,-1.1,1.1]); 
% title("经过低通滤波器后的信号");
% xlabel('时间/s');           
% ylabel('幅度');             

k=0;                        
received_signa=1*(filtered_sginal>0);            
% subplot(413)                
% plot(t2,received_signa,'LineWidth',2) 
% axis([0,relatively_t,-0.1,1.1]); 
% title("经过抽样判决后的信号")
% xlabel('时间/s');           
% ylabel('幅度');             

% 下采样
downsampled_pdst = received_signa(1:M:end);
% 删除第一个元素
downsampled_pdst = downsampled_pdst(2:end);
real_absolute_dpsk_original_signal = absolute_dpsk_original_signal(1:end-1);

% 计算误码数
dpsk_error = sum(real_absolute_dpsk_original_signal ~= downsampled_pdst);

% 计算误码率
dpsk_error_rate = dpsk_error / length(real_absolute_dpsk_original_signal);
% disp(dpsk_error_rate);

end