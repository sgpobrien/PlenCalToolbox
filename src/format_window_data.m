function window_data = format_window_data(boardSize,nfiles,window_array)
%FORMAT_WINDOW_DATA Pairs each lenslet-pixel pair with a physical point coordinate. 
%   This function simply appends a window array (see:
%   linear_estimate_window_parameters) with the physical point coordinates
%   corresponding to the point each window corresponds to. This makes the
%   calibration step easier. Eg. window_data(k,:,t) = [R,w_u,w_v,P_x,P_y]
%   where R is the plenoptic disc radius, [w_u,w_v] is the plenoptic disc 
%   centre, and [P_x,P_y,0] are the 3D coordinates of the grid point
%   corresponding to the kth grid point in frame t. 
%   Inputs: boardSize :: 1x2 Int
%           nfiles    :: Int
%           window_array (see: linear_estimate_window_parameters)
%   Outputs: window_data :: Kx5xT Double where 
%                            K is the number of feature points 
%                            T is the number of frames used

I = boardSize(1)-1;
J = boardSize(2)-1;
for k = 1:(I*J)
j = (floor((k-1)/(I)))-(J+1)/2+1;
i = (mod(k-1,(I)))-(I)/2+1;
point_locations(k,:) = [i,j];
end
for t = 1:nfiles
window_data(:,:,t) = [window_array(:,:,t),point_locations];
end
end

