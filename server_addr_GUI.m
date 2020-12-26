function varargout = server_addr_GUI(varargin)
% SERVER_ADDR_GUI MATLAB code for server_addr_GUI.fig
%      SERVER_ADDR_GUI, by itself, creates a new SERVER_ADDR_GUI or raises the existing
%      singleton*.
%
%      H = SERVER_ADDR_GUI returns the handle to a new SERVER_ADDR_GUI or the handle to
%      the existing singleton*.
%
%      SERVER_ADDR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SERVER_ADDR_GUI.M with the given input arguments.
%
%      SERVER_ADDR_GUI('Property','Value',...) creates a new SERVER_ADDR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before server_addr_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to server_addr_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help server_addr_GUI

% Last Modified by GUIDE v2.5 13-Dec-2020 19:07:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @server_addr_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @server_addr_GUI_OutputFcn, ...
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


% --- Executes just before server_addr_GUI is made visible.
function server_addr_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to server_addr_GUI (see VARARGIN)

% Choose default command line output for server_addr_GUI
handles.output = hObject;
load('jobmgr/netsrv/server');
set(handles.addr,'String',server{1});
set(handles.port,'String',server{2});
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes server_addr_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = server_addr_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = 0;
varargout{1} = handles.output;
%delete(handles.figure1);
drawnow;


% --- Executes on button press in Ok.
function Ok_Callback(hObject, eventdata, handles)
% hObject    handle to Ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addr = get(handles.addr,'String');
port = get(handles.port,'String');
server{1} = addr;
server{2} = port;
save '+jobmgr/+netsrv/server' server;
handles.output = {};
guidata(hObject, handles);
delete(handles.figure1);
return;



function addr_Callback(hObject, eventdata, handles)
% hObject    handle to addr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of addr as text
%        str2double(get(hObject,'String')) returns contents of addr as a double


% --- Executes during object creation, after setting all properties.
function addr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function port_Callback(hObject, eventdata, handles)
% hObject    handle to port (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of port as text
%        str2double(get(hObject,'String')) returns contents of port as a double


% --- Executes during object creation, after setting all properties.
function port_CreateFcn(hObject, eventdata, handles)
% hObject    handle to port (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Cancel_button.
function Cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=[];
guidata(hObject, handles);
delete(handles.figure1);
