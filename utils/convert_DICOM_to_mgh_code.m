clear all; close all;

DICOM_dir = '/home/leon/Cloud_GUI/1/2016-06__Studies/testsub_1019';

file_info = list_all_files(DICOM_dir, {}, '');
% file_info = filelist;

%img_all = zeros(320, 260, length(file_info));
for idx = 1:length(file_info)
    if ~isdicom(file_info{idx})
        continue;
    end
    temp1 = double(dicomread(file_info{idx}));
    temp2 = dicominfo(file_info{idx});
    vec1(idx) = temp2.InstanceNumber;
end

[sorted_x sorted_idx] = sort(vec1,'descend');
sorted_x;
file_info = file_info(sorted_idx);

for idx = 1:length(file_info)
    if ~isdicom(file_info{idx})
        continue;
    end
    temp1 = double(dicomread(file_info{idx}));
    temp2 = dicominfo(file_info{idx});
    if ~isfield(temp2, 'RescaleSlope')
        temp2.RescaleSlope = 1;
    end
    if ~isfield(temp2, 'RescaleIntercept')
        temp2.RescaleIntercept = 0;
    end
    
    img_all(:,:,idx) = (double(temp1)*double(temp2.RescaleSlope)+double(temp2.RescaleIntercept));
    
end
%%
M = TransMatrix(temp2);
if ~isfield(temp2, 'InversionTime')
    temp2.InversionTime = 0;
end
tr = temp2.RepetitionTime;
flipangle = temp2.FlipAngle;
te = temp2.EchoTime;
ti = temp2.InversionTime;
mr_parms = [tr flipangle te ti]
tic
r = save_mgh(img_all, 'test1.mgz', M, mr_parms);
toc


