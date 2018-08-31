function colour_grid = generate_colour_test_grid
grid_r = [0,1,0;0,1,1;1,0,1];
grid_g = [0,0,1;1,1,0;1,0,1];
grid_b = [0,0,0;1,1,1;0,1,1];

colour_grid = cat(3,grid_r,grid_g,grid_b);
end