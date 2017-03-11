function varargout = serial_gui(varargin)
% TEST MATLAB code for serial_gui.fig
%      TEST, by itself, creates a new TEST or raises the existing
%      singleton*.
%
%      H = TEST returns the handle to a new TEST or the handle to
%      the existing singleton*.
%
%      TEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST.M with the given input arguments.
%
%      TEST('Property','Value',...) creates a new TEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test

% Last Modified by GUIDE v2.5 11-Mar-2017 10:42:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_OpeningFcn, ...
                   'gui_OutputFcn',  @test_OutputFcn, ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global COM_PORT % the serial port number
global COM_RATE % the serial port baud rate
global s_handler % the handle of serial port
global sending_text % the text ready to send
global isSendingNewLine % is sending new line or not
global rev_text % receive text
global rev_data_counter % how many data i have received yet
global send_data_counter % how mant data i have sent yet
global buffer_size % fft buffer sizes
global var_names % variable's names
global data_mat % data matrix, in order to save int .mat files and csv files
global isFFT 
global origin_plot_counter 
global fft_plot_counter
global origin_plot_buffer
global isOrigin_buffer_init
global SerialInputBufferSize
global cmd_specify_fmt
global csv_file_name
global csv_file_handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes just before test is made visible.
function test_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test (see VARARGIN)
global isFFT
global origin_plot_counter 
global fft_plot_counter
global isOrigin_buffer_init
global rev_data_counter
rev_data_counter = 0 ;
isFFT = false ;
origin_plot_counter = 0 ;
fft_plot_counter = 0 ;
isOrigin_buffer_init = false ;
global SerialInputBufferSize
SerialInputBufferSize = 10240000 ;
% clc

% Choose default command line output for test
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes test wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = test_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in lb_SerialPort.
function lb_SerialPort_Callback(hObject, eventdata, handles)
% hObject    handle to lb_SerialPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String')) ;

% Hints: contents = cellstr(get(hObject,'String')) returns lb_SerialPort contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb_SerialPort


% --- Executes during object creation, after setting all properties.
function lb_SerialPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_SerialPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lb_BaudRate.
function lb_BaudRate_Callback(hObject, eventdata, handles)
% hObject    handle to lb_BaudRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lb_BaudRate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb_BaudRate


% --- Executes during object creation, after setting all properties.
function lb_BaudRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_BaudRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbOpenPort.
function pbOpenPort_Callback(hObject, eventdata, handles)
% hObject    handle to pbOpenPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global COM_PORT
global COM_RATE
global s_handler
global SerialInputBufferSize
global cmd_specify_edit
global var_names
global csv_file_name
global csv_file_handle
clc
instrreset  % inconnect and delete all instrument objects
s_handler = serial(COM_PORT) ;
set(s_handler, 'BaudRate', COM_RATE) ;
set(s_handler,'DataBits',8);%%%
set(s_handler,'StopBits',1);%%%
set(s_handler,'InputBufferSize',SerialInputBufferSize);%%%
set(handles.pbOpenPort,'Enable','off');
set(handles.pbClosePort,'Enable','on');
s_handler.BytesAvailableFcnMode = 'terminator' ;
s_handler.BytesAvailableFcnCount = 10;
s_handler.BytesAvailableFcn={@EveBytesAvailableFcn,handles};
fopen(s_handler) ;
display('open the serial port now') ;
% parse var fmt
cmd_specify_name = 'cmd-specify' ;
cmd_specify_edit = get(handles.cmd_specify_edit, 'String') ;
cmd_specify_flag = strfind(cmd_specify_edit, cmd_specify_name) ;
if cmd_specify_flag >= 1
    specify_contents = cmd_specify_edit(length(cmd_specify_name)+1:end) ;
    extractPacketVarNames(specify_contents) ;
end
% save data into csv
csv_file_name = get(handles.csv_name, 'string') ;
if isempty(csv_file_name)
    csv_file_name = 'serial_csv_data.csv' ;
end
var_str = '' ;
delete(csv_file_name) ;
tmp = fopen(csv_file_name,'w') ;
fclose(tmp) ; % create file named $csv_file_name
csv_file_handle = fopen(csv_file_name,'w') ;
for i = 1:length(var_names)
    var_str = var_names{i} ;
    if i ~= length(var_names)
        fprintf(csv_file_handle, '%s,',char(var_str)) ;
    else
        fprintf(csv_file_handle,'%s',char(var_str)) ;
    end
end
fprintf(csv_file_handle,'\r') ;



function extractPacketVarNames(var_contents)
global var_names
var_names = {} ;
count = 1 ;
while length(var_contents) >= 2
    loc_1 = strfind(var_contents, '"') ;
    new_str = var_contents(loc_1+1:end) ;
    loc_2 = strfind(new_str,'"') ;
    var_name = new_str(1:loc_2-1) ;
    var_contents = var_contents(loc_2+3:end) ;
    if isempty(var_name) == true
        break ;
    end
    var_names = [var_names, var_name] ; 
    count = count+1 ;
end

% specify the packet format
% specify method: sending
% cmd-specify{"var-name1","var-name2",etc}
% to specify the csv name:sending
% cmd-csv{"csv-name"}
% when you want to send datas:sending
% data{var-data1,var-data2,etc}
function EveBytesAvailableFcn( t,event,handles )
global s_handler 
global rev_text
global rev_data_counter
global var_names
global origin_plot_buffer
global isOrigin_buffer_init 
global origin_plot_counter 
global buffer_size
global csv_file_handle
buffer_size = get(handles.buf_edit, 'string') ;
buf_size = str2double(buffer_size) ;
rev_text = fscanf(s_handler) ;
rev_data_counter = rev_data_counter+1 ;
count = ['rev count = ', num2str(rev_data_counter)] ;
set(handles.rev_count_text, 'string', count) ;
% show how many data packets i have received yet
if isOrigin_buffer_init == false
    isOrigin_buffer_init = true ;
    origin_plot_buffer = zeros(buf_size, length(var_names)) ; % init the buffer 
end % judge whether have been initiated yet or not

cmd_data_name = 'data' ;
data_str = rev_text(length(cmd_data_name)+1:end) ;
data_vector = zeros(1,length(var_names)) ;
data_cell = regexp(data_str,'\d*\.?\d*','match') ;
len_cell = length(data_cell) ;
for i = 1:len_cell 
    data_vector(i) = str2double(data_cell{i}) ;
    if i ~= len_cell
        fprintf(csv_file_handle, '%f,',data_vector(i));
    else
        fprintf(csv_file_handle, '%f',data_vector(i)) ;
    end
end
fprintf(csv_file_handle,'\r') ;
if origin_plot_counter < buf_size
    origin_plot_counter = origin_plot_counter+1 ;
    origin_plot_buffer(origin_plot_counter,:) = data_vector(:) ;
    if origin_plot_counter == buf_size
        origin_plot_counter = 0 ;
        x = origin_plot_buffer(:,1) ;
        y = origin_plot_buffer(:,2) ;
        plot(handles.origin_axes,x, y) ;
        set(handles.origin_axes, 'XGrid','on')
        set(handles.origin_axes, 'YGrid','on')
        fft_y = fftshift(abs(fft(y, 1024))) ;
        plot(handles.fft_axes,1:1024, mapminmax(fft_y,0,1)) ;
        set(handles.fft_axes, 'XGrid','on')
        set(handles.fft_axes, 'YGrid','on')
    end
end


% --- Executes on button press in pbClosePort.
function pbClosePort_Callback(hObject, eventdata, handles)
% hObject    handle to pbClosePort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global s_handler
global rev_data_counter
global csv_file_name
global csv_file_handle
fclose(csv_file_handle);
fclose(s_handler) ;
delete(s_handler) ;
set(handles.pbOpenPort, 'Enable', 'on') ;
set(handles.pbClosePort, 'Enable', 'off') ;
% clc
display('close serial port now') ;
axes(handles.origin_axes) 
cla reset
set(handles.origin_axes, 'XGrid','on')
set(handles.origin_axes, 'YGrid','on')
axes(handles.fft_axes) 
cla reset
set(handles.fft_axes, 'XGrid','on')
set(handles.fft_axes, 'YGrid','on')
rev_data_counter = 0 ;
count = ['rev count = ', num2str(rev_data_counter)] ;
set(handles.rev_count_text, 'string', count) ;



% --- Executes on selection change in menu_serialport.
function menu_serialport_Callback(hObject, eventdata, handles)
% hObject    handle to menu_serialport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_serialport contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_serialport
global COM_PORT ;
val = get(hObject, 'value') ;
switch val
    case 1
        COM_PORT = -1 ;
    case 2
        COM_PORT = 'COM1' ;
    case 3
        COM_PORT = 'COM2' ;
    case 4
        COM_PORT = 'COM3' ;
    case 5
        COM_PORT = 'COM4' ;
    case 6
        COM_PORT = 'COM5' ;
    case 7
        COM_PORT = 'COM6' ;
end

% --- Executes on selection change in menu_baudrate.
function menu_baudrate_Callback(hObject, eventdata, handles)
% hObject    handle to menu_baudrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_baudrate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_baudrate
% end
global COM_RATE ;
val = get(hObject, 'value') ;
switch val
    case 1
        COM_RATE = -1 ;
    case 2
        COM_RATE = 128000 ;
    case 3
        COM_RATE = 14400 ;
    case 4
        COM_RATE = 19200 ; 
    case 5
        COM_RATE = 115200 ;
end

% --- Executes on button press in pd_send.
function pd_send_Callback(hObject, eventdata, handles)
% hObject    handle to pd_send (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sending_text
global s_handler
global isSendingNewLine
global send_data_counter
if isSendingNewLine == true
    fprintf(s_handler, '%s\r\n', sending_text) ;
else
    fprintf(s_handler, '%s', sending_text) ;
end
send_data_counter = send_data_counter+1 ;
count = ['send count = ', num2str(send_data_counter)] ;
set(handles.send_count_text, 'string', count) ;


function edit_send_Callback(hObject, eventdata, handles)
% hObject    handle to edit_send (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_send as text
%        str2double(get(hObject,'String')) returns contents of edit_send as a double
global sending_text
sending_text = get(hObject, 'String') ; % get the sending text contents



% --- Executes on button press in sending_newline.
function sending_newline_Callback(hObject, eventdata, handles)
% hObject    handle to sending_newline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global isSendingNewLine
val = get(hObject, 'Value') ;
if val == 1
    isSendingNewLine = true ;
else
    isSendingNewLine = false ;
end
% Hint: get(hObject,'Value') returns toggle state of sending_newline


% --- Executes during object creation, after setting all properties.
function rev_count_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rev_count_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function send_count_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to send_count_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global send_data_counter
send_data_counter = 0 ;



function buf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to buf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of buf_edit as text
%        str2double(get(hObject,'String')) returns contents of buf_edit as a double
global buffer_size
buffer_size = get(hObject, 'string') ;
buffer_size = num2str(buffer_size) ; 


% --- Executes during object creation, after setting all properties.
function buf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global buffer_size
buffer_size = 0 ;

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function csv_name_Callback(hObject, eventdata, handles)
% hObject    handle to csv_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of csv_name as text
%        str2double(get(hObject,'String')) returns contents of csv_name as a double
global csv_file_name
csv_file_name = get(hObject, 'string') ;


% --- Executes during object creation, after setting all properties.
function csv_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to csv_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cmd_specify_edit_Callback(hObject, eventdata, handles)
% hObject    handle to cmd_specify_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cmd_specify_edit as text
%        str2double(get(hObject,'String')) returns contents of cmd_specify_edit as a double
global cmd_specify_fmt
cmd_specify_fmt = get(hObject, 'String') ;

% --- Executes during object creation, after setting all properties.
function cmd_specify_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmd_specify_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function origin_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to origin_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate origin_axes
