function mbe = test_mean_backprojection_error(calibration_est,checkerboard,window_array,grid_size,showPlots)
    centre_pixel = calibration_est(2,1:2); % temp
    cx = centre_pixel(2);
    cy = centre_pixel(1);
    K1 = calibration_est(1,1);
    K2 = calibration_est(1,2);
    A = -1/K2;
    B = -K1/K2;
    fx = calibration_est(1,3);
    fy = calibration_est(2,3);
    k1 = calibration_est(3,1);
    k2 = calibration_est(3,2);
    errors = [];
    [K,~,T] = size(window_array);
    if showPlots
        figure; hold on;
        for k = 1:K
            scatterarray3(checkerboard,'k');
        end
    end
    for t = 1:T
        disp_t = calibration_est(2*t+3,:);
        ang_t = calibration_est(2*t+4,:);
        rot_t = expm(skew3(ang_t));
        if showPlots
            scatterarray3(disp_t,'k*');
            plotarray3([disp_t;disp_t+100*rot_t(:,1)'],'r');
            plotarray3([disp_t;disp_t+100*rot_t(:,2)'],'g');
            plotarray3([disp_t;disp_t+100*rot_t(:,3)'],'b');
        end
        window_map = window_array(:,:,t);
        for k = 1:K
            R = window_map(k,1);
            lx = window_map(k,2)-cx;
            ly = window_map(k,3)-cy;
            ru = sqrt(lx^2 + ly^2);
            rds = (roots([k2,0,k1,0,1,-ru]));
            rds = rds(rds==real(rds));
            [~,i] = min(abs(rds));
            rd = rds(i);
            lxd = (rd/ru)*lx;
            lyd = (rd/ru)*ly;
            Pz = 1/(B + A*R);
            Px = Pz*lxd/fx;
            Py = Pz*lyd/fy;
            P = disp_t+(rot_t*[Px;Py;Pz])';
            errors = [errors;sqrt(sum((P - grid_size*[window_map(k,4),window_map(k,5),0]).^2))/Pz];
            if showPlots
                %scatterarray3(P,'r');
            end
        end
    end
    if showPlots
        axis equal;
    end
    mbe = (mean(errors));
end

            
