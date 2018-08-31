function img_col_corr = correct_colour_affine(img,colour_matrix)
    [X,Y,~] = size(img);
    img_list = [reshape(img,X*Y,3),ones(X*Y,1)];
    img_list_col_corr = (colour_matrix*img_list')';
    img_col_corr = reshape(img_list_col_corr(:,1:3),X,Y,3);
end