clc;
close all;
clear all;
folderpath = fileparts(mfilename('fullpath'));
cd(folderpath);
cd('../');
folderpath = pwd;
addpath(genpath(folderpath));

%% Initial Parameters
scale = 5;
resolution = [3280,3280];
field_of_view = 5;
calibration_set = 'PlenCalCVPR2013DatasetD';
data_dir = ['data/',calibration_set,'/01/'];
imagefiles = dir([data_dir, '*.jpg']);
nfiles = length(imagefiles);
grid_size = 7.22;

%% Generate Lense Coordinates
lenses_coordinates = generate_lense_coordinates_lytro;
save(['data/',calibration_set,'/lenses_coordinates-',calibration_set,'.mat'],'lenses_coordinates');

%% Generate Connection Array
connection_array = generate_connectivity_array(lenses_coordinates,scale,resolution);
save(['data/',calibration_set,'/connection_array-',calibration_set,'.mat'],'connection_array');

%% Generate Correspondences Struct
[correspondences_struct,boardSize] = generate_correspondences_struct(lenses_coordinates,connection_array,data_dir,imagefiles,resolution,scale,field_of_view,1);
save(['data/',calibration_set,'/correspondences-',calibration_set,'.mat'],'correspondences_struct');
save(['data/',calibration_set,'/boardSize-',calibration_set,'.mat'],'boardSize');

nfiles = length(correspondences_struct);

%% Generate Window Array
window_array = linear_estimate_window_parameters(correspondences_struct, field_of_view);
save(['data/',calibration_set,'/window_array-',calibration_set,'.mat'],'window_array');

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
calibration_init = linear_estimate_calibration_parameters(window_data,nfiles,grid_size,[3280,3280]/2,checkerboard,[],[],0);
data_scale = [100,1,1;1,1,1;10^12,1,1;1,1,1;repmat([10,10,10;1000,1000,1000],nfiles,1)];
save(['data/',calibration_set,'/calibration_init-',calibration_set,'.mat'],'calibration_init');
calibration_init = calibration_init.*data_scale;

%% Calibration Optimisation
calibration_est = optimise_calibration_parameters(window_data,data_scale,grid_size,calibration_init);
save(['data/',calibration_set,'/calibration_est-',calibration_set,'.mat'],'calibration_est');

calibration_est = calibration_est./data_scale;

%% Calibration Tests

currentfilename = imagefiles(1).name;
raw_light_field = im2double(imread([data_dir,currentfilename]));
mre = test_mean_reprojection_error(calibration_est,raw_light_field,nfiles,checkerboard,window_array,boardSize,field_of_view,lenses_coordinates,0)
mbe = test_mean_backprojection_error(calibration_est,checkerboard,window_data,grid_size,0)
mse = test_mean_synthetic_reprojection_error(calibration_est,correspondences_struct,checkerboard,scale,boardSize,0)
