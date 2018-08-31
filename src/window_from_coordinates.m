function window = window_from_coordinates(lenses,window_centre,window_radius)
    window = [];
    lenses_list = reshape(lenses,(numel(lenses)/2),2);
    for i=1:(numel(lenses)/2)
        l_x = lenses_list(i,1);
        l_y = lenses_list(i,2);
        distance_sq = (l_x - window_centre(1))^2 + (l_y - window_centre(2))^2;
        if distance_sq <= (window_radius)^2
            window = [window; [l_x, l_y]];
        end
    end
end