function crop(images_folder)
% an interactive tool for cropping multiple images in a folder
% use by:
%      crop_multiple_images
% or 
%      crop_multiple_images(folder)
% where "folder" is the name of a folder with images
% 
% the tool allows you to overwrite the old files OR save them in a new
% folder.
%% get a valid folder name
if ~exist('images_folder','var')  
       images_folder=get_images_folder;
       if images_folder==0,  return, end
end
if  ~exist(images_folder,'dir')
    error(['The images folder name ' images_folder ' is not a valid folder'])
end
%% make sure it contains images and choose the right image file type
[image_files,N]=set_image_type_and_get_image_info(images_folder);
if N==0, return, end
%% load the first file 
image_files_1=image_files(1); % the first file
image_file_1_full_name=fullfile(images_folder,image_files_1.name);
% then load this file using imread
I=imread(image_file_1_full_name);
imshow(I),set(gcf,'Name',image_files_1.name)
drawnow
%% then let the user crop this file interactively 
msg= {'Using the mouse, draw a rectangle over the portion ', ...
              'of the image that you want to crop.',...
              'Finish by double-clicking in the crop rectangle. ' };
uiwait(helpdlg(msg,'Instructions for interactive crop') )
[~,rect]=imcrop(I); % and keep the rctangle position
close(gcf)
%% Next, ask user if he's ready for batch cropping
str_title='Approve multi-file crop';
str_q=sprintf('Perform crop for all %d files?',numel(image_files));
str_new='Crop and save in new folder';
str_overwrite='Crop and overwrite old files';
str_cancel='Cancel';  str_default=str_cancel;
choice=questdlg(str_q,str_title,str_new,str_overwrite,str_cancel,str_default);
%% then, get the name of the folder to save to
switch choice
    case str_new
    parentpath = cd(cd([images_folder filesep '..']));
    folder_name_to_save2=uigetdir(parentpath,'Define a new folder for saving the files');
    case str_overwrite
    folder_name_to_save2=images_folder;
    case str_cancel
     disp('Process cancelled. No files cropped.')
     return
end
%% Next, for every image file, perform crop, and save the cropped image.
h_waitbar=waitbar(0, 'processing image files...');
for i=1:N
    % read a single file
    image_file_1_full_name=fullfile(images_folder,image_files(i).name);
    I=imread(image_file_1_full_name);
    % crop it
    I2 = imcrop(I,rect);
    % and write it to file
    image_file_1_full_name_to_save2=fullfile(folder_name_to_save2,image_files(i).name);
    imwrite(I2,image_file_1_full_name_to_save2)
    msg=sprintf('%d out of %d files were processed', i, N);
    waitbar(i/N,h_waitbar,msg)
    if i==N, pause(0.5), end 
end
close(h_waitbar)
disp('Finished cropping and saving the files.')
end
function images_folder=get_images_folder
start_path='' ;   % the user may change this to have a specific start folder to choose within
images_folder=uigetdir(start_path,'Choose the folder with images');
end
function [image_files,N]=set_image_type_and_get_image_info(images_folder)
image_files=NaN; N=0;
while 1
    % check if the folder contains images
    image_types={'bmp','gif','hdf','jpg','jpeg','jp2','jpx','pbm',...
                          'pcx','pgm','png','pnm','ppm','ras','tif','tiff','xwd'};
    NImT=numel(image_types);
    %initialize
    files=cell(NImT,1);
    numfiles=zeros(NImT,1);
    
    for i=1:NImT
        folder_str=fullfile(images_folder, ['*.', image_types{i}]);
        files{i}=dir(folder_str);
        numfiles(i)=numel(files{i});
    end
    if sum(numfiles)==0
        uiwait(errordlg({'No image files were found in',...
                                images_folder,...
                                'Make sure the folder you choose is correct.'}))
        return
    end
    [num_f_sorted,sort_order]=sort(numfiles, 'descend');
    if num_f_sorted(2)<=1
        % only one file type found (one instance of different file type will not count here)
        N=num_f_sorted(1);
        file_type=image_types{sort_order(1)};
        uiwait(msgbox(['There are ' num2str(N)  ' ' file_type ' files in the folder.']))
        image_files=files{sort_order(1)};
        return
    else
        % there's more than one file type found
        idx=find(num_f_sorted>0);
        sort_order=sort_order(idx);
        num_f_sorted=num_f_sorted(idx);
        % ask the user which to choose
        prompt=cell(numel(idx)+2,1);
        prompt{1}='The folder contains:';
        for i=1:numel(idx)
            image_type_1=image_types{sort_order(i)};
             prompt{i+1}=sprintf('%d file(s) of type %s', num_f_sorted(i), image_type_1);
        end
        prompt{i+2}='Which type to crop?';
             
        [selection,ok]=listdlg('PromptString',prompt,...
                'SelectionMode','single',...
                'ListString',image_types(sort_order));
        if ~ok
            error('no choice was made')
        end
        % then  keep only the names of image files which fit the user's choice
        file_type_idx=sort_order(selection);
        image_files=files{file_type_idx};
        N=numel(image_files);
        return
    end
end
end
