function [window_array_plane,homography,radius_aberation,centre_aberation] = window_parameters_plane_fit(window_data)
    [K,~] = size(window_data);

    for k=1:K
    data_mat(3*(k-1)+1,:) = [[window_data(k,4:5),1],0,0,0,0,0,0,-[window_data(k,4:5),1]*window_data(k,1)];
    data_mat(3*(k-1)+2,:) = [0,0,0,[window_data(k,4:5),1],0,0,0,-[window_data(k,4:5),1]*window_data(k,2)];
    data_mat(3*(k-1)+3,:) = [0,0,0,0,0,0,[window_data(k,4:5),1],-[window_data(k,4:5),1]*window_data(k,3)];
    end
    
    [~,~,V] = svd(data_mat);
    v = V(:,end);
    v = v/v(12);
    H = reshape(v,3,4)';    
    
    figure;
    hold on;
    pts = (H*[window_data(:,4:5),ones(K,1)]')';
    div = [pts(:,4),pts(:,4),pts(:,4)];
    pts = pts(:,1:3)./div;
    scatterarray3(pts,'b');
    scatterarray3(window_data(:,1:3),'r');
    
    window_array_plane = pts;
    homography = H;
    radius_aberation = pts(:,1)-window_data(:,1);
    centre_aberation = pts(:,2:3)-window_data(:,2:3);
    
    figure;
    windowsurf([radius_aberation,window_data(:,2:5)]);
    
    figure;
    windowsurf([centre_aberation(:,1),window_data(:,2:5)]);
    
    figure;
    windowsurf([centre_aberation(:,2),window_data(:,2:5)]);
end