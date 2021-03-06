function [sub_aperture_images,offset_array] = create_sub_aperture_images_fast(lenses_coordinates,connection_array,data_dir,currentfilename,resolution,scale,field_of_view)
    tic
    framesUsed = [];
    sub_resolution = round(resolution/scale);
    valid_pixels = sqrt((repmat(((1:(2*field_of_view+1))-(field_of_view+1))',1,(2*field_of_view+1)).^2)+(repmat(((1:(2*field_of_view+1))-(field_of_view+1))',1,(2*field_of_view+1)).^2)') < field_of_view;
    offset_array = [];
    light_field = im2double(imread([data_dir,currentfilename]));
    light_field = imgaussfilt(light_field,4);
%     sub_aperture_images = zeros(sub_resolution(1),sub_resolution(2),3,sum(sum(valid_pixels)));
    s=0;
    lf_r = light_field(:,:,1);
    lf_g = light_field(:,:,2);
    lf_b = light_field(:,:,3);
    neighbour_array = reshape(connection_array(:,:,1,:),prod(sub_resolution),3);
    coefficient_array = reshape(connection_array(:,:,2,:),prod(sub_resolution),3);
    for m = (-field_of_view+1):2:(field_of_view-1)
        for n = (-field_of_view+1):2:(field_of_view-1)
            if valid_pixels(m+(field_of_view+1),n+(field_of_view+1))
                s = s+1;
                offset = [m,n];
                offset_array(s,:) = offset;
                lenses_indices = round(lenses_coordinates(:,2)+offset(2)) + (round(lenses_coordinates(:,1)+offset(1))-1)*resolution(1);
                neighbour_indices = [lenses_indices(neighbour_array(:,1)),lenses_indices(neighbour_array(:,2)),lenses_indices(neighbour_array(:,3))];
                subap_r = sum(coefficient_array.*lf_r(neighbour_indices),2);              
                subap_g = sum(coefficient_array.*lf_g(neighbour_indices),2);
                subap_b = sum(coefficient_array.*lf_b(neighbour_indices),2);
                sub_aperture_images(:,:,:,s) = reshape([subap_r,subap_g,subap_b],sub_resolution(1),sub_resolution(2),3);
                100*s/(sum(sum(valid_pixels)))
            end
        end
    end
    toc
end