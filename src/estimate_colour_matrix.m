function colour_matrix = estimate_colour_matrix(img,black_points,blue_points,green_points,cyan_points,red_points,magenta_points,yellow_points,white_points)
    for k = 1:numel(black_points)
    black_values(k,:) = reshape(img(black_points(k).Position(2),black_points(k).Position(1),:),1,3);
    true_black_values(k,:) = [0,0,0];
    end 
    for k = 1:numel(blue_points)
    blue_values(k,:) = reshape(img(blue_points(k).Position(2),blue_points(k).Position(1),:),1,3);
    true_blue_values(k,:) = [0,0,1];
    end
    for k = 1:numel(green_points)
    green_values(k,:) = reshape(img(green_points(k).Position(2),green_points(k).Position(1),:),1,3);
    true_green_values(k,:) = [0,1,0];
    end
    for k = 1:numel(cyan_points)
    cyan_values(k,:) = reshape(img(cyan_points(k).Position(2),cyan_points(k).Position(1),:),1,3);
    true_cyan_values(k,:) = [0,1,1];
    end
    for k = 1:numel(red_points)
    red_values(k,:) = reshape(img(red_points(k).Position(2),red_points(k).Position(1),:),1,3);
    true_red_values(k,:) = [1,0,0];
    end
    for k = 1:numel(magenta_points)
    magenta_values(k,:) = reshape(img(magenta_points(k).Position(2),magenta_points(k).Position(1),:),1,3);
    true_magenta_values(k,:) = [1,0,1];
    end
    for k = 1:numel(yellow_points)
    yellow_values(k,:) = reshape(img(yellow_points(k).Position(2),yellow_points(k).Position(1),:),1,3);
    true_yellow_values(k,:) = [1,1,0];
    end
    for k = 1:numel(white_points)
    white_values(k,:) = reshape(img(white_points(k).Position(2),white_points(k).Position(1),:),1,3);
    true_white_values(k,:) = [1,1,1];
    end
    colour_before = [black_values;blue_values;green_values;cyan_values;red_values;magenta_values;yellow_values;white_values];
    colour_after = [true_black_values;true_blue_values;true_green_values;true_cyan_values;true_red_values;true_magenta_values;true_yellow_values;true_white_values];
    colour_matrix = colour_after'/colour_before';
end