%% Matlab Setup
clc;
close all;
clear all;
folderpath = fileparts(mfilename('fullpath'));
cd(folderpath);
cd('../');
folderpath = pwd;
addpath(genpath(folderpath));

%% Initial Parameters
scale = 17.4636; % approximate true radius in pixels of lenslet subimage
resolution = [5364,7716]; % resolution of light-field
sub_image_radius = 15; % size in pixels of subimage excluding 2.4636 pixel border
calibration_set = 'R_C';
data_dir = ['data/Dataset_',calibration_set,'/'];
imagefiles = dir([data_dir, '*.jpg']);
nfiles = length(imagefiles);
grid_size = 15.5;
data_scale = [10,1,1;1,1,1;10^(12),1,1;1,1,1;repmat([10,10,1;1000,1000,1000],nfiles,1)];

%% Generate Lens Coordinates
lens_coordinates = generate_lens_coordinates; % image-coordinates of the lenslet sub-image centres
save([data_dir,'lens_coordinates-',calibration_set,'.mat'],'lens_coordinates');

%% Generate Connection Array
connection_array = generate_connectivity_array(lens_coordinates,scale,resolution); % pre-calculation of nearest lenslets to pixels in a rectangular array. Used for computation of sub-aperture images. 
save([data_dir,'connection_array-',calibration_set,'.mat'],'connection_array');

%% Generate Correspondences Struct
[correspondences_struct,boardSize,framesUsed] = generate_correspondences_struct(lens_coordinates,connection_array,data_dir,imagefiles,resolution,scale,sub_image_radius,0); % Lenslet-pixel pairs corresponding to each feature point in each light-field image. 
save([data_dir,'correspondences_struct-',calibration_set,'.mat'],'correspondences_struct');
save([data_dir,'boardSize-',calibration_set,'.mat'],'boardSize');
save([data_dir,'framesUsed-',calibration_set,'.mat'],'framesUsed');

%% Generate Window Array
window_array = linear_estimate_window_parameters(correspondences_struct, sub_image_radius); % an array of the plenoptic disc parameters corresponding to each feature point in each light-field image. 
save([data_dir,'window_array-',calibration_set,'.mat'],'window_array');
checkerboard = generate_checker_board(boardSize,grid_size); % physical coordinates of the checker-board.
window_data = format_window_data(boardSize,nfiles,window_array); % plenoptic disc parameters paired with physical coordinates of the points each disc corresponds to. 

%% Calibration Initialisation
calibration_init = linear_estimate_calibration_parameters(window_data,nfiles,grid_size,resolution/2,checkerboard,[],[],0); % initial solution to the calibration problem. 
save([data_dir,'calibration_init-',calibration_set,'.mat'],'calibration_init');
calibration_init = calibration_init.*data_scale; % Pre-scaling 

%% Calibration Optimisation
calibration_est = optimise_calibration_parameters(window_data,data_scale,grid_size,calibration_init); % calibration non-linear optimisation procedure. 
calibration_est = calibration_est./data_scale; % Divide out data pre-scaling.
save([data_dir,'calibration_est-',calibration_set,'.mat'],'calibration_est');

%% Calibration Tests
currentfilename = imagefiles(1).name; 
raw_light_field = im2double(imread(currentfilename));
mre = test_mean_reprojection_error(calibration_est,raw_light_field,nfiles,checkerboard,window_array,boardSize,sub_image_radius,lens_coordinates,0)
mbe = test_mean_backprojection_error(calibration_est,checkerboard,window_data,grid_size,1)
mse = test_mean_synthetic_reprojection_error(calibration_est,correspondences_struct,checkerboard,scale,boardSize,0)