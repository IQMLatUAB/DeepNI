## DeepNI

DeepNI provides a remote computing server with GPUs for users to conduct medical image processing without the cumbersome of both software and hardware requirements.

## Installation

Dowload DeepNI repository and unzip it.

or try
    
    $ git clone https://github.com/IQMLatUAB/DeepNI.git
Open the DeepNI folder in matlab.

## Instructions


1. Run DeepNI_GUI.m under the DeepNI folder in matlab.
2. Click "Load images" button to import medical images you want to process.
3. Choose any dcm file which belong to a specific Dicom series in the selection window. DeepNI will convert this Dicom file to a Nifti format.
4. Select an Nifti image you imported and a processing model in the model list. then click the "Submit job" button in order to transfer this job to the computing server to process.
5. Click "Check job" under the action menu or "Update status for all jobs" button to refresh the job status and messages from the remote server, which shown in matlab command window. 
6. Click "Export results" under the action menu to save processing results in your local computer when the job status is "Completed". Make sure you export results before you close DeepNI because non-save results will be automatically eliminated. The name of export results is composed of the processing model name and the time that you export.
