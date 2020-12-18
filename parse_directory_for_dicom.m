function varargout = parse_directory_for_dicom(dirname);

all_files_list = list_all_files(dirname, {}, '');




study_ID = [];  % create empty cell array
study_description_name = {};
dirlen = length(all_files_list);
filelist = {};
if dirlen ==0
    return;
end

do_fields_table= [8 4144; 8 4158; 32 13; 32 14];
dicomdict('set', 'dicom-dict_fastMR.txt');
dictionary = dicomdict('get_current');

%tic
timing_n = floor(dirlen/5);

h = waitbar(0,'Parsing the directory for DICOM files. Please wait...');
steps = dirlen;

for i = 1:dirlen
    if mod(i, timing_n) == 0
        waitbar(i / steps);
    end
    
    info1 = dicominfo_fastversion(all_files_list{i}, do_fields_table, dictionary);
    
    if ~isempty(info1) && isfield(info1, 'StudyInstanceUID') 
        %warndlg('No dicom files found');
    %else
        %find_location = strcmp(study_ID, info1.StudyID);  % "find(study_ID == info1.StudyID)" is unavailable because info1.StudyID is a string
        find_location = strcmp(study_ID, info1.StudyInstanceUID);  % "find(study_ID == info1.StudyID)" is unavailable because info1.StudyID is a string
        if ~isfield(info1, 'SeriesDescription') % to handle the anonymized images
            info1.SeriesDescription = '';
        end
        
        if sum(find_location) == 0
            % new ID for the ID List
            %study_ID{end+1} = info1.StudyID;
            study_ID{end+1} = info1.StudyInstanceUID;
            find_location = length(study_ID);
            study_description_name{find_location}.description{1} = info1.SeriesInstanceUID;            
            study_description{find_location}.description{1}.filename{1} = all_files_list{i};
        else
            
            % ID already exists in list
            if isfield(study_description{find_location}, 'description')
                description_location = find(strcmp(study_description_name{find_location}.description, info1.SeriesInstanceUID));
                if isempty(description_location)
                    study_description_name{find_location}.description{end+1} = info1.SeriesInstanceUID;
                    study_description{find_location}.description{end+1}.filename{1} = all_files_list{i};
                else
                    study_description{find_location}.description{description_location}.filename{end+1} = all_files_list{i};

                end
            else
                study_description_name{find_location}.description{1} = info1.SeriesInstanceUID;
                study_description{find_location}.description{1}.filename{1} = all_files_list{i};
            end
        end
    end
end
close(h)

dicomdict('factory');

table_content = {};
datatable = {};
for i = 1:length(study_ID)
    for j = 1:length(study_description_name{i}.description)
        fileinfo = dicominfo(study_description{i}.description{j}.filename{1});
        if ~isfield(fileinfo.PatientName, 'GivenName')
            fileinfo.PatientName.GivenName = '';
        end
        if ~isfield(fileinfo.PatientName, 'FamilyName')
            fileinfo.PatientName.FamilyName = '';
        end
        
        if ~isfield(fileinfo, 'SeriesTime')
            datatable(end+1,:) = {study_description{i}.description{j}.filename, []};
            fileinfo.SeriesTime = '';
        else
            datatable(end+1,:) = {study_description{i}.description{j}.filename, fileinfo.SeriesTime};
        end
        
        if ~isfield(fileinfo, 'StudyDescription')
            fileinfo.StudyDescription = '';
        end
        if ~isfield(fileinfo, 'SeriesDescription')
            fileinfo.SeriesDescription = '';
        end
        table_content(end+1,:) = {false, fileinfo.PatientID, fileinfo.PatientName.FamilyName, fileinfo.PatientName.GivenName, fileinfo.StudyDescription, fileinfo.SeriesDescription, fileinfo.StudyDate, fileinfo.SeriesTime, ...
            length(study_description{i}.description{j}.filename), false};
        
    end
end

if size(datatable,1) == 1
    % simple case. Return the list.
    filelist = study_description{1}.description{1}.filename;
else
    if (exist('fileinfo')~=1)
        warndlg('No DICOM files within the selected folder');
        varargout{1} = [];
        varargout{2} = [];
        return;
    end
    try
        [filelist fusion_filelist table_content] = DICOM_selection_GUI(datatable, table_content, fileinfo, study_ID, study_description);
    catch EM
        filelist = [];
    end
end

varargout{1} = filelist;
if exist('fusion_filelist')
    varargout{2} = fusion_filelist;
else
    varargout{2} = '';
end
varargout{3} = table_content;

return;
