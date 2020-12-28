function varargout = Viewer_GUI(varargin)
% VIEWER_GUI MATLAB code for Viewer_GUI.fig
%      VIEWER_GUI, by itself, creates a new VIEWER_GUI or raises the existing
%      singleton*.
%
%      H = VIEWER_GUI returns the handle to a new VIEWER_GUI or the handle to
%      the existing singleton*.
%
%      VIEWER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWER_GUI.M with the given input arguments.
%
%      VIEWER_GUI('Property','Value',...) creates a new VIEWER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Viewer_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Viewer_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Viewer_GUI

% Last Modified by GUIDE v2.5 15-Dec-2020 10:11:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Viewer_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Viewer_GUI_OutputFcn, ...
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


% --- Executes just before Viewer_GUI is made visible.
function Viewer_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Viewer_GUI (see VARARGIN)

% Choose default command line output for Viewer_GUI
addpath files
addpath software_seg_table;
handles.btndwn_fcn2        = @(hObject,eventdata)Viewer_GUI('axes2_ButtonDownFcn',hObject,eventdata,guidata(hObject));
handles.btndwn_fcn3        = @(hObject,eventdata)Viewer_GUI('axes3_ButtonDownFcn',hObject,eventdata,guidata(hObject));
handles.btndwn_fcn1        = @(hObject,eventdata)Viewer_GUI('axes1_ButtonDownFcn',hObject,eventdata,guidata(hObject));
handles.btndwn_fcn4        = @(hObject,eventdata)Viewer_GUI('axes4_ButtonDownFcn',hObject,eventdata,guidata(hObject));
handles.btndwn_fcn5        = @(hObject,eventdata)Viewer_GUI('axes5_ButtonDownFcn',hObject,eventdata,guidata(hObject));
handles.btndwn_fcn6        = @(hObject,eventdata)Viewer_GUI('axes6_ButtonDownFcn',hObject,eventdata,guidata(hObject));
iptPointerManager(handles.figure1, 'enable');
% Have the pointer change to a cross when the mouse enters an axes object:
iptSetPointerBehavior(handles.axes2, @(gcf, currentPoint)set(handles.figure1, 'Pointer', 'cross'));
iptSetPointerBehavior(handles.axes3, @(gcf, currentPoint)set(handles.figure1, 'Pointer', 'cross'));
iptSetPointerBehavior(handles.axes1, @(gcf, currentPoint)set(handles.figure1, 'Pointer', 'cross'));
iptSetPointerBehavior(handles.axes4, @(gcf, currentPoint)set(handles.figure1, 'Pointer', 'cross'));
iptSetPointerBehavior(handles.axes5, @(gcf, currentPoint)set(handles.figure1, 'Pointer', 'cross'));
iptSetPointerBehavior(handles.axes6, @(gcf, currentPoint)set(handles.figure1, 'Pointer', 'cross'));
handles.output = hObject;
axes(handles.axes1);image([0 0;0 0]);colormap gray;
axis off;
axes(handles.axes2);image([0 0;0 0]);colormap gray;
axis off;
axes(handles.axes3);image([0 0;0 0]);colormap gray;
axis off;
axes(handles.axes4);image([0 0;0 0]);colormap gray;
axis off;
axes(handles.axes5);image([0 0;0 0]);colormap gray;
axis off;
axes(handles.axes6);image([0 0;0 0]);colormap gray;
axis off;
bar = waitbar(0,'Loading image......');
handles.now_label = 1;
handles.result_img_contra = 0; %initial contra value
handles.original_img_contra = 0;
% Update handles structure
handles.hashkey = varargin{1};
handles.currsoft = varargin{2}; % defult current soft in soft list, 1 means fastserver
handles.content_show = varargin{3};
show_info = handles.content_show(1:8);
set(handles.img_content,'Units', 'characters', 'Data', show_info);
r = jobmgr.recall(@jobmgr.example.solver, handles.hashkey); %get the cache file
    
waitbar(0.6);
if handles.currsoft ==1 || handles.currsoft ==2
    contour = r{1};
    img_file = r{2};
    
    %fwrite mgz file from jobmgr
    fileID = fopen('files/img_file.mgz','w');
    fwrite(fileID,img_file,'*bit8');
    fclose(fileID);
    
    fileID = fopen('files/Contour.mgz','w');
    fwrite(fileID,contour,'*bit8');
    fclose(fileID);
    
    Primary_dir = pwd;
    ima = fullfile(Primary_dir,'files/img_file.mgz');
    contour = fullfile(Primary_dir,'files/Contour.mgz');
    waitbar(0.8);
    % read mask and image file from the mgz files
    [vol2, M2, mr_parms2, volsz] = load_mgz(ima);
    vol2 = flip(permute(vol2, [3 1 2]),1);
    [vol4, M4, mr_parms2, volsz] = load_mgz(contour);
    vol4 = flip(permute(vol4, [3 1 2]),1);
    handles.mask_all = vol4;
    handles.image_vol = vol2;
    vec1 = unique(vol4(:));
    
    if (handles.currsoft ==1)%Fastserver
        load freesurfer_labels.mat num str;
        vec1(find(vec1==0)) = [];
        vec1 = sort(vec1);
        handles.label_vec = vec1;
        for idx = 1:length(vec1)
            r_idx = find(num(:,1) == vec1(idx));
            handles.table{idx, 1} = vec1(idx);
            handles.table{idx, 2} = str{r_idx, 2};
            handles.table{idx, 3} = length(find(vol4==vec1(idx)));
            handles.label_str{idx} = [num2str(vec1(idx)) ':' str{r_idx, 2}];
        end
    elseif(handles.currsoft ==2) %DARTS
        load freesurfer_labels.mat num str;
        load DARTS_labels.mat p;
        vec2 = vec1;
        vec1 = p; % If using DARTS...
        vec1(find(vec1==0)) = [];
        vec1 = sort(vec1);
        handles.label_vec = vec1;
        for idx = 1:length(vec1)
            r_idx = find(num(:,1) == vec1(idx));
            handles.table{idx, 1} = vec1(idx);
            handles.table{idx, 2} = str{r_idx, 2};
            % handles.table{idx, 3} = length(find(vol4==vec1(idx))); %Fastsrf
            handles.table{idx, 3} = length(find(vol4==vec2(idx))); %DARTAS
            handles.label_str{idx} = [num2str(vec1(idx)) ':' str{r_idx, 2}];
        end
    end
    set(handles.Contourlist, 'String', handles.label_str);
    handles.now_label = 0;
    set(handles.Contourlist, 'Value', 1);
    guidata(hObject, handles);
    handles = update_image_display(hObject, handles);
elseif handles.currsoft ==3
    Inho_img = r{1};
    V = zeros(10,10,10);
    niftiwrite(V, '/files/Inho_img.nii');
    fileID = fopen('/files/Inho_img.nii','w');
    fwrite(fileID, Inho_img,'*bit8');
    handles.image_vol = double(niftiread('/files/Inho_img.nii'));
    [x,y,z] = size(handles.image_vol);
    handles.mask1 = zeros(x,y,z);
    handles.now_label = 0;
    handles.outcurrent_slice = round(size(handles.image_vol, 3)/2);
    handles.outcurrent_i = round(size(handles.image_vol, 1)/2);
    handles.outcurrent_j = round(size(handles.image_vol, 2)/2);

    handles = update_image_display(hObject, handles);
end
    


orifile = handles.content_show{:,11};
orifile = fullfile('nii_dir/',[orifile '.nii']);%show the original image before processing
handles.ori_img = double(niftiread(orifile));
handles.current_slice = round(size(handles.ori_img, 3)/2);
handles.current_i = round(size(handles.ori_img, 1)/2);
handles.current_j = round(size(handles.ori_img, 2)/2);

handles = refresh_all(handles);

waitbar(1);
close(bar);
guidata(hObject, handles); % handles store



% UIWAIT makes Viewer_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Viewer_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;





% --- Executes on selection change in Contourlist.
function Contourlist_Callback(hObject, eventdata, handles)
% hObject    handle to Contourlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_image_display(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns Contourlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Contourlist


% --- Executes during object creation, after setting all properties.
function Contourlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Contourlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = update_image_display(hObject, handles)
if handles.currsoft ==1 || handles.currsoft ==2
    if (handles.currsoft ==1)
        now_label_new = handles.label_vec(get(handles.Contourlist, 'Value'));
    elseif(handles.currsoft ==2)
        now_label_new = get(handles.Contourlist, 'Value')-1;
    end
    
    
    if handles.now_label ~= now_label_new
        handles.now_label = now_label_new;
        handles.mask1 = handles.mask_all==now_label_new;
    else
        handles.mask1 = handles.mask_all==now_label_new;
    end
    
    tempvec = squeeze(sum(sum(handles.mask1,1),2));
    tempvec = find(tempvec>0);
    handles.outcurrent_slice = tempvec(round(length(tempvec)/2));
    guidata(handles.axes4, handles);
    tempvec = squeeze(sum(sum(handles.mask1,1),3));
    tempvec = find(tempvec>0);
    handles.outcurrent_j = tempvec(round(length(tempvec)/2));
    guidata(handles.axes4, handles);
    tempvec = squeeze(sum(sum(handles.mask1,2),3));
    tempvec = find(tempvec>0);
    handles.outcurrent_i = tempvec(round(length(tempvec)/2));
    guidata(handles.axes4, handles);
    handles = refresh_allout(handles);
    guidata(hObject, handles);
    guidata(handles.axes4, handles);
else
    handles = refresh_allout(handles);
end

return;

function handles = refresh_all(handles)

contra = handles.original_img_contra;
%img_to_show = imrotate(handles.ori_img(:, :, handles.current_slice), 90);
ima = imrotate(handles.ori_img(:, :, handles.current_slice),90);
ima = gray2ind(ima/max(ima(:)), 256);
img_to_show = imadjust(ima, [contra ; 1-contra],[]);%adjust contrast
handles.Img1 = imagesc(img_to_show, 'Parent', handles.axes1);
set(handles.Img1, 'ButtonDownFcn', handles.btndwn_fcn1);
colormap gray;
set(handles.axes1,'XTick', [], 'YTick', []);

ima = imrotate(squeeze(handles.ori_img(handles.current_i, :, :)), 90);
ima = gray2ind(ima/max(ima(:)), 256);
img_to_show = imadjust(ima, [contra ; 1-contra],[]);%adjust contrast
handles.Img2 = imagesc(img_to_show, 'Parent', handles.axes2);
set(handles.Img2, 'ButtonDownFcn', handles.btndwn_fcn2);
colormap gray;
set(handles.axes2,'XTick', [], 'YTick', []);

ima = imrotate(squeeze(handles.ori_img(:, handles.current_j, :)), 90);
ima = gray2ind(ima/max(ima(:)), 256);
img_to_show = imadjust(ima, [contra ; 1-contra],[]);%adjust contrast
handles.Img3 = imagesc(img_to_show, 'Parent', handles.axes3);
set(handles.Img3, 'ButtonDownFcn', handles.btndwn_fcn3);
colormap gray;
set(handles.axes3,'XTick', [], 'YTick', []);
return;

function handles = refresh_allout(handles)
contra = handles.result_img_contra;
mask = handles.mask1(:, :, handles.outcurrent_slice);
ima = handles.image_vol(:, :, handles.outcurrent_slice);
map1 = colormap('gray');
ima = ind2rgb(gray2ind(ima/max(ima(:)), 256), map1);
ima = imadjust(ima, [contra ; 1-contra]); %contract adjust
if handles.currsoft ==1 || handles.currsoft ==2
    img_to_show = fuse_img(ima, mask); %overlap the contour and image
else
    img_to_show = ima;
end
handles.Img4 = imagesc(img_to_show, 'Parent', handles.axes4);
set(handles.Img4, 'ButtonDownFcn', handles.btndwn_fcn4);
colormap gray;
set(handles.axes4,'XTick', [], 'YTick', []);

mask = imrotate(squeeze(handles.mask1(handles.outcurrent_i, :, :)), 270);
ima = imrotate(squeeze(handles.image_vol(handles.outcurrent_i, :, :)), 270);
map1 = colormap('gray');
ima = ind2rgb(gray2ind(ima/max(ima(:)), 256), map1);
ima = imadjust(ima, [contra ; 1-contra]); %contract adjust
if handles.currsoft ==1 || handles.currsoft ==2
    img_to_show = fuse_img(ima, mask); %overlap the contour and image
else
    img_to_show = ima;
end

handles.Img5 = imagesc(img_to_show, 'Parent', handles.axes5);
set(handles.Img5, 'ButtonDownFcn', handles.btndwn_fcn5);
colormap gray;
set(handles.axes5,'XTick', [], 'YTick', []);

mask = imrotate(squeeze(handles.mask1(:, handles.outcurrent_j, :)), 270);
ima = imrotate(squeeze(handles.image_vol(:, handles.outcurrent_j, :)), 270);
map1 = colormap('gray');
ima = ind2rgb(gray2ind(ima/max(ima(:)), 256), map1);
ima = imadjust(ima, [contra ; 1-contra]); %contract adjust
if handles.currsoft ==1 || handles.currsoft ==2
    img_to_show = fuse_img(ima, mask); %overlap the contour and image
else
    img_to_show = ima;
end
handles.Img6 = imagesc(img_to_show, 'Parent', handles.axes6);
set(handles.Img6, 'ButtonDownFcn', handles.btndwn_fcn6);
colormap gray;
set(handles.axes6,'XTick', [], 'YTick', []);
return;


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Axial
a = get(handles.axes1,'currentpoint');
handles.current_i = round(a(1,1));
handles.current_j = size(handles.ori_img, 2)-round(a(1,2))+1;
handles = refresh_all(handles);
guidata(handles.axes2, handles);

return;


% --- Executes on mouse press over axes background.
function axes3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on mouse press over axes background.
%coronal
a = get(handles.axes3,'currentpoint');
handles.current_slice = size(handles.ori_img, 3) - round(a(1,2))+1;
handles.current_i = round(a(1,1));
handles = refresh_all(handles);
guidata(handles.axes2, handles);

return;

function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

%Sagittal
a = get(handles.axes2,'currentpoint');
handles.current_slice = size(handles.ori_img, 3) - round(a(1,2))+1;
handles.current_j = round(a(1,1));
handles = refresh_all(handles);
guidata(handles.axes2, handles);

return;



% --- Executes on mouse press over axes background.
function axes4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Axial
a = get(handles.axes4,'currentpoint');
handles.outcurrent_i = round(a(1,2));
handles.outcurrent_j = round(a(1,1));
handles = refresh_allout(handles);
guidata(handles.axes4, handles);

% --- Executes on mouse press over axes background.
function axes5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Sagittal
a = get(handles.axes5,'currentpoint');
%handles.outcurrent_slice = size(handles.image_vol, 3) - round(a(1,2))+1;
handles.outcurrent_slice = round(a(1,2))+1;
handles.outcurrent_j = size(handles.image_vol, 3) - round(a(1,1));
handles = refresh_allout(handles);
guidata(handles.axes4, handles);

return;

% --- Executes on mouse press over axes background.
function axes6_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%coronal
a = get(handles.axes6,'currentpoint');
%handles.outcurrent_slice = size(handles.image_vol, 3) - round(a(1,2))+1;
handles.outcurrent_slice = round(a(1,2))+1;
handles.outcurrent_i = size(handles.image_vol, 1) - round(a(1,1));
handles = refresh_allout(handles);
guidata(handles.axes4, handles);

return;


% --- Executes on selection change in software_list.
function software_list_Callback(hObject, eventdata, handles)
% hObject    handle to software_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
now_soft = get(handles.software_list, 'Value');
if (now_soft ~= handles.currsoft)
     handles.inputarg{2, handles.currsoft} = get(handles.inputargument_edit, 'string');
     handles.currsoft = now_soft;
end

set(handles.inputargument_edit, 'string', handles.inputarg{2, handles.currsoft});

guidata(hObject,handles);

    
% Hints: contents = cellstr(get(hObject,'String')) returns software_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from software_list


% --- Executes on slider movement.
function result_contrastslider_Callback(hObject, eventdata, handles)
% hObject    handle to result_contrastslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.result_img_contra = get(hObject,'Value');
%handles.image_vol = imadjustn(handles.image_vol, [contra, 1-contra],[]);
handles = refresh_allout(handles);
guidata(handles.axes4, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function result_contrastslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to result_contrastslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function original_contrastslider_Callback(hObject, eventdata, handles)
% hObject    handle to original_contrastslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.original_img_contra = get(hObject,'Value');
handles = refresh_all(handles);
guidata(handles.axes2, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function original_contrastslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to original_contrastslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
