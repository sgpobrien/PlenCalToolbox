function mre = test_mean_reprojection_error(calibration_est,raw_light_field,nfiles,checkerboard,window_array,boardSize,field_of_view,lenses_coordinates,showPlot)
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
    for t = 1:nfiles
        pos = calibration_est(2*t+3,:);
        ang = calibration_est(2*t+4,:);
        rot = expm(skew3(ang));
        pcam.pose.position = pos; %is this used?
        pcam.pose.rotation = rot; %is this used?
        for i = 1:(boardSize(1)-1)
            for j = 1:(boardSize(2)-1)
                point = checkerboard((i-1)*(boardSize(2)-1)+j,:);
                P = (rot'*(point-pos)')'; % body-fixed coordinates of point
    %             P = (rot_s*(point)')'+disp_s; % body-fixed coordinates of point
                Px = P(1);  
                Py = P(2); 
                Pz = P(3); % depth of P
                
               % My distortion model
                wx = fx*Px/Pz;
                wy = fy*Py/Pz;
                r = wx^2+wy^2;
                wx = wx*(1+c1*r+c2*r^2)+cx;
                wy = wy*(1+c1*r+c2*r^2)+cy; %uncomment up to here
                R = (1/(A*Pz)) - B/A;
                window_params_est((i-1)*(boardSize(2)-1)+j,:,t) = [R,wx,wy];
    %             err(i,j,t) = norm(window_array((i-1)*J+j,1:3,t)-window_params_est((i-1)*J+j,:,t));
            end
        end
        projections{t} = show_windows(raw_light_field,window_array(:,1:3,t),lenses_coordinates,field_of_view,boardSize,t==showPlot);
        reprojections{t} = show_windows_reprojections(raw_light_field,window_array(:,1:3,t),window_params_est(:,:,t),lenses_coordinates,field_of_view,boardSize,t==showPlot);
    end
    for t=1:nfiles
        mret(t) = sum(sum(sqrt((projections{t}-reprojections{t})'.^2),2));
        denom(t) = numel(projections{t})/6;
    end
    mre = (sum(mret)/(sum(denom)));
end