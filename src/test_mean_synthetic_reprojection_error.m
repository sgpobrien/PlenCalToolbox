function mse = test_mean_synthetic_reprojection_error(calibration_est,correspondences_struct,checkerboard,scale,boardSize,showPlot)
    centre_pixel = calibration_est(2,1:2); 
    cx = centre_pixel(2);
    cy = centre_pixel(1);
    K1 = calibration_est(1,1);
    K2 = calibration_est(1,2);
    A = -1/K2;
    B = -K1/K2;
    fx = calibration_est(1,3);
    fy = calibration_est(2,3);
    c1 = calibration_est(3,1);
    c2 = calibration_est(3,2);
    c3 = calibration_est(3,3);
    c4 = calibration_est(4,1);
    c5 = calibration_est(4,2);
    c6 = calibration_est(4,3);
    synthetic_reprojection_errors = [];
    for t = 1:length(correspondences_struct)
        correspondences = correspondences_struct{t};
        pos = calibration_est(2*t+3,:);
        ang = calibration_est(2*t+4,:);
        rot = expm(skew3(ang));
        pcam.pose.position = pos;
        pcam.pose.rotation = rot;
        for k = 1:(numel(correspondences)/(4*(boardSize(1)-1)*(boardSize(2)-1)))
            correspondences_k = reshape(correspondences(k,:,:),4,(boardSize(1)-1)*(boardSize(2)-1))';
            synthetic_pixel_data = correspondences_k(:,1:2)/scale;
            offset = mean(correspondences_k(:,3:4) - correspondences_k(:,1:2));
            counter = 0;
            synthetic_pixel_reprojection = [];
            for i = 1:(boardSize(1)-1)
                for j = 1:(boardSize(2)-1)
                    counter = counter + 1; 
                    point = checkerboard((i-1)*(boardSize(2)-1)+j,:);
                    P = (rot'*(point-pos)')'; % body-fixed coordinates of point
                    Px = P(1);  
                    Py = P(2); 
                    Pz = P(3); % depth of P
                    wx = fx*Px/Pz;
                    wy = fy*Py/Pz;
                    r = wx^2+wy^2;
                    R = (1/(A*Pz)) - B/A;
                    wx = wx*(1+c1*r+c2*r^2)+cx;
                    wy = wy*(1+c1*r+c2*r^2)+cy;
%                     synthetic_pixel_reprojection((i-1)*(boardSize(2)-1)+j,:) = ([wx,wy]+(R/scale)*offset)/scale;
                    synthetic_pixel_reprojection(counter,:) = ([wx,wy]+(R/scale)*offset)/scale;
                end
            end
            synthetic_reprojection_errors = [synthetic_reprojection_errors;sqrt(sum((synthetic_pixel_data-synthetic_pixel_reprojection).^2,2))];
%             synthetic_reprojection_errors(:,k,t) = sqrt(sum((synthetic_pixel_data-synthetic_pixel_reprojection).^2,2));
        end
    end
%     synthetic_reprojection_errors(:,k,t) = ;
    mse = mean(synthetic_reprojection_errors);
%     mse = mean(sqrt(sum((synthetic_pixel_data-synthetic_pixel_reprojection).^2,2)));
end