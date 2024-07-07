function varargout = dpsk(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dpsk_OpeningFcn, ...
                   'gui_OutputFcn',  @dpsk_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before dpsk is made visible.
function dpsk_OpeningFcn(hObject, eventdata, handles, varargin)

movegui(gcf,'center');%窗口居中

%默认参数
handles.dpsk_length = 50; % 信号的长度
%handles.dpsk_original_signal = randi([0, 1], 1, handles.dpsk_length); % 生成随机的二进制信号
handles.dpsk_symbol_rate = 400; % 符号速率
handles.dpsk_carrier_frequency = 500; % 载波频率
handles.dpsk_SNR_dB = 1; % 所需的信噪比（以分贝为单位）

set(handles.edit1, 'String', num2str(handles.dpsk_length));
set(handles.edit2, 'String', num2str(handles.dpsk_symbol_rate));
set(handles.edit3, 'String', num2str(handles.dpsk_carrier_frequency));
set(handles.edit4, 'String', num2str(handles.dpsk_SNR_dB));
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dpsk wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dpsk_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)

function edit3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)

function edit4_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton1_Callback(hObject, eventdata, handles)%%%%%%%%%%%%%%%%%%%%%按钮

    handles.dpsk_length = str2double(get(handles.edit1, 'String'));
    handles.dpsk_symbol_rate = str2double(get(handles.edit2, 'String'));
    handles.dpsk_carrier_frequency = str2double(get(handles.edit3, 'String'));
    handles.dpsk_SNR_dB = str2double(get(handles.edit4, 'String'));
    handles.dpsk_original_signal = randi([0, 1], 1, handles.dpsk_length); % 生成随机的二进制信号


    [error_rate, modulated_signal, noisy_modulated_signal,error_bits] = simulateDPSK(handles.dpsk_original_signal, handles.dpsk_symbol_rate, handles.dpsk_carrier_frequency, handles.dpsk_SNR_dB);
axes(handles.axes1); % 设置绘图区域为 axes1
stairs(handles.dpsk_original_signal); % 使用 stairs 函数绘制方波图
xlabel('时间');
ylabel('信号幅度');
title('原始信号方波图');
grid on;

axes(handles.axes2); % 设置绘图区域为 axes2
t = linspace(0, length(modulated_signal)/handles.dpsk_symbol_rate, length(modulated_signal)); % 时间向量
plot(t, modulated_signal);
xlabel('时间');
ylabel('信号幅度');
title('DBPSK调制信号');
grid on;

axes(handles.axes3); % 设置绘图区域为 axes3
fs = 2 * handles.dpsk_carrier_frequency; % 采样频率
n = length(modulated_signal);
f = (-n/2:n/2-1)*(fs/n); % 频率向量，以便将中心置于 0
fft_signal = fftshift(fft(modulated_signal)); % 对频谱进行移位操作
magnitude_spectrum = abs(fft_signal);

% 绘制频谱图
plot(f, magnitude_spectrum);
xlabel('频率');
ylabel('幅度');
title('调制后的信号频谱图');
grid on;



axes(handles.axes4); % 设置绘图区域为 axes3
t = linspace(0, length(noisy_modulated_signal)/handles.dpsk_symbol_rate, length(noisy_modulated_signal)); % 时间向量
plot(t, noisy_modulated_signal);
xlabel('时间');
ylabel('信号幅度');
title('加入噪声后的信号波形');
grid on;

% 在 axes4 区域绘制加入噪声后的信号频谱
axes(handles.axes5); % 设置绘图区域为 axes4

% 计算加入噪声后信号的频谱信息
% axes(handles.axes3); % 设置绘图区域为 axes3
fs = 2 * handles.dpsk_carrier_frequency; % 采样频率
n = length(noisy_modulated_signal);
f = (-n/2:n/2-1)*(fs/n); % 频率向量，以便将中心置于 0
fft_signal = fftshift(fft(noisy_modulated_signal)); % 对频谱进行移位操作
magnitude_spectrum = abs(fft_signal);
% 绘制频谱图
plot(f, magnitude_spectrum);
xlabel('频率');
ylabel('幅度');
title('加入噪声后的信号频谱图');
grid on;



set(handles.text6, 'String', ['不匹配的比特数: ' num2str(error_bits)]);
set(handles.text7, 'String', ['原始信号长度: ' num2str(handles.dpsk_length)]); % 使用原始信号的长度更新文本框内容
set(handles.text8, 'String', ['误码率: ' num2str(error_rate)]);

    disp(['不匹配的比特数: ' num2str(error_bits)]);
    disp(['原始信号长度: ' num2str(handles.dpsk_length)]);
    disp(['误码率: ' num2str(error_rate)]);
