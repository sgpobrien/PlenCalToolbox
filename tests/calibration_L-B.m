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
scale = 5; % approximate true radius in pixels of lenslet subimage
resolution = [3280,3280]; % resolution of light-field
field_of_view = 5; % size in pixels of subimage excluding 2.4636 pixel border
calibration_set = 'PlenCalCVPR2013DatasetB'; % name of calibration dataset
data_dir = ['data/',calibration_set,'/01/']; % location of calibration dataset relative to path
imagefiles = dir([data_dir, '*.jpg']); % struct containing raw light-field image details
nfiles = length(imagefiles); % number of images used in calibration
grid_size = 3.61; % size in millimeters of calibration grid squares
data_scale = [100,1,1;1,1,1;10^12,10^20,1;1,1,1;repmat([100,100,10;1000,1000,1000],nfiles,1)]; % optimisation prescaling parameters

%% Generate Lens Coordinates
lens_coordinates = generate_lense_coordinates_lytro; % image-coordinates of the lenslet sub-image centres
save(['data/',calibration_set,'/lens_coordinates-',calibration_set,'.mat'],'lens_coordinates');

%% Generate Connection Array
connection_array = generate_connectivity_array(lens_coordinates,scale,resolution); % pre-calculation of nearest lenslets to pixels in a rectangular array. Used for computation of sub-aperture images. 
save([data_dir,'/connection_array-',calibration_set,'.mat'],'connection_array');

%% Generate Correspondences Struct
[correspondences_struct,boardSize,framesUsed] = generate_correspondences_struct(lens_coordinates,connection_array,data_dir,imagefiles,resolution,scale,sub_image_radius,0); % Lenslet-pixel pairs corresponding to each feature point in each light-field image. 
save([data_dir,'/correspondences-',calibration_set,'.mat'],'correspondences_struct');
save([data_dir,'/boardSize-',calibration_set,'.mat'],'boardSize');
save([data_dir,'/framesUsed-',calibration_set,'.mat'],'framesUsed');

%% Generate Window Array
window_array = linear_estimate_window_parameters(correspondences_struct, sub_image_radius); % an array of the plenoptic disc parameters corresponding to each feature point in each light-field image. 
save([data_dir,'/window_array-',calibration_set,'.mat'],'window_array');
checkerboard = generate_checker_board(boardSize,grid_size); % physical coordinates of the checker-board.
window_data = format_window_data(boardSize,nfiles,window_array); % plenoptic disc parameters paired with physical coordinates of the points each disc corresponds to. 

%% Calibration Initialisation
calibration_init = linear_estimate_calibration_parameters(window_data,nfiles,grid_size,resolution/2,checkerboard,[],[],0); % initial solution to the calibration problem. 
save([data_dir,'/calibration_init-',calibration_set,'.mat'],'calibration_init');
calibration_init = calibration_init.*data_scale; % Pre-scaling 

%% Calibration Optimisation
calibration_est = optimise_calibration_parameters(window_data,data_scale,grid_size,calibration_init); % calibration non-linear optimisation procedure. 
calibration_est = calibration_est./data_scale; % Divide out data pre-scaling.
save([data_dir,'/calibration_est-',calibration_set,'.mat'],'calibration_est');

%% Calibration Tests
currentfilename = imagefiles(1).name; 
raw_light_field = im2double(imread(currentfilename));
mre = test_mean_reprojection_error(calibration_est,raw_light_field,nfiles,checkerboard,window_array,boardSize,sub_image_radius,lens_coordinates,0)
mbe = test_mean_backprojection_error(calibration_est,checkerboard,window_data,grid_size,1)
mse = test_mean_synthetic_reprojection_error(calibration_est,correspondences_struct,checkerboard,scale,boardSize,0)
