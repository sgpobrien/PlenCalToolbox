function img_col_corr = correct_colour(current_img,colour_matrix)
    [X,Y,~] = size(current_img);
    img_list = reshape(current_img,X*Y,3);
    img_list_col_corr = (colour_matrix*img_list')';
    img_col_corr = reshape(img_list_col_corr(:,1:3),X,Y,3);
end