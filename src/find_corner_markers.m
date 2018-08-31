function error = find_corner_markers(img,bw_thresh,patch_size,feature_thresh)
img_0 = im2bw(img,bw_thresh); 
img_1 = flip(img_0',1);
img_2 = flip(img_1',1);
img_3 = flip(img_2',1);

% patch_size = 8;

h = fspecial('gaussian', 2*patch_size+1, patch_size);

error = fast_corner_error(img_0,img_1,img_2,img_3,patch_size,h);

error = ((error-min(min(error)))/(max(max(error-min(min(error))))));

[M,N] = size(img_0);
boundary = ones(M,N);
boundary((patch_size+1):(M-patch_size),(patch_size+1):(N-patch_size)) = 0;
error(boundary(:)==1) = 1;

error = 1-im2bw(error,feature_thresh);
end