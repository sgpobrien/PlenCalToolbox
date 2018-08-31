function [correspondences_struct,goodBoardSize,framesUsed] = generate_correspondences_struct(lens_coordinates,connection_array,data_dir,imagefiles,resolution,scale,sub_image_radius,isSymmetric)
%GENERATE_CORRESPONDENCES_STRUCT Generates a struct containing sets of calibration point correspondences for each image. 
%   This function generates a cell-array that contains for each light-field
%   frame, an array that lists a set of lenslet-pixel pairs corresponding
%   to each of the calibration feature points. The cell-array is a 1 by T
%   array where T is the number of light-fields for which the calibration
%   grid is successfully detected. Each entry of the cell-array is a N(t)
%   by 4 by K array where N(t) is the number of sub-aperture images used in
%   frame t for which the calibration grid is successfully detected, and K
%   is the number of calibration feature points. Thus,
%   correspondences_struct{t}(n,:,k) gives the lenslet-pixel pair for which
%   feature point k is visible in frame t in the nth sub-aperture image for
%   which the feature is successfully detected. 
%   goodBoardSize is of type [1,2] Int and lists the number of rows and
%   columns automatically detected by this function. 
%   framesUsed is of type [Int] and lists the numbers of frames for which
%   the calibration grid was successfully detected. 
%   Inputs: lens_coordinates (see: generate_lens_coordinates)
%           connection_array (see: generate_connectivity_array) 
%           data_dir :: String (directory where calibration images are located)
%           imagefiles :: Tx1 struct (calibration image details)
%           resolution :: 1x2 Int (light-field resolution)
%           sub_image_radius :: Double (radius of lenslet subimages used)
%           isSymmetric :: Bool (is True if calibration grid is symmetric)
%   Outputs: correspondences_struct (see above)
%            goodBoardSize (see above) 
%            framesUsed (see above)
    tic
    framesUsed = [];
    nfiles = length(imagefiles);
    sub_resolution = round(resolution/scale);
    valid_pixels = sqrt((repmat(((1:(2*sub_image_radius+1))-(sub_image_radius+1))',1,(2*sub_image_radius+1)).^2)+(repmat(((1:(2*sub_image_radius+1))-(sub_image_radius+1))',1,(2*sub_image_radius+1)).^2)') < sub_image_radius;
    offset_array = [];
    for t=1:nfiles
        currentfilename = imagefiles(t).name;
        light_field = im2double(imread([data_dir,currentfilename]));
        centre_images = zeros(sub_resolution(1),sub_resolution(2),3,sum(sum(valid_pixels)));
%         centre_images_used = zeros(1,sum(sum(valid_pixels)));
        s=0;
        lf_r = light_field(:,:,1);
        lf_g = light_field(:,:,2);
        lf_b = light_field(:,:,3);
        neighbour_array = reshape(connection_array(:,:,1,:),prod(sub_resolution),3);
        coefficient_array = reshape(connection_array(:,:,2,:),prod(sub_resolution),3);
        for m = -sub_image_radius:sub_image_radius
            for n = -sub_image_radius:sub_image_radius
                if valid_pixels(m+(sub_image_radius+1),n+(sub_image_radius+1))
                    s = s+1;
                    offset = [m,n];
                    offset_array(s,:) = offset;
%                     neighbour_array = reshape(connection_array(:,:,1,:),prod(sub_resolution),3);
%                     coefficient_array = reshape(connection_array(:,:,2,:),prod(sub_resolution),3);
                    lenses_indices = round(lens_coordinates(:,2)+offset(2)) + (round(lens_coordinates(:,1)+offset(1))-1)*resolution(1);
                    neighbour_indices = [lenses_indices(neighbour_array(:,1)),lenses_indices(neighbour_array(:,2)),lenses_indices(neighbour_array(:,3))];
%                     lf_r = light_field(:,:,1);
                    im_r = sum(coefficient_array.*lf_r(neighbour_indices),2);
%                     lf_g = light_field(:,:,2);
                    im_g = sum(coefficient_array.*lf_g(neighbour_indices),2);
%                     lf_b = light_field(:,:,3);
                    im_b = sum(coefficient_array.*lf_b(neighbour_indices),2);
                    centre_images(:,:,:,s) = reshape([im_r,im_g,im_b],sub_resolution(1),sub_resolution(2),3);
%                     centre_images_used(s) = 1;
            %         figure; 
            %         imshow(centre_image);
                    100*((t-1)*sum(sum(valid_pixels))+s)/(nfiles*sum(sum(valid_pixels)))
                end
            end
        end
        toc
        [imagePoints,boardSize,imagesUsed] = detectCheckerboardPoints(centre_images);
%         if isSymmetric
%             [K,~,R] = size(imagePoints);
%             dists = zeros(K,R);
%             for r = 1:R
%                 for k = 1:K
%                     dists(k,r) = norm(imagePoints(k,:,1) - imagePoints(k,:,r));
%                 end
%             end
%             goodBoards = sum(dists,1)<mean(sum(dists,1));
%             meanBoard = mean(imagePoints(:,:,goodBoards),3);
%             for r = 1:R
%                 if ~goodBoards(r)
%                     new_indices = zeros(1,K);
%                     for k = 1:K
%                         [~,min_index] = min(sum((bsxfun(@minus,meanBoard(k,:),imagePoints(:,:,r))).^2,2));
%                         new_indices(k) = min_index;
%                     end
%                     imagePoints(:,:,r) = imagePoints(new_indices,:,r);
%                 end
%             end
%         end
        offset_array = offset_array(imagesUsed,:);
        if isSymmetric
            [K,~,R] = size(imagePoints);
            for r = 1:R
                for repeat = 1:4 % shuffling hack
                    [~,origin] = min(sum(imagePoints(:,:,r).^2,2));
                    if origin ~= 1
                        board_array = reshape(imagePoints(:,:,r),(boardSize(1)-1),(boardSize(2)-1),2);
                        board_array = cat(3,flip(board_array(:,:,1),1)',flip(board_array(:,:,2),1)');
                        imagePoints(:,:,r) = reshape(board_array,(boardSize(1)-1)*(boardSize(2)-1),2);
                    end
                end
            end
        end
        if any(boardSize) 
            goodBoardSize = boardSize;
            framesUsed = [framesUsed,t];
            s = 0;
            r = 0;
            correspondences = zeros(sum(imagesUsed),4,(boardSize(1)-1)*(boardSize(2)-1));
            for m = -sub_image_radius:sub_image_radius
                for n = -sub_image_radius:sub_image_radius
                    if valid_pixels(m+(sub_image_radius+1),n+(sub_image_radius+1))
                        s = s+1;
                        if imagesUsed(s); 
                            r = r+1;
                            correspondences(r,:,:) = [imagePoints(:,:,r),bsxfun(@plus,imagePoints(:,:,r),[m,n]/scale)]';
                        end
                    end
                end
            end
%             correspondences_struct{t} = correspondences;
            correspondences_struct{t} = scale*correspondences;
            offset_struct{t} = offset_array;
        end
    end
%     for t = 1:nfiles
%         correspondences_struct{t} = scale*correspondences_struct{t};
%     end
end