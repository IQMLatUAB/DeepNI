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

% Last Modified by GUIDE v2.5 23-Dec-2020 14:15:16

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
jobmgr.empty_cache(@jobmgr.example.solver); %empty previous processing result
try
    websave('softlist.csv','https://drive.google.com/uc?export=download&id=11NXs-UhODyqJhI_MTmgJ8QTYb8d36GrW'); % load the default argument from google drive
catch ME
    if strcmp(ME.message,'Could not access server. https://drive.google.com/uc?export=download&id=18bJNG7Rh10Ru_nZ8tP3cZAEvfRiyvxkh.')
        %warndlg('Fail to download softlist. Please check Internet connection and restart DeepNI.', '!! Warning !!');
        handles.output = 0;
        return;
    end
end
addpath utils
if ~isfile('utils/dicominfo_fastversion.m')
    version = ver;
    version = version.Release;
    if strcmp(version, '(R2020a)') || str2double(version(3:6))<2020
        str = which('dicominfo_fastversion_R2020a.m');
        copyfile(str, append(str(1:end-9),'.m'));
    else
        str = which('dicominfo_fastversion_R2020b.m');
        copyfile(str, append(str(1:end-9), '.m'));
    end
end

softlist = readcell('softlist.csv');
[r,c] = size(softlist);
for i =1:r
    for j = 1:c
        if (ismissing(softlist{i,j})) %% replace the missing value with 0x0 double
            softlist{i,j}=[];
        end
    end
end
% load the IP address and port of server
load('+jobmgr/+netsrv/server.mat');
server{1,1} = softlist{1,1};
server{1,2} = softlist{2,1};
save('+jobmgr/+netsrv/server.mat','server');


handles.inputarg = softlist(2, 2:end);
handles.default_arg = softlist(3, 2:end);
handles.currsoft = 1; % defult current soft in soft list, 1 means fastserver
set(handles.software_list,'string',softlist(1, 2:end));
set(handles.input_arg_edit,'string',handles.default_arg(handles.currsoft));
handles.job_content = cell(1,13);
handles.pre_proctacont = cell(1, 11);
set(handles.pre_process_table, 'Unit','characters','Data',handles.pre_proctacont);
set(handles.job_table, 'Unit','characters','Data',handles.job_content(1:10));
handles.non_compl = [];
guidata(hObject, handles);
uiwait(handles.figure1);







% --- Outputs from this function are returned to the command line.
function varargout = DeepNI_GUI_OutputFcn(hObject, eventdata, handles) 
jobmgr.empty_cache(@jobmgr.example.solver); %empty previous processing result
delete softlist.csv;
if isfolder('DeepNI_nii_dir')
    rmdir('DeepNI_nii_dir','s'); 
end
if isfolder('DeepNI_files')
    rmdir('DeepNI_files','s');
end
% try
%     websave('softlist.mat','https://drive.google.com/uc?export=download&id=18bJNG7Rh10Ru_nZ8tP3cZAEvfRiyvxkh'); % load the default argument from google drive
% catch ME
%     if strcmp(ME.message,'Could not access server. https://drive.google.com/uc?export=download&id=18bJNG7Rh10Ru_nZ8tP3cZAEvfRiyvxkh.')
%         warndlg('Fail to download softlist. Please check Internet connection and restart DeepNI.', '!! Warning !!');
%         return;
%     end
% end
% Get default command line output from handles structure



% --- Executes on selection change in software_list.
function software_list_Callback(hObject, eventdata, handles)
last_arg = get(handles.input_arg_edit,'String');
handles.default_arg(handles.currsoft) = last_arg;
handles.currsoft = get(handles.software_list, 'Value');
set(handles.input_arg_edit,'String',handles.default_arg(handles.currsoft));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function software_list_CreateFcn(hObject, eventdata, handles)
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
        file = handles.pre_proctacont{idx,10};
        dicomfilelist =  handles.pre_proctacont{idx,11};
    end
end
if sum(cell2mat(value(:,1))) == 0
    warndlg('None of the images were selected. Select at least one.', '!! Warning !!');
    return;
    
elseif sum(cell2mat(value(:,1))) >1
    warndlg('More than one image was selected. Select only one image.', '!! Warning !!');
    return;
end
d = get(handles.job_table,'Data'); %limit submitted job number 
[num,~]=size(d);
if num>10
    warndlg('The maximum number of submitted jobs is 10.', '!! Warning !!');
    return;
end

conbar = waitbar(0.5,'Check the Internet connection....');
try
    [job_msg, job_result] = jobmgr.server.control('check_server_connection');
catch ME
    if (strcmp(ME.identifier,'MATLAB:zmq_communicate:timeout'))
        fprintf('Attemp to reconnect.....');
    end
end
close(conbar);

bar = waitbar(0,'Submitting a job to server....');
config = struct();
config.solver = @jobmgr.example.solver;
clientdata = config;
readyfile = fullfile('DeepNI_nii_dir/',[file '.nii']);
waitbar(0.25);
fileID = fopen(readyfile, 'r');
clientdata.input = fread(fileID,'*bit8'); %% read the file
fclose(fileID);

argument = get(handles.input_arg_edit,'string');%prepareing info for jobmgr to run
%clientdata.argument = char(set_up_argument(handles.inputarg{1, sofidx},
%argument, sofidx)); not required for IQMLserver
clientdata.softnum = get(handles.software_list, 'Value') +999;
clientdata.date = datenum(datetime);
configs = {clientdata};
run_opts = struct();
run_opts.execution_method = 'job_server';
run_opts.run_names = {'clientdata'};
waitbar(0.7);
try
    r = jobmgr.run(configs, run_opts);
catch ME
    if (strcmp(ME.identifier,'MATLAB:zmq_communicate:timeout'))
        warndlg('The server did not respond in time.Please check the server address and Internet connection.', '!! Warning !!');
        close(bar);
    end
    return;
end
    
waitbar(1);
close(bar);

if isempty(r{1})
    temp2 = {'Action' 'Submitted'};
    temp2(3) = append(currsof,' ',argument);
    temp2(:, 4:10) = get_content;
    temp2{:,11} = sofidx;
    temp2{:,12} = jobmgr.struct_hash(clientdata); %find the key of this job in the hash map
    temp2{:,13} = file; %store nii filename;
    if ~isempty(dicomfilelist)
        temp2{:,14} = dicomfilelist;
    else
        temp2{:,14} = [];
    end
    if isempty(handles.job_content{3})
        handles.job_content = temp2;
    else
        handles.job_content(end+1,:) = temp2;
    end
    job_show = handles.job_content(:,1:10);
    set(handles.job_table, 'Unit','characters','Data',job_show);
    [job_msg, job_result] = jobmgr.server.control('check_job',handles.job_content{end,12});
    msgbox(job_msg);
else
    temp2 = {'Action' 'Completed'};
    temp2(3) = append(currsof,' ',argument);
    temp2(:, 4:10) = get_content;
    temp2{:,11} = sofidx;
    temp2{:,12} = jobmgr.struct_hash(clientdata); %find the key of this job in the hash map
    temp2{:,13} = file; %store nii filename;
    if ~isempty(dicomfilelist)
        temp2{:,14} = dicomfilelist;
    end
    if isempty(handles.job_content{3})
        handles.job_content = temp2;
    else
        handles.job_content(end+1,:) = temp2;
    end
    job_show = handles.job_content(:,1:10);
    set(handles.job_table, 'Unit','characters','Data',job_show);
end
guidata(hObject,handles);
    



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
set(hObject, 'Data', value);
guidata(hObject, handles);


% --- Executes on button press in Load_Image.
function Load_Image_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addpath DICOM2Nifti;
[filename, dicom_path] = uigetfile('*.*',pwd); % let user to choose particular dir
Primary_dir_nii = fullfile(pwd,'DeepNI_nii_dir');

if ~isfolder('DeepNI_nii_dir')
    mkdir('DeepNI_nii_dir','s'); 
end

if dicom_path
    addpath(dicom_path);
    temp = {};
    if isdicom(filename)%is dicom file
        [filelist fusion_filelist tempinfo] = parse_directory_for_dicom(dicom_path);
        UID = dicominfo(filename).SOPInstanceUID;
%         handles.filelist = filelist;
        temp2  = dicm2nii_DeanMod(filelist,Primary_dir_nii,'nii',UID);
        temp = {false};% prepare the table content to show on pre_process table
        temp2 = tempinfo(:, 2:8);
        temp(:, 2) = {'.nii'};
        temp(:, 3:9) = temp2;
        temp{:,10} = UID;
        temp{:,11} = filelist;
    else
        [~,filename,extention] = fileparts(filename);
        if strcmp(extention,'.nii') %is nii file
            copyfile(append(dicom_path,filename,extention), Primary_dir_nii);
            temp = cell(1,9);
            temp{1} = false;
            temp{2} = extention;
            temp{3} = append(filename, extention);
            temp{10} = filename;
            temp{:,11} = [];
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
    
 set(handles.pre_process_table, 'Unit','characters','Data',handles.pre_proctacont(:,1:9));
else
end
 guidata(hObject,handles);

    

% --- Executes on button press in Server_setting.
function Server_setting_Callback(hObject, eventdata, handles)
% hObject    handle to Server_setting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
blank = server_addr_GUI();
clear all;
return;


% --- Executes when entered data in editable cell(s) in job_table.
function job_table_CellEditCallback(hObject, eventdata, handles)
idx = eventdata.Indices;
table_info = get(handles.job_table,'Data');
job_selected = handles.job_content(idx(1), :);
act = table_info{idx(1),1};

conbar = waitbar(0.5,'Check the Internet connection....');
try
    [job_msg, job_result] = jobmgr.server.control('check_server_connection');
catch ME
    if (strcmp(ME.identifier,'MATLAB:zmq_communicate:timeout'))
        fprintf('Attemp to reconnect.....');
    end
end
close(conbar);

if table_info{idx(1),4}
    switch act
        case 'Check job'
            if strcmp(handles.job_content(idx(1),2), 'Submitted')
                [job_msg, job_result] = jobmgr.server.control('check_job',cell2mat(handles.job_content(idx(1), 12)));
                if ~isempty(job_result)
                    jobmgr.store(@jobmgr.example.solver, cell2mat(handles.job_content(idx(1), 12)), job_result); %store the result in cache
                    
                    handles.job_content{idx(1), 2} = 'Completed';
                    handles.job_content{idx(1),1} = 'Action';
                    job_show = handles.job_content(:,1:10);
                    set(handles.job_table, 'Unit','characters','Data',job_show);
                    fprintf('check_job!');
                    handles.job_content{idx(1),1} = 'Action';
                    job_show = handles.job_content(:,1:10);
                    set(handles.job_table, 'Unit','characters','Data',job_show);
                    
                    guidata(hObject, handles);
                else
                    waitfor(msgbox(job_msg));
                    handles.job_content{idx(1),1} = 'Action';
                    job_show = handles.job_content(:,1:10);
                    set(handles.job_table, 'Unit','characters','Data',job_show);
                end
            end
            handles.job_content{idx(1),1} = 'Action';
            job_show = handles.job_content(:,1:10);
            set(handles.job_table, 'Unit','characters','Data',job_show);


        case 'Cancel job'
            hash = handles.job_content{idx(1), 12};
            try
                [response_msg, ~] = jobmgr.server.control('cancel_job',hash);
            catch ME
                if (strcmp(ME.identifier,'MATLAB:zmq_communicate:timeout'))
                    warndlg('The server did not respond in time.Please check the server address and Internet connection.', '!! Warning !!');
                    close(bar);
                end
                return;
            end
            r = jobmgr.recall(@jobmgr.example.solver, hash);
            if isempty(r)
                if strcmp(response_msg,'OK')
                    handles.job_content(idx(1),:) = [];
                    if isempty(handles.job_content)
                        handles.job_content = cell(1,14);
                    end
                    handles.job_content{idx(1),1} = 'Action';
                    job_show = handles.job_content(:,1:10);
                    set(handles.job_table, 'Unit','characters','Data',job_show);
                    msgbox('This job has been canceled in server.');
                end
            else
                handles.job_content(idx(1), :) = [];
                if isempty(handles.job_content)
                    handles.job_content = cell(1,14);
                end
                handles.job_content{idx(1),1} = 'Action';
                job_show = handles.job_content(:,1:10);
                set(handles.job_table, 'Unit','characters','Data',job_show);
                %                 msgbox('Cannot cancel a job which is being processing in server.');
                %                 handles.job_content{idx(1),1} = 'Action';
                %                 job_show = handles.job_content(:,1:10);
                %                 set(handles.job_table, 'Unit','characters','Data',job_show);
            end
            
        case 'View results'
            if ~strcmp(handles.job_content(idx(1), 2), 'Submitted')
                hashkey = handles.job_content{idx(1), 12};
                sof = handles.job_content{idx(1),11};
                show_content = handles.job_content(idx(1), 3:13);
                Viewer_GUI(hashkey, sof, show_content);
                handles.job_content{idx(1),1} = 'Action';
                job_show = handles.job_content(:,1:10);
                set(handles.job_table, 'Unit','characters','Data',job_show);
            else
                msgbox('There is no result for this job. Please choose "check job".');
                handles.job_content{idx(1),1} = 'Action';
                job_show = handles.job_content(:,1:10);
                set(handles.job_table, 'Unit','characters','Data',job_show);
                
            end
        case 'Export results'
            if ~strcmp(handles.job_content(idx(1), 2), 'Submitted') && (handles.job_content{idx(1), 11}==1 || handles.job_content{idx(1), 11}==2)
                
                %                 [result,in_cache] = jobmgr.recall(@jobmgr.example.solver,handles.job_content{idx(1),12});
                %[file,path,indx] = uiputfile('outputfile');
                %                 path = uigetdir();
                path = 1;
                if path
                    isexported = Export_file_GUI(handles.job_content{idx(1), 13}, handles.job_content{idx(1), 14}, handles.job_content{idx(1), 12}, handles.job_content{idx(1), 11});
                    if isexported
                        handles.job_content{idx(1),2} = 'Exported';
                        handles.job_content{idx(1),1} = 'Action';
                        job_show = handles.job_content(:,1:10);
                        set(handles.job_table, 'Unit','characters','Data',job_show);
                    else
                        handles.job_content{idx(1),1} = 'Action';
                        job_show = handles.job_content(:,1:10);
                        set(handles.job_table, 'Unit','characters','Data',job_show);
                    end
%                     DICOMRT_conversion_v01152021(handles.job_content{idx(1), 13}, handles.job_content{idx(1), 14}, handles.job_content{idx(1), 12}, handles.job_content{idx(1), 11});
%                     bar = waitbar(0,'Exporting the file........');
%                     waitbar(0.2);
%                     fileID = fopen('DeepNI_files\contour.nii','w+');%write contour file to pwd
%                     fwrite(fileID, result{1},'*bit8');
%                     fclose(fileID);
%                     waitbar(0.6);
%                     fileID = fopen('DeepNI_files\orig.nii','w+');%write img file to pwd
%                     fwrite(fileID, result{1},'*bit8');
%                     fclose(fileID);
%                     
%                     dateinfo = datetime;
%                     sofinfo = strsplit(handles.job_content{idx(1) ,3});
%                     sofinfo = sofinfo{1};
%                     oldfile = append(pwd,'\DeepNI_files\contour.nii');
%                     newfile = append(path,'\',sofinfo,'Contour_',datestr(dateinfo,30),'.nii');
%                     copyfile(oldfile,newfile);%copy file to user destination
%                     oldfile = append(pwd,'\DeepNI_files\orig.nii');
%                     newfile = append(path,'\',sofinfo,'img_file_',datestr(dateinfo,30),'.nii');
%                     copyfile(oldfile,newfile);%copy file to user destination
%                     waitbar(1);
%                     close(bar);
%                     handles.job_content{idx(1),1} = 'Action';
%                     job_show = handles.job_content(:,1:10);
%                     set(handles.job_table, 'Unit','characters','Data',job_show);
%                 end %if no choosen destination
%                 handles.job_content{idx(1),2} = 'Exported';
%                 handles.job_content{idx(1),1} = 'Action';
%                 job_show = handles.job_content(:,1:10);
%                 set(handles.job_table, 'Unit','characters','Data',job_show);
%             elseif ~strcmp(handles.job_content(idx(1), 2), 'Submitted') && (handles.job_content{idx(1), 11}==3)
%                 [file,path,indx] = uiputfile('outputfile');
%                 if indx
%                     bar = waitbar(0,'Exporting the file........');
%                     waitbar(0.2);
%                     dateinfo = datetime;
%                     oldfile = append(pwd,'\DeepNI_files\Inho_img.nii');
%                     newfile = append(path,handles.job_content{idx(1),3},datestr(dateinfo,30),'.nii');
%                     waitbar(0.7);
%                     copyfile(oldfile, newfile);
%                     waitbar(1);
%                     close(bar);
%                     handles.job_content{idx(1),2} = 'Exported';
%                     handles.job_content{idx(1),1} = 'Action';
%                     job_show = handles.job_content(:,1:10);
%                     set(handles.job_table, 'Unit','characters','Data',job_show);
               end
               
            else
               msgbox('There is no result for this job to export. Please choose "check job".');
               handles.job_content{idx(1),1} = 'Action';
               job_show = handles.job_content(:,1:10);
               set(handles.job_table, 'Unit','characters','Data',job_show);
            end
    end
else
    handles.job_content{idx(1),1} = 'Action';
    job_show = handles.job_content(:,1:10);
    set(handles.job_table, 'Unit','characters','Data',job_show);
    
end
guidata(hObject, handles);



% --- Executes on button press in Updata_all_jobs.
function Updata_all_jobs_Callback(hObject, eventdata, handles)
handles.non_compl = [];
bar = waitbar(0, 'Updating all jobs......');
[idx,~] = size(handles.job_content);
for i=1:idx %find all non-completed jobs
    if ~strcmp(handles.job_content{i, 2}, 'Completed') && ~isempty(handles.job_content{i, 2})
        handles.non_compl = [handles.non_compl, i];
    end
end
if isempty(handles.non_compl)
    guidata(hObject, handles);
    waitbar(1);
    close(bar);
    return;
end
steps = length(handles.non_compl);
for i = 1:length(handles.non_compl)
    waitbar(i/steps);
    try
        [job_msg, job_result] = jobmgr.server.control('check_job',cell2mat(handles.job_content(handles.non_compl(i), 12)));
        
    catch ME
        if (strcmp(ME.identifier,'MATLAB:zmq_communicate:timeout'))
            warndlg('The server did not respond in time.Please check the server address and Internet connection.', '!! Warning !!');
            close(bar);
        end
        return;
    end
 
    if ~isempty(job_result)
        jobmgr.store(@jobmgr.example.solver, cell2mat(handles.job_content(handles.non_compl(i), 12)), job_result); %store the result in cache
        
        handles.job_content{handles.non_compl(i), 2} = 'Completed';
        job_show = handles.job_content(:,1:10);
        set(handles.job_table, 'Unit','characters','Data',job_show);
        fprintf('check_job!');
        guidata(hObject, handles);
    end
end
close(bar);
guidata(hObject, handles);

% --- Executes on button press in Clear_exported.
function Clear_exported_Callback(hObject, eventdata, handles)

[idx,~] = size(handles.job_content);
to_del = [];
if idx
    for i = 1:idx
        if strcmp(handles.job_content(i, 2), 'Exported')
           to_del = [to_del, i]; 
        end
    end
    for i = i:length(to_del)
        handles.job_content(to_del(i)) = [];
    end
end
guidata(hObject, handles);


% --- Executes on button press in Cancel_all_jobs.
function Cancel_all_jobs_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_all_jobs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.job_content = cell(1,13);
set(handles.job_table, 'Unit','characters','Data',handles.job_content(1:10));
jobmgr.empty_cache(@jobmgr.example.solver); %empty previous processing result
guidata(hObject, handles);
