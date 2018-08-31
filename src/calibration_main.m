clc;
close all;
clear all;
folderpath = fileparts(mfilename('fullpath'));
cd(folderpath);
cd('../');
folderpath = pwd;
addpath(genpath(folderpath));

%% Initial Parameters
scale = 17.4636;
resolution = [5364,7716];
field_of_view = 15;
calibration_set = '0.5m-3';
imagefiles = dir(['data/Calib-', calibration_set, '/*.jpg']);
nfiles = length(imagefiles);
grid_size = 7;

%% Generate Lense Coordinates
lenses_coordinates = generate_lense_coordinates;
save(['data/Calib-',calibration_set,'/lenses_coordinates-',calibration_set,'-struct.mat'],'lenses_coordinates');

%% Generate Connection Array
connection_array = generate_connectivity_array(lenses_coordinates,scale,resolution);
save(['data/Calib-',calibration_set,'/connection_array-',calibration_set,'-struct.mat'],'connection_array');

%% Generate Correspondences Struct
[correspondences_struct,boardSize] = generate_correspondences_struct(lenses_coordinates,connection_array,imagefiles,resolution,scale,field_of_view);
save(['data/Calib-',calibration_set,'/correspondences-',calibration_set,'-struct.mat'],'correspondences_struct');
save(['data/Calib-',calibration_set,'/boardSize-',calibration_set,'-struct.mat'],'boardSize');
    
%% Generate Window Array
window_array = linear_estimate_window_parameters(correspondences_struct, field_of_view);
save(['data/Calib-',calibration_set,'/window_array-',calibration_set,'-struct.mat'],'window_array');

I = boardSize(1)-1;
J = boardSize(2)-1;
for k = 1:(I*J)
j = (floor((k-1)/(I)))-(J+1)/2+1;
i = (mod(k-1,(I)))-(I)/2+1;
point_locations(k,:) = [i,j];
end
checkerboard = grid_size*[point_locations,zeros(I*J,1)];
for t = 1:nfiles
window_data(:,:,t) = [window_array(:,:,t),point_locations];
end

%% Calibration Initialisation
calibration_init = linear_estimate_calibration_parameters(window_data,nfiles,grid_size,checkerboard,[],[]);
data_scale = [1000000000,10000000,1;1,1,1;repmat([1,1,1;1000,1000,1000],nfiles,1)];
save(['data/Calib-',calibration_set,'/calibration_init-',calibration_set,'-struct.mat'],'calibration_init');
calibration_init = calibration_init.*data_scale;

%% Calibration Optimisation
calibration_est = optimise_calibration_parameters(window_data,data_scale,grid_size,calibration_init);
save(['data/Calib-',calibration_set,'/calibration_est-',calibration_set,'-struct.mat'],'calibration_est');

calibration_est = calibration_est./data_scale;

%% Calibration Tests

currentfilename = imagefiles(1).name;
raw_light_field = im2double(imread(currentfilename));
mre = test_mean_reprojection_error(calibration_est,raw_light_field,nfiles,checkerboard,window_array,boardSize,field_of_view,lenses_coordinates)
mbe = test_mean_backprojection_error(calibration_est,checkerboard,window_data,grid_size)
