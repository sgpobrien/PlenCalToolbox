function window_array = linear_estimate_window_parameters(correspondences_struct, sub_image_radius)
%LINEAR_ESTIMATE_WINDOW_PARAMETERS Estimates the plenoptic disc parameters corresponding to a point given the array of lenslet-pixel pairs corresponding to that point. 
%   The plenoptic disc parameters [R,w], where R is the disc radius, and w
%   is the disc centre, corresponding to a point should satisfy
%   [-1,0,(l_u-p_u)/r,l_u; 0,-1,(l_v-p_v)/r,l_v]*[R;w_u;w_v;1] = 0, where
%   (l_u,l_v), (p_u,p_v) are the image coordinates of a lenslet-pixel pair
%   corresponding the the point, and r is the sub-image radius. This 
%   function solves this system in the least-squares sense for all the 
%   lenslet-pixel pairs corresponding to each feature point. 
%   Inputs: correspondences_struct (see: generate_correspondences_struct)
%           sub_image_radius :: Double
%   Outputs: window_array :: Kx3xT Double where 
%                            K is the number of feature points 
%                            T is the number of frames used

[~,T] = size(correspondences_struct);
    for t=1:T
        correspondences = correspondences_struct{t};
        [~,~,K] = size(correspondences);
%         window_array = zeros(K,3,T);
        for k = 1:K
            lens = correspondences(:,1:2,k);
            pixels = correspondences(:,3:4,k);
            data_x = [repmat([-1,0],numel(lens)/2,1),(lens(:,1)-pixels(:,1))/sub_image_radius,lens(:,1)];
            data_y = [repmat([0,-1],numel(lens)/2,1),(lens(:,2)-pixels(:,2))/sub_image_radius,lens(:,2)];
            window_data = [data_x;data_y];
            [~,~,V] = svd(window_data);
            v = V(:,end);
            v = v/v(end);
            w = v(1:2)';
            R = v(3);
            window_array(k,:,t) = [R,w];
        end
    end
end