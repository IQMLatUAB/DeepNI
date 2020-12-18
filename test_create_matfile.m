softlist = {'Fastserver','DARTS'; 'cd /root/FastSurfer; ./run_fastsurfer.sh --t1 /root/Cloud_GUI/temptest.nii --sid Output --sd /root/Image_Analysis_Result ', ...
    'cd /root/DARTS; python3 DARTS/perform_pred.py --input_image_path /root/Cloud_GUI/temptest.nii --segmentation_dir_path /root/Image_Analysis_Result/Output/mri --file_name input_T1 --model_wts_path /root/DARTS/DARTS/saved_model_wts/dense_unet_back2front_non_finetuned.pth' ...
    };
save softlist softlist -v7.3 -nocompression;
load ('bathmatry.mat');
websave('bathmatry.mat','https://drive.google.com/uc?export=download&id=1IvraN4fp94TfOh6yEYU7mhnisl4pVl_T');
fileID = fopen('bathmatry.mat')
s = textscan(fileID,'%f');
fclose(fileID);
