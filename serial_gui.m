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

% Last Modified by GUIDE v2.5 10-Mar-2017 23:55:16

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
global inform % new receive data need to be show
global rev_data_counter % how many data i have received yet
global send_data_counter % how mant data i have sent yet
global isCreateCSVFiles % 
global buffer_size % fft buffer sizes
global var_names % variable's names
global csv_file_name % generated csv file's name
global isSpecifyVarName 
global isSpecifyCSVName
global data_mat % data matrix, in order to save int .mat files and csv files
global isFFT 
global origin_plot_counter 
global fft_plot_counter
global origin_plot_buffer
global isOrigin_buffer_init
% global sendingData % ready to sending data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes just before test is made visible.
function test_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test (see VARARGIN)
global isSpecifyVarName 
global isSpecifyCSVName
global isFFT
global origin_plot_counter 
global fft_plot_counter
global isOrigin_buffer_init
isSpecifyCSVName = false ;
isSpecifyVarName = false ;
isFFT = false ;
origin_plot_counter = 0 ;
fft_plot_counter = 0 ;
isOrigin_buffer_init = false ;
clc

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
clc
instrreset  % inconnect and delete all instrument objects
s_handler = serial(COM_PORT) ;
set(s_handler, 'BaudRate', COM_RATE) ;
set(s_handler,'DataBits',8);%%%
set(s_handler,'StopBits',1);%%%
set(s_handler,'InputBufferSize',1024000);%%%
set(handles.pbOpenPort,'Enable','off');
set(handles.pbClosePort,'Enable','on');
s_handler.BytesAvailableFcnMode = 'terminator' ;
s_handler.BytesAvailableFcnCount = 10;
s_handler.BytesAvailableFcn={@EveBytesAvailableFcn,handles};
fopen(s_handler) ;
display('open the serial port now') ;
% open the port now, we need to save the port number and baud rate into a
% file in convenience to reload them before next usage


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
global inform
global rev_data_counter
global isSpecifyVarName 
global isSpecifyCSVName
global var_names
global csv_file_name
global isCreateCSVFiles
global origin_plot_buffer
global isOrigin_buffer_init 
global origin_plot_counter 

buf_size = 300 ;
rev_text = fscanf(s_handler) ;
rev_data_counter = rev_data_counter+1 ;
% inform{length(inform)+1} = rev_text ;
% set(handles.rev_list, 'string', inform) ;
% set(handles.rev_list,'ListboxTop', rev_data_counter) ;
% show data receive buffer in listbox
count = ['rev count = ', num2str(rev_data_counter)] ;
set(handles.rev_count_text, 'string', char(count)) ;
% show how many data packets i have received yet
if isOrigin_buffer_init == false
    isOrigin_buffer_init = true ;
    origin_plot_buffer = zeros(buf_size, length(var_names)) ; % init the buffer 
end

if isSpecifyVarName == true && isSpecifyCSVName == true
    cmd_data_name = 'data' ;
    data_str = rev_text(length(cmd_data_name)+1:end) ;
    data_vector = zeros(1,length(var_names)) ;
    data_cell = regexp(data_str,'\d*\.?\d*','match') ;
    len_cell = length(data_cell) ;
    for i = 1:length(len_cell)+1 % why plus 1 ? i dont know but seems right
        data_vector(i) = str2double(data_cell{i}) ;
    end
    if origin_plot_counter < buf_size
        origin_plot_counter = origin_plot_counter+1 ;
        origin_plot_buffer(origin_plot_counter,:) = data_vector ; 
        if origin_plot_counter == buf_size
            origin_plot_counter = 0 ;
            x = origin_plot_buffer(:,1) ;
            y = origin_plot_buffer(:,2) ;
            plot(handles.origin_axes,x, y) ;
            set(handles.origin_axes, 'XGrid','on')
            set(handles.origin_axes, 'YGrid','on')
        end
    end
end

if isSpecifyVarName == false
    cmd_specify_name = 'cmd-specify' ;
    cmd_specify_flag = strfind(rev_text, cmd_specify_name) ;
    if cmd_specify_flag >= 1
        specify_contents = rev_text(length(cmd_specify_name)+1:end) ;
        extractPacketVarNames(specify_contents) ;
        fmt_str = '' ;
        for i = 1:length(var_names)
            part_str = var_names{i} ;
            fmt_str = [fmt_str,'"',part_str,'"',','] ;
        end
        fmt_str = fmt_str(1:end-1) ;
        set(handles.fmt_text, 'string', fmt_str) ;
        isSpecifyVarName = true ;
    end
end % get var names and show it in Command Format
if isSpecifyCSVName == false
    cmd_csv_name = 'cmd-csv' ;
    cmd_csv_flag = strfind(rev_text, cmd_csv_name) ;
    if cmd_csv_flag >= 1
        csv_contents = rev_text(length(cmd_csv_name)+1:end) ;
        loc_1 = strfind(csv_contents, '"') ;
        new_str = csv_contents(loc_1+1:end) ;
        loc_2 = strfind(new_str, '"') ;
        csv_file_name = new_str(1:loc_2-1) ;
        isSpecifyCSVName = true ;
        csv_show_name = ['data save as csv file, named = ',csv_file_name,'.csv'] ;
        set(handles.csv_name_text, 'string', csv_show_name) ;
    end
end % get csv files name and save it to create csv file 





% --- Executes on button press in pbClosePort.
function pbClosePort_Callback(hObject, eventdata, handles)
% hObject    handle to pbClosePort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global s_handler
fclose(s_handler) ;
delete(s_handler)
set(handles.pbOpenPort, 'Enable', 'on') ;
set(handles.pbClosePort, 'Enable', 'off') ;
fprintf('close serial port') ;


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


% --- Executes during object creation, after setting all properties.
function menu_serialport_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_serialport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
        COM_RATE = 9600 ;
    case 3
        COM_RATE = 14400 ;
    case 4
        COM_RATE = 19200 ; 
    case 5
        COM_RATE = 115200 ;
end

% --- Executes during object creation, after setting all properties.
function menu_baudrate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_baudrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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


% --- Executes during object creation, after setting all properties.
function edit_send_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_send (see GCBO)
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


% --- Executes on button press in r_button.
function r_button_Callback(hObject, eventdata, handles)
% hObject    handle to r_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global isSendingNewLine
val = get(hObject, 'Value') ;
if val == 1
    isSendingNewLine = true ;
else
    isSendingNewLine = false ;
end
% Hint: get(hObject,'Value') returns toggle state of r_button



function CmdFormat_edit_Callback(hObject, eventdata, handles)
% hObject    handle to CmdFormat_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CmdFormat_edit as text
%        str2double(get(hObject,'String')) returns contents of CmdFormat_edit as a double


% --- Executes during object creation, after setting all properties.
function CmdFormat_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CmdFormat_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rev_edit_Callback(hObject, eventdata, handles)
% hObject    handle to rev_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rev_edit as text
%        str2double(get(hObject,'String')) returns contents of rev_edit as a double
global rev_text
global s_handler


% --- Executes during object creation, after setting all properties.
function rev_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rev_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function rev_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rev_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in rev_text.
function rev_text_Callback(hObject, eventdata, handles)
% hObject    handle to rev_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns rev_text contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rev_text


% --- Executes on selection change in rev_list.
function rev_list_Callback(hObject, eventdata, handles)
% hObject    handle to rev_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns rev_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rev_list


% --- Executes during object creation, after setting all properties.
function rev_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rev_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

global inform
global rev_data_counter
inform = {} ;
rev_data_counter = 0 ;


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in csv_button.
function csv_button_Callback(hObject, eventdata, handles)
% hObject    handle to csv_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of csv_button
global isCreateCSVFiles
val = get(hObject, 'Value') ;
if val == 1
    isCreateCSVFiles = true ;
else
    isCreateCSVFiles = false ;
end


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


% --- Executes during object creation, after setting all properties.
function csv_name_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to csv_name_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
