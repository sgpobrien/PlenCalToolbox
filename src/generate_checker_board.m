function checkerboard = generate_checker_board( boardSize,grid_size )
%GENERATE_CHECKER_BOARD Generates the 3D coordinates of the checker-board corners given known dimensions and size. 
%   This function takes as input the boardSize, which is a 1 by 2 vector
%   where boardSize(1) is the number of rows, and boardSize(2) is the
%   number of columns, and grid_size, which is the distance between
%   adjacent corners measured in millimetres, and returns a K by 3 array
%   checkerboard, where K = (boardSize(1)-1)*(boardSize(2)-1), and 
%   checkerboard(k,:) are the 3D coordinates of the kth feature point. 
%   The origin of the coordinate frame is the centre of the checkerboard, 
%   and the camera position is assumed to have positive z-component in this
%   reference frame.
%   Inputs : boardSize :: 1x2 Int
%            grid_size :: Double
%   Outputs: checkerboard :: Kx3 Double (where K is as above)

I = boardSize(1)-1;
J = boardSize(2)-1;
for k = 1:(I*J)
j = (floor((k-1)/(I)))-(J+1)/2+1;
i = (mod(k-1,(I)))-(I)/2+1;
point_locations(k,:) = [i,j];
end
checkerboard = grid_size*[point_locations,zeros(I*J,1)];
end

