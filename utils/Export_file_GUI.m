function varargout = Export_file_GUI(varargin)
%EXPORT_FILE_GUI MATLAB code file for Export_file_GUI.fig
%      EXPORT_FILE_GUI, by itself, creates a new EXPORT_FILE_GUI or raises the existing
%      singleton*.
%
%      H = EXPORT_FILE_GUI returns the handle to a new EXPORT_FILE_GUI or the handle to
%      the existing singleton*.
%
%      EXPORT_FILE_GUI('Property','Value',...) creates a new EXPORT_FILE_GUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to Export_file_GUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      EXPORT_FILE_GUI('CALLBACK') and EXPORT_FILE_GUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in EXPORT_FILE_GUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Export_file_GUI

% Last Modified by GUIDE v2.5 02-Apr-2021 11:59:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Export_file_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Export_file_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before Export_file_GUI is made visible.
function Export_file_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for Export_file_GUI
handles.output = hObject;
handles.origfile = varargin{1};
handles.filelist = varargin{2};
handles.hashkey = varargin{3};
handles.currsoft = varargin{4};
handles.isexported = false;
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes Export_file_GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Export_file_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% DICOMRT_conversion_v01152021(origfile, filelist, hashkey, currsoft)
% varargout{1} = handles.output;
handles.output = {};
varargout{1} = handles.isexported;

% guidata(hObject, handles);
try
    delete(handles.figure1);
    drawnow;
catch EM
end
return;


% --- Executes on button press in Export_button.
function Export_button_Callback(hObject, eventdata, handles)
% hObject    handle to Export_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pop = get(handles.exportpop,'string');
popindex = get(handles.exportpop,'Value');
selected = pop{popindex};
if ~isfolder('DeepNI_files')
    mkdir('DeepNI_files');
end
switch selected
    case 'DICOMRTSS'
        if ~isempty(handles.filelist) %check if there is a reference dicom T1 image file.
            DICOMRT_conversion_v01152021(handles.origfile, handles.filelist, handles.hashkey, handles.currsoft);
            handles.isexported = true;
        else
            msgbox('Can not fine the reference DICOM file for DICOMRT exportion.');
        end
    case 'NIFTI'
        [file,path,index] = uiputfile('*.nii');
        if index
            r = jobmgr.recall(@jobmgr.example.solver, handles.hashkey); %read the cache results
            contour = r{1};
            fileID = fopen('DeepNI_files/contour.nii','w+');
            fwrite(fileID,contour,'*bit8');
            fclose(fileID);
            copyfile(append(pwd,'\DeepNI_files\contour.nii'),append(path,file));
            handles.isexported = true;
        end
end
guidata(hObject, handles);
uiresume;



% --- Executes on button press in Cancel_button.
function Cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = {};
guidata(hObject, handles);
uiresume;

% --- Executes on selection change in exportpop.
function exportpop_Callback(hObject, eventdata, handles)
% hObject    handle to exportpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns exportpop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from exportpop


% --- Executes during object creation, after setting all properties.
function exportpop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exportpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
