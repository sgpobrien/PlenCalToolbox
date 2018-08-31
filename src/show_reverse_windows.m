function lenses_pixels_indices = show_reverse_windows(raw_light_field,window_map,lenses,field_of_view,boardSize,extra)
    lenses_pixels_indices = [];
    [num_points,~] = size(window_map);
    for k = 1:num_points
        window_radius = window_map(k,1);
        centre_estimate = window_map(k,2:3);
        window = window_from_coordinates(lenses,centre_estimate,window_radius);
%                 scatterarray(window,'ro');
        for l = 1:(numel(window)/2)
            current_lense = window(l,:);
            corresponding_pixel = current_lense + (field_of_view/window_radius)*(current_lense-centre_estimate);
%                     scatterarray(corresponding_pixel,'g.');
%                     boardSize = [7,10];
            i = (floor((k-1)/(boardSize(1)-1)));
            j = (mod(k-1,(boardSize(1)-1)));
            lenses_pixels_indices = [lenses_pixels_indices; current_lense,corresponding_pixel,i,j];
        end
    end
    switch nargin 
        case 6
            if extra ~= 0
                figure;
                dims = size(lenses);
                if dims(2) == 2
                    lenses_list = lenses;
                else
                    lenses_list = reshape(lenses,dims(1)*dims(2),2);
                end
                scatterarray(lenses_list,'b');
                if numel(raw_light_field) > 0
                    imshow(raw_light_field)
                end
                hold on;
                scatterarray(lenses_pixels_indices(:,1:2),'ro');
                scatterarray(lenses_pixels_indices(:,3:4),'g.');
            end
        otherwise
            if raw_light_field ~= []
                imshow(raw_light_field)
            end
            hold on;
            scatterarray(lenses_pixels_indices(:,1:2),'ro');
            scatterarray(lenses_pixels_indices(:,3:4),'g.');
    end
    lenses_pixels_indices = lenses_pixels_indices';
end
