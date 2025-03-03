function varargout = main(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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
%以上代码为图窗初始化



function main_OpeningFcn(hObject, eventdata, handles, varargin)
ha=axes('units','normalized','pos',[0 0 1 1]);
uistack(ha,'down');
ii=imread('background.png');
image(ii);
colormap gray
set(ha,'handlevisibility','off','visible','on');


A=imread('background2.png');   %读取图片
set(handles.pushbutton1,'CData',A);  %将按钮的背景图片设置成A，美化按钮
set(handles.pushbutton5,'CData',A);  %将按钮的背景图片设置成A，美化按钮
set(handles.pushbutton6,'CData',A);  %将按钮的背景图片设置成A，美化按钮
set(handles.pushbutton7,'CData',A);  %将按钮的背景图片设置成A，美化按钮
javaFrame = get(gcf,'JavaFrame');
set(javaFrame,'Maximized',1);
handles.output = hObject;
guidata(hObject, handles);

function varargout = main_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function pushbutton1_Callback(hObject, eventdata, handles)%%%%%%%%%%%%按钮ASK
action(ask().fig);


function pushbutton5_Callback(hObject, eventdata, handles)%%%%%%%%%%%%%%%%按钮3
action(bpsk().fig)


function pushbutton6_Callback(hObject, eventdata, handles)%%%%%%%%%%%%按钮FSK
action(fsk().fig);


function pushbutton7_Callback(hObject, eventdata, handles)%%%%%%%%%%%%%按钮dpsk

action(dpsk().fig);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)


% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
