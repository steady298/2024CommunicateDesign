function varargout = fsk(varargin)
% FSK MATLAB code for fsk.fig
%      FSK, by itself, creates a new FSK or raises the existing
%      singleton*.
%
%      H = FSK returns the handle to a new FSK or the handle to
%      the existing singleton*.
%
%      FSK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FSK.M with the given input arguments.
%
%      FSK('Property','Value',...) creates a new FSK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fsk_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fsk_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fsk

% Last Modified by GUIDE v2.5 28-Dec-2023 21:26:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fsk_OpeningFcn, ...
                   'gui_OutputFcn',  @fsk_OutputFcn, ...
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


% --- Executes just before fsk is made visible.
function fsk_OpeningFcn(hObject, eventdata, handles, varargin)
movegui(gcf,'center');%窗口居中


handles.fsk_signal_length = 50;

handles.frequency_for_0 = 10;
handles.frequency_for_1 = 100;
handles.fsk_SNR_dB = 5;
handles.symbol_rate = 1000; % 假设码元速率为 1000 Baud

set(handles.edit1, 'String', num2str(handles.fsk_signal_length));
set(handles.edit2, 'String', num2str(handles.frequency_for_0));
set(handles.edit3, 'String', num2str(handles.frequency_for_1));
set(handles.edit4, 'String', num2str(handles.fsk_SNR_dB));
set(handles.edit6, 'String', num2str(handles.symbol_rate));
% Choose default command line output for fsk
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fsk wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fsk_OutputFcn(hObject, eventdata, handles) 
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
    handles.fsk_signal_length = str2double(get(handles.edit1, 'String'));
    handles.frequency_for_0 = str2double(get(handles.edit2, 'String'));
    handles.frequency_for_1 = str2double(get(handles.edit3, 'String'));
    handles.fsk_SNR_dB = str2double(get(handles.edit4, 'String'));
    handles.symbol_rate = str2double(get(handles.edit6, 'String'));
    handles.fsk_original_signal = randi([0, 1], 1, handles.fsk_signal_length); % 随机二进制信号

[fsk, noisy_signal, fsk_error, fsk_error_rate,t,st1,st2,F1,F2,fft_fsk,f,fsk_f_noisy]=simulateFSK(handles.fsk_original_signal, handles.fsk_signal_length, handles.frequency_for_0, handles.frequency_for_1, handles.fsk_SNR_dB,handles.symbol_rate);




% 原始信号波形
    axes(handles.axes1);
    plot(t, st1);
    title('原始信号波形');

    % 调制后的完整波形
    axes(handles.axes2);
    plot(t, fsk);
    title('调制后的完整波形');

    % 幅度谱
    axes(handles.axes3);
    plot(f, fft_fsk);
    title('2FSK 信号幅度谱');
    xlabel('频率');
    ylabel('幅度');

    % 添加高斯白噪声后的完整波形
    axes(handles.axes4);
    plot(t, noisy_signal);
    title('添加高斯白噪声后的完整波形');
    xlabel('时间');
    ylabel('幅度');

    % 添加高斯白噪声后的信号频谱
    axes(handles.axes5);
    plot(fsk_f_noisy, abs(fftshift(fft(noisy_signal))));
    title('添加高斯白噪声后的信号频谱');
    xlabel('频率');
    ylabel('幅度');

    set(handles.text8, 'String', ['不匹配的比特数: ' num2str(fsk_error)]);
    set(handles.text9, 'String', ['原始信号长度: ' num2str(handles.fsk_signal_length)]); % 使用原始信号的长度更新文本框内容
    set(handles.text10, 'String', ['误码率: ' num2str(fsk_error_rate)]);

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



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
