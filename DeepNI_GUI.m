function varargout = DeepNI_GUI(varargin)
% DEEPNI_GUI MATLAB code for DeepNI_GUI.fig
%      DEEPNI_GUI, by itself, creates a new DEEPNI_GUI or raises the existing
%      singleton*.
%
%      H = DEEPNI_GUI returns the handle to a new DEEPNI_GUI or the handle to
%      the existing singleton*.
%
%      DEEPNI_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEEPNI_GUI.M with the given input arguments.
%
%      DEEPNI_GUI('Property','Value',...) creates a new DEEPNI_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DeepNI_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DeepNI_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DeepNI_GUI

% Last Modified by GUIDE v2.5 15-Dec-2020 12:48:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DeepNI_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DeepNI_GUI_OutputFcn, ...
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


% --- Executes just before DeepNI_GUI is made visible.
function DeepNI_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DeepNI_GUI (see VARARGIN)

websave('softlist.mat','https://drive.google.com/uc?export=download&id=18bJNG7Rh10Ru_nZ8tP3cZAEvfRiyvxkh'); % load the default argument from google drive
handles.inputarg = load('softlist.mat').softlist(2, :);
handles.default_arg = load('softlist.mat').softlist(3,:);
handles.currsoft = 1; % defult current soft in soft list, 1 means fastserver
set(handles.software_list,'string',load('softlist.mat').softlist(1, :));
set(handles.input_arg_edit,'string',handles.default_arg(handles.currsoft));
handles.result_content = cell(1, 9);
handles.waiting_content = cell(1,13);
handles.pre_proctacont = cell(1, 9);
set(handles.pre_process_table, 'Unit','characters','Data',handles.pre_proctacont);
set(handles.waiting_table, 'Unit','characters','Data',handles.waiting_content(1:10));
guidata(hObject, handles);
uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = DeepNI_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
jobmgr.empty_cache(@jobmgr.example.solver); %empty previous processing result
delete(append(pwd,'\nii_dir\*.nii'));
% Get default command line output from handles structure



% --- Executes on selection change in software_list.
function software_list_Callback(hObject, eventdata, handles)
% hObject    handle to software_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns software_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from software_list
last_arg = get(handles.input_arg_edit,'String');
handles.default_arg(handles.currsoft) = last_arg;
handles.currsoft = get(handles.software_list, 'Value');
set(handles.input_arg_edit,'String',handles.default_arg(handles.currsoft));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function software_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to software_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run_remotely_button.
function run_remotely_button_Callback(hObject, eventdata, handles)
value = get(handles.pre_process_table, 'Data');
sofidx = get(handles.software_list,'value');
sofstr = get(handles.software_list,'string');
currsof = sofstr{sofidx}; % the name of software user choose

for idx = 1: size(value,1)
    if cell2mat(value(idx,1)) == 1
        get_content = value(idx,3:9);
        file = value{idx,10};
    end
end
if sum(cell2mat(value(:,1))) == 0
    %if sum(cell2mat(value(:,2))) == 0
        warndlg('None of the studies were selected. Select at least one study.', '!! Warning !!');
        return;
    %end
    
elseif sum(cell2mat(value(:,1))) >1
    warndlg('More than one study was selected. Select only one study.', '!! Warning !!');
    return;
end
bar = waitbar(0,'Submitted job to server....');
config = struct();
config.solver = @jobmgr.example.solver;
clientdata = config;
readyfile = fullfile('nii_dir/',[file '.nii']);
waitbar(0.25);
fileID = fopen(readyfile, 'r');
clientdata.input = fread(fileID,'*bit8'); %% read the file
fclose(fileID);
%input close file
argument = get(handles.input_arg_edit,'string');
clientdata.argument = char(set_up_argument(handles.inputarg{1, sofidx}, argument, sofidx));
clientdata.softnum = get(handles.software_list, 'Value');
configs = {clientdata};
run_opts = struct();
run_opts.execution_method = 'job_server';
run_opts.run_names = {'clientdata'};
waitbar(0.6);
r = jobmgr.run(configs, run_opts);
waitbar(1);
close(bar);
%r = {jobmgr.recall(clientdata.solver, jobmgr.struct_hash(clientdata))};%get the cache file
if isempty(r{1})
    temp2 = {'Action' 'Submitted'};
    temp2(3) = append(currsof,' ',argument);
    temp2(:, 4:10) = get_content;
    temp2{:,11} = sofidx;
    temp2{:,12} = jobmgr.struct_hash(clientdata); %find the key of this job in the hash map
    temp2{:,13} = file; %store nii filename;
    if isempty(handles.waiting_content{3})
        handles.waiting_content = temp2;
    else
        handles.waiting_content(end+1,:) = temp2;
    end
    waiting_show = handles.waiting_content(:,1:10);
    set(handles.waiting_table, 'Unit','characters','Data',waiting_show);
end
guidata(hObject,handles);
    


% --- Executes on button press in run_locally_button.
function run_locally_button_Callback(hObject, eventdata, handles)
% hObject    handle to run_locally_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in view_img.
function view_img_Callback(hObject, eventdata, handles)
value = get(handles.result_table, 'Data');
for idx = 1: size(value,1)
    if cell2mat(value(idx,1)) == 1
        hashkey = handles.result_content(idx, 11);
        sof = handles.result_content(idx, 10);
        show_content = value(idx, 2:9);
    end
end
if sum(cell2mat(value(:,1))) == 0
        warndlg('None of the studies were selected. Select at least one study.', '!! Warning !!');
        return;
    
elseif sum(cell2mat(value(:,1))) >1
    warndlg('More than one study was selected. Select only one study.', '!! Warning !!');
    return;
    
end

Viewer_GUI(hashkey, sof, show_content);


% --- Executes on button press in export_img.
function export_img_Callback(hObject, eventdata, handles)
% hObject    handle to export_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in check_job_isdone.
function check_job_isdone_Callback(hObject, eventdata, handles)
value = get(handles.waiting_table, 'Data');

for idx = 1: size(value,1)
    if cell2mat(value(idx,1)) == 1
        processing_info = strsplit(value{idx,2});
        argument = processing_info{2};
        sof = handles.waiting_content{idx,10};
        checkfile = append(value{idx, 3},'_',value{idx, 8},'_',value{idx, 9});
        finishidx = idx;
    end
end
if sum(cell2mat(value(:,1))) == 0
    %if sum(cell2mat(value(:,2))) == 0
        warndlg('None of the studies were selected. Select at least one study.', '!! Warning !!');
        return;
    %end
    
elseif sum(cell2mat(value(:,1))) >1
    warndlg('More than one study was selected. Select only one study.', '!! Warning !!');
    return;
    
end
config = struct();
config.solver = @jobmgr.example.solver;
clientdata = config;
readyfile = fullfile('nii_dir/',[checkfile '.nii']);

fileID = fopen(readyfile, 'r');
clientdata.input = fread(fileID,'*bit8'); %% read the file
fclose(fileID);

clientdata.argument = set_up_argument(handles.inputarg{1, sof}, argument, sof);
clientdata.softnum = sof;
configs = {clientdata};
run_opts = struct();
run_opts.execution_method = 'job_server';
run_opts.run_names = {'clientdata'};
r = jobmgr.run(configs, run_opts);
if ~isempty(r{1})
    if isempty(handles.result_content{1,3})
        handles.result_content = handles.waiting_content(finishidx, :);
    else
        handles.result_content(end+1 ,:) = handles.waiting_content(finishidx, :);
    end
    handles.waiting_content(finishidx, :) = []; % remove the finish job for waiting table;
    if isempty(handles.waiting_content)
        handles.waiting_content = cell(1,11);
    end
        
    waiting_show = handles.waiting_content(:,1:9);
    result_show = handles.result_content(:,1:9);
    set(handles.waiting_table, 'Unit','characters','Data',waiting_show);
    set(handles.result_table, 'Unit','characters','Data',result_show);
else
    waiting_msg = jobmgr.server.control('check_job',jobmgr.struct_hash(clientdata));
     waitfor(msgbox(waiting_msg));
end
guidata(hObject, handles);

function input_arg_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_arg_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_arg_edit as text
%        str2double(get(hObject,'String')) returns contents of input_arg_edit as a double


% --- Executes during object creation, after setting all properties.
function input_arg_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in pre_process_table.
function pre_process_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to pre_process_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when entered data in editable cell(s) in pre_process_table.
function pre_process_table_CellEditCallback(hObject, eventdata, handles)
value = get(hObject,'Data');
%[r c] = size(value);
set(hObject, 'Data', value);
guidata(hObject, handles);


% --- Executes on button press in Load_Image.
function Load_Image_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addpath DICOM2Nifti;
[filename, dicom_path] = uigetfile('*.*',pwd); % let user to choose particular dir 
Primary_dir_nii = fullfile(pwd,'nii_dir');

if dicom_path
addpath(dicom_path);
temp = {};
if isdicom(filename)%is dicom file
    %[filelist fusion_filelist tempinfo] = parse_directory_for_dicom(Primary_dir_dicom);
    [filelist fusion_filelist tempinfo] = parse_directory_for_dicom(dicom_path);
    UID = dicominfo(filename).SOPInstanceUID;
    temp2  = dicm2nii_DeanMod(filelist,Primary_dir_nii,'nii',UID);
    temp = {false};% prepare the table content to show on pre_process table 
    temp2 = tempinfo(:, 2:8);
    temp(:, 2) = {'.nii'};
    temp(:, 3:9) = temp2;
    temp{:,10} = UID;
else
    [~,filename,extention] = fileparts(filename);
    if strcmp(extention,'.nii') %is nii file
        copyfile(append(filename,extention), 'nii_dir');
        temp = cell(1,9); 
        temp{1} = false;
        temp{2} = extention;
        temp{3} = append(filename, extention);
        temp{10} = filename;
    elseif strcmp(extention,'.mgz') % is mgz file
        temp = cell(1,9);
        temp{1} = false;
        temp{2} = extention;
        temp{3} = append(filename, extention);
    end
end
if isempty(temp)
    warndlg('Please select Dicom or nii file.', '!! Warning !!');
    return;
end

 if isempty(handles.pre_proctacont{1,3}) %show content to pre_process_table
     handles.pre_proctacont = temp;
 else
     handles.pre_proctacont(end+1, :) = temp;
 end
     
 set(handles.pre_process_table, 'Unit','characters','Data',handles.pre_proctacont);
else
end
 guidata(hObject,handles);


% --- Executes on button press in Cancel_job.
function Cancel_job_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_job (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = get(handles.waiting_table, 'Data');

for idx = 1: size(value,1)
    if cell2mat(value(idx,1)) == 1
        hash = handles.waiting_content{11};
    end
end
if sum(cell2mat(value(:,1))) == 0
    warndlg('None of the studies were selected. Select at least one study.', '!! Warning !!');
    return;
    
elseif sum(cell2mat(value(:,1))) >1
    warndlg('More than one study was selected. Select only one study.', '!! Warning !!');
    return;
end
response_msg = jobmgr.server.control('cancel_job',hash);
if strcmp(response_msg,'OK')
    handles.waiting_content(idx,:) = [];
    if isempty(handles.waiting_content)
        handles.waiting_content = cell(1,11);
    end
    waiting_show = handles.waiting_content(:,1:9);
    set(handles.waiting_table, 'Unit','characters','Data',waiting_show);
    waitfor(msgbox('This job has been canceled in server.'));
end
guidata(hObject, handles);
    





% --- Executes on button press in Server_setting.
function Server_setting_Callback(hObject, eventdata, handles)
% hObject    handle to Server_setting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
blank = server_addr_GUI();
clear all;
return;


% --- Executes when entered data in editable cell(s) in waiting_table.
function waiting_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to waiting_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
idx = eventdata.Indices;
table_info = get(handles.waiting_table,'Data');
job_selected = handles.waiting_content(idx(1), :); 
act = table_info{idx(1),1};
if table_info{idx(1),4}
    switch act
        case 'Check_job'
            bar = waitbar(0,'Check this job in server....');
            config = struct();
            config.solver = @jobmgr.example.solver;
            clientdata = config;
            checkfile = job_selected{1,13};
            sof = job_selected{1,11};
            processing_info = strsplit(job_selected{idx(1),3});
            argument = processing_info{2};
            
            readyfile = fullfile('nii_dir/',[checkfile '.nii']);
            waitbar(0.5);
            fileID = fopen(readyfile, 'r');
            clientdata.input = fread(fileID,'*bit8'); %% read the file
            fclose(fileID);
            waitbar(0.7);
            clientdata.argument = set_up_argument(handles.inputarg{1, sof}, argument, sof);
            clientdata.softnum = sof;
            configs = {clientdata};
            run_opts = struct();
            run_opts.execution_method = 'job_server';
            run_opts.run_names = {'clientdata'};
            r = jobmgr.run(configs, run_opts);
            waitbar(1);
            close(bar);
            if ~isempty(r{1})
                handles.waiting_content{idx(1), 2} = 'Completed';
                waiting_show = handles.waiting_content(:,1:10);
                set(handles.waiting_table, 'Unit','characters','Data',waiting_show);
            else
                waiting_msg = jobmgr.server.control('check_job',jobmgr.struct_hash(clientdata));
                waitfor(msgbox(waiting_msg));
            end
            handles.waiting_content{idx(1),1} = 'Action';
            waiting_show = handles.waiting_content(:,1:10);
            set(handles.waiting_table, 'Unit','characters','Data',waiting_show);
        case 'Cancel_job'
            hash = handles.waiting_content{idx(1), 12};
            response_msg = jobmgr.server.control('cancel_job',hash);
            r = jobmgr.recall(@jobmgr.example.solver, hash);
            if isempty(r)                
                if strcmp(response_msg,'OK')
                    handles.waiting_content(idx(1),:) = [];
                    if isempty(handles.waiting_content)
                        handles.waiting_content = cell(1,13);
                    end
                    handles.waiting_content{idx(1),1} = 'Action';
                    waiting_show = handles.waiting_content(:,1:10);
                    set(handles.waiting_table, 'Unit','characters','Data',waiting_show);
                    waitfor(msgbox('This job has been canceled in server.'));
                end
            else
                waitfor(msgbox('Cannot cancel a job which is being processing in server.'));
                handles.waiting_content{idx(1),1} = 'Action';
                waiting_show = handles.waiting_content(:,1:10);
                set(handles.waiting_table, 'Unit','characters','Data',waiting_show);
            end
            
        case 'View_image'
            if strcmp(handles.waiting_content(idx(1), 2), 'Completed');
                hashkey = handles.waiting_content{idx(1), 12};
                sof = handles.waiting_content{idx(1),11};
                show_content = handles.waiting_content(idx(1), 3:13);
                Viewer_GUI(hashkey, sof, show_content);
                handles.waiting_content{idx(1),1} = 'Action';
                waiting_show = handles.waiting_content(:,1:10);
                set(handles.waiting_table, 'Unit','characters','Data',waiting_show);
            else
                waitfor(msgbox('There is no result for this job. Please choose "check job".'));
                handles.waiting_content{idx(1),1} = 'Action';
                waiting_show = handles.waiting_content(:,1:10);
                set(handles.waiting_table, 'Unit','characters','Data',waiting_show);

            end
        case 'Export_image'
            if strcmp(handles.waiting_content(idx(1), 2), 'Completed') && (handles.waiting_content{idx(1), 11}==1 || handles.waiting_content{idx(1), 11}==2)
               
               [result,in_cache] = jobmgr.recall(@jobmgr.example.solver,handles.waiting_content{idx(1),12});
               [file,path,indx] = uiputfile('outputfile');
               if indx
               bar = waitbar(0,'Exporting the file........');
               waitbar(0.2);
               fileID = fopen('Contour.mgz','w');%write contour file to pwd
               fwrite(fileID, result{1},'*bit8');
               fclose(fileID);
               waitbar(0.6);
               fileID = fopen('img_file.mgz','w');%write img file to pwd
               fwrite(fileID, result{1},'*bit8');
               fclose(fileID);
               
               dateinfo = datetime;
               oldfile = append(pwd,'\Contour.mgz');
               newfile = append(path,'Contour_',num2str(yyyymmdd(dateinfo)),'_',num2str(hour(dateinfo)),num2str(minute(dateinfo)),'.mgz');
               copyfile(oldfile,newfile);%copy file to user destination
               oldfile = append(pwd,'\img_file.mgz');
               newfile = append(path,'img_file_',num2str(yyyymmdd(dateinfo)),'_',num2str(hour(dateinfo)),num2str(minute(dateinfo)),'.mgz');
               copyfile(oldfile,newfile);%copy file to user destination
               waitbar(1);
               close(bar);
               handles.waiting_content{idx(1),1} = 'Action';
               waiting_show = handles.waiting_content(:,1:10);
               set(handles.waiting_table, 'Unit','characters','Data',waiting_show);
               end %if no choosen destination
               handles.waiting_content{idx(1),1} = 'Action';
               waiting_show = handles.waiting_content(:,1:10);
               set(handles.waiting_table, 'Unit','characters','Data',waiting_show);
            else
               waitfor(msgbox('There is no result for this job to export. Please choose "check job".'));
               handles.waiting_content{idx(1),1} = 'Action';
               waiting_show = handles.waiting_content(:,1:10);
               set(handles.waiting_table, 'Unit','characters','Data',waiting_show);
            end
    end
else
    handles.waiting_content{idx(1),1} = 'Action';
    waiting_show = handles.waiting_content(:,1:10);
    set(handles.waiting_table, 'Unit','characters','Data',waiting_show);
    
end
guidata(hObject, handles);

    
