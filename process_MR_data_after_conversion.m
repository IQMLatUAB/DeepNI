function [FAST_results, img_file] = process_MR_data_after_conversion(ori_img_file)
% clear all; close all;


display('----------------------------------------------');
display('----------------------------------------------');
display('----------------------------------------------');
display('----------------------------------------------');

target_dir = '/home/leon/my_fastsurfer_analysis';

FS_results = fullfile(target_dir,'aparc+aseg.mgz');

% ori_img_file = 'test1.mgz'; 
copyfile(ori_img_file, '/home/leon/Cloud_GUI/temptest.nii');

% move the file from Windows to Linux
% system('run cp /mnt/c/temp/temptest.mgz /home/yfang/data/temptest.mgz');
% activate freesrf environment
% system('bash');
% do fastsurfer segmentation
[status msg] = system('cd /home/leon/FastSurfer; ./run_fastsurfer.sh --t1 /home/leon/Cloud_GUI/temptest.nii --sid subject1 --sd /home/leon/my_fastsurfer_analysis --seg_only','-echo');
% system('run cp /home/leon/my_fastsurfer_analysis/subject1/mri/aparc.DKTatlas+aseg.deep.mgz /mnt/c/temp/');
% move the results back to windows
% system('run cp /home/leon/my_fastsurfer_analysis/subject1/mri/orig.mgz /mnt/c/temp/');

FAST_results = '/home/leon/my_fastsurfer_analysis/subject1/mri/aparc.DKTatlas+aseg.deep.mgz';

img_file = '/home/leon/Cloud_GUI/orig.mgz';

return;
%% load results and show them
% [vol2, M2, mr_parms2, volsz] = load_mgz(img_file);
% [vol4, M4, mr_parms2, volsz] = load_mgz(FAST_results);
% now_label = 50;
% mask2 = vol4==now_label;
% img1 = squeeze(vol2(:,110,:));
% mask2t = squeeze(mask2(:,110,:));
% imgtemp2 = fuse_img(img1, mask2t);
% figure
% imagesc(imgtemp2);  axis off; title('FASTsurfer');
