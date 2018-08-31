function lens_coordinates = generate_lens_coordinates_lytro 
%% Initialisation
    load('data/PlenCalCVPR2013DatasetB/01/gridcoords.mat');

    lens_coordinates = reshape(GridCoords,numel(GridCoords)/2,2);
    lens_coordinates_indices = lens_coordinates(:,1) > 5 & lens_coordinates(:,1) < 3275 & lens_coordinates(:,2) > 5 & lens_coordinates(:,2) < 3275;
    lens_coordinates = lens_coordinates(lens_coordinates_indices,:);
end


