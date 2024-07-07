function varargout = ask(varargin)
% ASK MATLAB code for ask.fig
%      ASK, by itself, creates a new ASK or raises the existing
%      singleton*.
%
%      H = ASK returns the handle to a new ASK or the handle to
%      the existing singleton*.
%
%      ASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASK.M with the given input arguments.
%
%      ASK('Property','Value',...) creates a new ASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ask_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ask_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ask

% Last Modified by GUIDE v2.5 26-Dec-2023 16:37:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ask_OpeningFcn, ...
                   'gui_OutputFcn',  @ask_OutputFcn, ...
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


% --- Executes just before ask is made visible.
function ask_OpeningFcn(hObject, eventdata, handles, varargin)
movegui(gcf,'center');%窗口居中
handles.ask_length = 200; % 信号的长度
%handles.ask_original_signal = randi([0, 1], 1, handles.ask_length); % 生成随机的二进制信号
handles.ask_symbol_rate = 1000; % 符号速率
handles.ask_carrier_frequency = 3000; % 载波频率
handles.ask_SNR_dB = 15; % 所需的信噪比（以分贝为单位）

set(handles.edit1, 'String', num2str(handles.ask_length));
set(handles.edit2, 'String', num2str(handles.ask_symbol_rate));
set(handles.edit3, 'String', num2str(handles.ask_carrier_frequency));
set(handles.edit4, 'String', num2str(handles.ask_SNR_dB));
% Choose default command line output for ask
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ask wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ask_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 测试函数
    handles.ask_length = str2double(get(handles.edit1, 'String'));
    handles.ask_symbol_rate = str2double(get(handles.edit2, 'String'));
    handles.ask_carrier_frequency = str2double(get(handles.edit3, 'String'));
    handles.ask_SNR_dB = str2double(get(handles.edit4, 'String'));
    handles.ask_original_signal = randi([0, 1], 1, handles.ask_length); % 生成随机的二进制信号
% 调用函数进行 ASK 仿真
[error_rate, modulated_signal, noisy_modulated_signal,error_bits] = simulateASK(handles.ask_original_signal, handles.ask_symbol_rate, handles.ask_carrier_frequency, handles.ask_SNR_dB);

axes(handles.axes1); % 设置绘图区域为 axes1
stairs(handles.ask_original_signal); % 使用 stairs 函数绘制方波图
xlabel('时间');
ylabel('信号幅度');
title('原始信号方波图');
grid on;

axes(handles.axes2); % 设置绘图区域为 axes2
t = linspace(0, length(modulated_signal)/handles.ask_symbol_rate, length(modulated_signal)); % 时间向量
plot(t, modulated_signal);
xlabel('时间');
ylabel('信号幅度');
title('2ASK调制信号');
grid on;

axes(handles.axes3); % 设置绘图区域为 axes3
fs = 2 * handles.ask_carrier_frequency; % 采样频率
n = length(modulated_signal);
f = (0:n-1)*(fs/n); % 频率向量
fft_signal = fft(modulated_signal);
magnitude_spectrum = abs(fft_signal);

% 绘制频谱图
plot(f, magnitude_spectrum);
xlabel('频率');
ylabel('幅度');
title('调制后的信号频谱图');
grid on;


axes(handles.axes4); % 设置绘图区域为 axes3
t = linspace(0, length(noisy_modulated_signal)/handles.ask_symbol_rate, length(noisy_modulated_signal)); % 时间向量
plot(t, noisy_modulated_signal);
xlabel('时间');
ylabel('信号幅度');
title('加入噪声后的信号波形');
grid on;

% 在 axes4 区域绘制加入噪声后的信号频谱
axes(handles.axes5); % 设置绘图区域为 axes4

% 计算加入噪声后信号的频谱信息
fs = 2 * handles.ask_carrier_frequency; % 采样频率
n = length(noisy_modulated_signal);
f = (0:n-1)*(fs/n); % 频率向量
fft_signal = fft(noisy_modulated_signal);
magnitude_spectrum = abs(fft_signal);

% 绘制频谱图
plot(f, magnitude_spectrum);
xlabel('频率');
ylabel('幅度');
title('加入噪声后的信号频谱图');
grid on;


set(handles.text2, 'String', ['不匹配的比特数: ' num2str(error_bits)]);
set(handles.text3, 'String', ['原始信号长度: ' num2str(handles.ask_length)]); % 使用原始信号的长度更新文本框内容
set(handles.text4, 'String', ['误码率: ' num2str(error_rate)]);

    disp(['不匹配的比特数: ' num2str(error_bits)]);
    disp(['原始信号长度: ' num2str(handles.ask_length)]);
    disp(['误码率: ' num2str(error_rate)]);



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
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
